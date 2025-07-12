#!/bin/bash

echo "=== Installation complète de LOTO API sur Linux ==="

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Configuration des couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction pour le logging
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# 1. Mise à jour du système
log "Mise à jour du système..."
apt-get update
apt-get upgrade -y

# 2. Installation des dépendances de base
log "Installation des dépendances de base..."
apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg

# 3. Installation de Java
log "Installation de Java..."
apt-get install -y openjdk-21-jdk
java -version

# 4. Installation de Maven
log "Installation de Maven..."
apt-get install -y maven
mvn -version

# 5. Installation de PostgreSQL
log "Installation de PostgreSQL..."
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install -y postgresql-14 postgresql-contrib-14

# 6. Installation de MongoDB
log "Installation de MongoDB..."
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update
apt-get install -y mongodb-org

# 7. Installation de Python et ses dépendances
log "Installation de Python..."
apt-get install -y python3 python3-pip python3-venv python3-dev

# 8. Configuration de l'environnement
log "Configuration de l'environnement..."
mkdir -p /opt/lotoapi
cp -r * /opt/lotoapi/
cd /opt/lotoapi

# 9. Configuration des bases de données
log "Configuration des bases de données..."
./setup_databases.sh

# 10. Configuration de l'environnement Python
log "Configuration de l'environnement Python..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 11. Compilation du projet
log "Compilation du projet..."
mvn clean install -DskipTests

# 12. Configuration du service systemd
log "Configuration du service systemd..."
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

# 13. Création de l'utilisateur de service
log "Création de l'utilisateur de service..."
useradd -r -s /bin/false lotoapi
chown -R lotoapi:lotoapi /opt/lotoapi

# 14. Démarrage des services
log "Démarrage des services..."
systemctl daemon-reload
systemctl enable postgresql mongod lotoapi
systemctl start postgresql mongod lotoapi

# 15. Vérification finale
log "Vérification finale..."
./check_status.sh

log "=== Installation terminée ==="
echo "L'application est accessible sur : http://localhost:8082"
echo "Documentation API : http://localhost:8082/swagger-ui.html"
echo "Pour voir les logs : journalctl -u lotoapi -f"
