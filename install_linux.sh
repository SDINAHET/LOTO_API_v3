#!/bin/bash

# Script d'installation pour Linux
echo "=== Installation de l'application LOTO API ==="

# Vérifier si l'utilisateur est root
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root"
  exit 1
fi

# 1. Installer les dépendances système
echo "Installation des dépendances système..."
apt-get update
apt-get install -y openjdk-21-jdk maven postgresql postgresql-contrib python3 python3-pip

# 2. Installer les dépendances Python
echo "Installation des dépendances Python..."
pip3 install psycopg2-binary

# 3. Configuration de PostgreSQL
echo "Configuration de PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql

# 4. Charger les variables d'environnement
echo "Chargement des variables d'environnement..."
set -a
source .env
set +a

# 5. Créer l'utilisateur et la base de données PostgreSQL
echo "Configuration de la base de données..."
sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';" || true
sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};" || true
sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH SUPERUSER;" || true

# 6. Configurer pg_hba.conf
PG_HBA_CONF="/etc/postgresql/14/main/pg_hba.conf"
echo "Configuration de pg_hba.conf..."
cp $PG_HBA_CONF "${PG_HBA_CONF}.backup"
cat > $PG_HBA_CONF << EOL
local   all             postgres                                trust
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             0.0.0.0/0               md5
EOL

# 7. Redémarrer PostgreSQL
echo "Redémarrage de PostgreSQL..."
systemctl restart postgresql

# 8. Compiler l'application
echo "Compilation de l'application..."
mvn clean package -DskipTests

# 9. Créer le service systemd
echo "Création du service systemd..."
cat > /etc/systemd/system/lotoapi.service << EOL
[Unit]
Description=Loto API Service
After=network.target postgresql.service

[Service]
Environment="SPRING_PROFILES_ACTIVE=prod"
EnvironmentFile=/path/to/app/.env
User=lotoapi
ExecStart=/usr/bin/java ${JAVA_OPTS} -jar /path/to/app/target/loto-api-0.0.1-SNAPSHOT.jar
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

# 10. Créer l'utilisateur de service
echo "Création de l'utilisateur de service..."
useradd -r -s /bin/false lotoapi || true

# 11. Configurer les permissions
echo "Configuration des permissions..."
chown -R lotoapi:lotoapi /path/to/app

# 12. Activer et démarrer le service
echo "Activation du service..."
systemctl daemon-reload
systemctl enable lotoapi
systemctl start lotoapi

echo "=== Installation terminée ==="
echo "Vérifiez les logs avec: journalctl -u lotoapi -f"
