#!/bin/bash

echo "=== Installation complète de LOTO API sur Ubuntu ==="

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# 1. Installation des dépendances système
echo "Installation des dépendances système..."
apt-get update
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    git \
    wget \
    curl \
    openjdk-21-jdk \
    maven

# 2. Installation de PostgreSQL
echo "Installation de PostgreSQL..."
apt-get install -y postgresql-14 postgresql-contrib-14

# 3. Installation de MongoDB
echo "Installation de MongoDB..."
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update
apt-get install -y mongodb-org

# 4. Configuration de l'environnement Python
echo "Configuration de Python..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. Configuration des services
echo "Configuration des services..."
systemctl enable postgresql
systemctl enable mongod
systemctl start postgresql
systemctl start mongod

# 6. Configuration des bases de données
echo "Configuration des bases de données..."
./config_postgres.sh
./setup_mongodb.sh

# 7. Migration des données
echo "Migration des données..."
./migrate_db.sh

# 8. Configuration du service systemd
echo "Configuration du service systemd..."
cat > /etc/systemd/system/lotoapi.service << EOL
[Unit]
Description=LOTO API Service
After=network.target postgresql.service mongod.service

[Service]
Type=simple
User=lotoapi
WorkingDirectory=/opt/lotoapi
Environment=JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
Environment=PATH=/opt/lotoapi/venv/bin:$PATH
EnvironmentFile=/opt/lotoapi/.env
ExecStart=/usr/bin/java -jar /opt/lotoapi/target/loto-api-0.0.1-SNAPSHOT.jar
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# 9. Création de l'utilisateur de service
echo "Création de l'utilisateur de service..."
useradd -r -s /bin/false lotoapi
mkdir -p /opt/lotoapi
cp -r * /opt/lotoapi/
chown -R lotoapi:lotoapi /opt/lotoapi

# 10. Finalisation
echo "Finalisation de l'installation..."
systemctl daemon-reload
systemctl enable lotoapi
systemctl start lotoapi

echo "=== Installation terminée ==="
echo "Vérifiez les logs avec : journalctl -u lotoapi -f"
echo "Status du service : systemctl status lotoapi"
