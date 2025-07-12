#!/bin/bash

echo "=== Démarrage complet de l'application LOTO API ==="

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Charger les variables d'environnement
if [ -f .env ]; then
    source .env
else
    echo "Fichier .env non trouvé"
    exit 1
fi

# Fonction pour vérifier le statut d'un service
check_service() {
    if systemctl is-active --quiet $1; then
        echo "✅ $1 est démarré"
    else
        echo "❌ $1 n'est pas démarré"
        return 1
    fi
}

# 1. Démarrer PostgreSQL
echo -e "\n1. Démarrage de PostgreSQL..."
systemctl start postgresql
check_service postgresql

# 2. Démarrer MongoDB
echo -e "\n2. Démarrage de MongoDB..."
systemctl start mongod
check_service mongod

# 3. Vérifier les connexions aux bases de données
echo -e "\n3. Vérification des connexions..."

# Test PostgreSQL
echo "Test de PostgreSQL..."
if PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -c '\l' > /dev/null 2>&1; then
    echo "✅ Connexion PostgreSQL réussie"
else
    echo "❌ Échec de connexion à PostgreSQL"
    exit 1
fi

# Test MongoDB
echo "Test de MongoDB..."
if mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo "✅ Connexion MongoDB réussie"
else
    echo "❌ Échec de connexion à MongoDB"
    exit 1
fi

# 4. Compiler l'application
echo -e "\n4. Compilation de l'application..."
mvn clean install -DskipTests

# 5. Démarrer l'application Spring Boot
echo -e "\n5. Démarrage de l'application..."
if [ -f target/loto-api-0.0.1-SNAPSHOT.jar ]; then
    nohup java -jar target/loto-api-0.0.1-SNAPSHOT.jar > app.log 2>&1 &
    APP_PID=$!
    echo "✅ Application démarrée avec PID: $APP_PID"
else
    echo "❌ Fichier JAR non trouvé"
    exit 1
fi

# 6. Vérifier que l'application est bien démarrée
echo -e "\n6. Vérification de l'application..."
sleep 10
if curl -s http://localhost:8082/actuator/health | grep -q "UP"; then
    echo "✅ Application prête et en bonne santé"
else
    echo "❌ L'application ne répond pas correctement"
    exit 1
fi

echo -e "\n=== Installation terminée avec succès ==="
echo "PostgreSQL : localhost:5432"
echo "MongoDB : localhost:27017"
echo "Application : http://localhost:8082"
echo -e "\nLogs de l'application : tail -f app.log"
echo "Pour arrêter : kill $APP_PID"
