#!/bin/bash

echo "=== Test des connexions aux bases de données ==="

# Charger les variables d'environnement
source .env

# Fonction pour afficher les résultats
print_result() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 - Succès"
    else
        echo "❌ $1 - Échec"
        GLOBAL_STATUS=1
    fi
}

# Initialiser le statut global
GLOBAL_STATUS=0

echo -e "\n1. Test de PostgreSQL"
echo "----------------------"
# Test de la connexion PostgreSQL
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "\dt" > /dev/null 2>&1
print_result "Connexion à PostgreSQL"

# Test des tables PostgreSQL
PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT count(*) FROM users;" > /dev/null 2>&1
print_result "Table 'users'"

PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT count(*) FROM tickets;" > /dev/null 2>&1
print_result "Table 'tickets'"

echo -e "\n2. Test de MongoDB"
echo "-------------------"
# Test de la connexion MongoDB
mongosh --host $MONGODB_HOST --port $MONGODB_PORT -u $MONGODB_USER -p $MONGODB_PASSWORD --eval "db.version()" > /dev/null 2>&1
print_result "Connexion à MongoDB"

# Test des collections MongoDB
mongosh --host $MONGODB_HOST --port $MONGODB_PORT -u $MONGODB_USER -p $MONGODB_PASSWORD --eval "db.ticket_gains.count()" > /dev/null 2>&1
print_result "Collection 'ticket_gains'"

echo -e "\n3. Test de l'API"
echo "----------------"
# Test de l'API Health
curl -s http://localhost:8082/actuator/health > /dev/null
print_result "Health Check de l'API"

# Afficher le résultat final
echo -e "\n=== Résultat final ==="
if [ $GLOBAL_STATUS -eq 0 ]; then
    echo "✅ Tous les tests ont réussi"
else
    echo "❌ Certains tests ont échoué"
fi

exit $GLOBAL_STATUS
