#!/bin/bash

echo "=== Démarrage des bases de données PostgreSQL et MongoDB ==="

# Vérifier que le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Charger les variables d'environnement
set -a
source .env
set +a

# Démarrer PostgreSQL
echo "Démarrage de PostgreSQL..."
systemctl start postgresql
if [ $? -eq 0 ]; then
    echo "PostgreSQL démarré avec succès"
else
    echo "Erreur lors du démarrage de PostgreSQL"
    exit 1
fi

# Démarrer MongoDB
echo "Démarrage de MongoDB..."
systemctl start mongod
if [ $? -eq 0 ]; then
    echo "MongoDB démarré avec succès"
else
    echo "Erreur lors du démarrage de MongoDB"
    exit 1
fi

# Vérifier les connexions
echo "Test de la connexion PostgreSQL..."
PGPASSWORD=$POSTGRES_PASSWORD psql -U $POSTGRES_USER -h $POSTGRES_HOST -p $POSTGRES_PORT -d $POSTGRES_DB -c "\conninfo"

echo "Test de la connexion MongoDB..."
mongosh --host $MONGODB_HOST --port $MONGODB_PORT -u $MONGODB_USER -p $MONGODB_PASSWORD --eval "db.version()"

echo "=== Les bases de données sont prêtes ==="

# Afficher les ports utilisés
echo "PostgreSQL : port $POSTGRES_PORT"
echo "MongoDB : port $MONGODB_PORT"

# Afficher les processus
echo -e "\nProcessus en cours :"
ps aux | grep -E "postgres|mongod"
