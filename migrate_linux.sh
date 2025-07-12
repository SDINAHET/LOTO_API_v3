#!/bin/bash

echo "=== Migration SQLite vers PostgreSQL et demarrage ==="

# Variables PostgreSQL
export PGUSER=postgres
export PGPASSWORD=postgres

# Vérifier si loto.db existe
if [ ! -f loto.db ]; then
    echo "Erreur: loto.db non trouvé"
    echo "Copiez votre base de données SQLite dans le répertoire courant"
    exit 1
fi

# Créer la base de données PostgreSQL
echo "Création de la base de données PostgreSQL..."
sudo -u postgres createdb lotodb || echo "La base de données existe peut-être déjà"

# Créer les tables
echo "Création des tables..."
sudo -u postgres psql -d lotodb -f src/main/resources/db/migration/V1__initial_schema.sql

# Définir le mot de passe PostgreSQL
echo "Configuration du mot de passe..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

# Exécuter le script de migration
echo "Migration des données..."
python3 src/main/resources/db/migration/sqlite_to_postgres.py

# Compiler et démarrer l'application
echo "Compilation et démarrage de l'application..."
mvn clean install -DskipTests
mvn spring-boot:run

echo "=== Fin du processus ==="
