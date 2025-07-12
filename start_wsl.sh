#!/bin/bash

echo "=== Démarrage PostgreSQL et migration des données ==="

# Démarrer PostgreSQL
echo "Démarrage PostgreSQL..."
sudo service postgresql start

# Créer l'utilisateur et la base de données
echo "Configuration de la base de données..."
sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD 'postgres' SUPERUSER;" || true
sudo -u postgres psql -c "CREATE DATABASE lotodb OWNER postgres;" || true

# Exécuter le script de migration
echo "Création des tables..."
sudo -u postgres psql -d lotodb -f src/main/resources/db/migration/V1__initial_schema.sql

# Migration des données
echo "Migration des données..."
python3 src/main/resources/db/migration/sqlite_to_postgres.py

# Démarrer l'application
echo "Compilation et démarrage de l'application..."
./mvnw clean install -DskipTests
./mvnw spring-boot:run

echo "=== Processus terminé ==="
