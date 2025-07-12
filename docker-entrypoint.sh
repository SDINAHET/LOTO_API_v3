#!/bin/bash
set -e

# Fonction pour attendre que PostgreSQL soit prêt
wait_for_postgres() {
    echo "Attente de PostgreSQL..."
    until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
        echo "PostgreSQL n'est pas prêt - attente..."
        sleep 2
    done
    echo "PostgreSQL est prêt !"
}

# Fonction pour attendre que MongoDB soit prêt
wait_for_mongodb() {
    echo "Attente de MongoDB..."
    until mongosh --host "$MONGODB_HOST" --port "$MONGODB_PORT" \
         -u "$MONGODB_USER" -p "$MONGODB_PASSWORD" \
         --authenticationDatabase admin \
         --eval "db.version()" >/dev/null 2>&1; do
        echo "MongoDB n'est pas prêt - attente..."
        sleep 2
    done
    echo "MongoDB est prêt !"
}

echo "=== Démarrage de l'application ==="

# Attendre que les bases de données soient prêtes
wait_for_postgres
wait_for_mongodb

# Vérifier la présence des variables d'environnement requises
: "${POSTGRES_HOST:?Variable POSTGRES_HOST non définie}"
: "${MONGODB_HOST:?Variable MONGODB_HOST non définie}"

# Appliquer les migrations PostgreSQL
echo "Application des migrations PostgreSQL..."
PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /app/db/migration/V1__initial_schema.sql

# Lancer l'application Spring Boot
echo "Démarrage de l'application Spring Boot..."
exec "$@"
