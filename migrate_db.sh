#!/bin/bash

echo "=== Migration de la base de données SQLite vers PostgreSQL ==="

# 1. Configuration de PostgreSQL
echo "1. Configuration de PostgreSQL..."
./config_postgres.sh
if [ $? -ne 0 ]; then
    echo "Erreur lors de la configuration de PostgreSQL"
    exit 1
fi

# 2. Création des tables
echo "2. Création des tables..."
export PGPASSWORD=postgres
psql -h localhost -U postgres -d lotodb -f src/main/resources/db/migration/V1__initial_schema.sql
if [ $? -ne 0 ]; then
    echo "Erreur lors de la création des tables"
    exit 1
fi

# 3. Migration des données
echo "3. Migration des données depuis SQLite..."
python3 src/main/resources/db/migration/sqlite_to_postgres.py
if [ $? -ne 0 ]; then
    echo "Erreur lors de la migration des données"
    exit 1
fi

# 4. Vérification
echo "4. Vérification de la migration..."
psql -h localhost -U postgres -d lotodb -c "SELECT COUNT(*) FROM users;"
psql -h localhost -U postgres -d lotodb -c "SELECT COUNT(*) FROM tickets;"

echo "=== Migration terminée avec succès ==="

# 5. Démarrage de l'application
echo "5. Démarrage de l'application..."
./mvnw spring-boot:run
