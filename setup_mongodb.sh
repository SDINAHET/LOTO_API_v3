#!/bin/bash

echo "=== Configuration de MongoDB ==="

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Charger les variables d'environnement
source .env

# Vérifier si MongoDB est en cours d'exécution
echo "Vérification du statut de MongoDB..."
if ! systemctl is-active --quiet mongod; then
    echo "Démarrage de MongoDB..."
    systemctl start mongod
    sleep 5
fi

# Créer l'utilisateur MongoDB
echo "Création de l'utilisateur MongoDB..."
mongosh admin --eval "
    db.createUser({
        user: '${MONGODB_USER}',
        pwd: '${MONGODB_PASSWORD}',
        roles: [
            { role: 'userAdminAnyDatabase', db: 'admin' },
            { role: 'readWriteAnyDatabase', db: 'admin' }
        ]
    })
"

# Créer la base de données et les collections
echo "Création de la base de données..."
mongosh ${MONGODB_DATABASE} -u ${MONGODB_USER} -p ${MONGODB_PASSWORD} --authenticationDatabase admin --eval "
    db.createCollection('ticket_gains');
    db.createCollection('users');
"

# Configuration de la sécurité
echo "Configuration de la sécurité..."
cat > /etc/mongod.conf << EOL
security:
  authorization: enabled

net:
  port: ${MONGODB_PORT}
  bindIp: 0.0.0.0

storage:
  dbPath: /var/lib/mongodb

systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
EOL

# Redémarrer MongoDB pour appliquer les changements
echo "Redémarrage de MongoDB..."
systemctl restart mongod

# Vérifier la connexion
echo "Test de la connexion..."
mongosh ${MONGODB_DATABASE} -u ${MONGODB_USER} -p ${MONGODB_PASSWORD} --authenticationDatabase admin --eval "db.stats()"

echo "=== Configuration de MongoDB terminée ==="

# Afficher les informations de connexion
echo -e "\nInformations de connexion MongoDB :"
echo "Base de données : ${MONGODB_DATABASE}"
echo "Port : ${MONGODB_PORT}"
echo "Utilisateur : ${MONGODB_USER}"
echo "URL de connexion : mongodb://${MONGODB_USER}:${MONGODB_PASSWORD}@localhost:${MONGODB_PORT}/${MONGODB_DATABASE}"
