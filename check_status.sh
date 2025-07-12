#!/bin/bash

echo "=== Vérification du statut de l'application LOTO API ==="

# Charger les variables d'environnement
if [ -f .env ]; then
    source .env
else
    echo "❌ Fichier .env non trouvé"
    exit 1
fi

# Couleurs pour le terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fonction pour vérifier un port
check_port() {
    local port=$1
    local service=$2
    if nc -z localhost $port; then
        echo -e "${GREEN}✓${NC} $service est accessible sur le port $port"
        return 0
    else
        echo -e "${RED}✗${NC} $service n'est pas accessible sur le port $port"
        return 1
    fi
}

# Fonction pour vérifier un processus
check_process() {
    local process=$1
    if pgrep -f "$process" > /dev/null; then
        echo -e "${GREEN}✓${NC} $process est en cours d'exécution"
        return 0
    else
        echo -e "${RED}✗${NC} $process n'est pas en cours d'exécution"
        return 1
    fi
}

# Fonction pour vérifier l'espace disque
check_disk_space() {
    local path=$1
    local threshold=80
    local usage=$(df -h $path | awk 'NR==2 {print $5}' | sed 's/%//')

    if [ $usage -gt $threshold ]; then
        echo -e "${RED}✗${NC} Espace disque critique : $usage% utilisé"
        return 1
    else
        echo -e "${GREEN}✓${NC} Espace disque OK : $usage% utilisé"
        return 0
    fi
}

# Fonction pour vérifier la mémoire
check_memory() {
    local threshold=80
    local usage=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')

    if [ $usage -gt $threshold ]; then
        echo -e "${RED}✗${NC} Utilisation mémoire critique : $usage%"
        return 1
    else
        echo -e "${GREEN}✓${NC} Utilisation mémoire OK : $usage%"
        return 0
    fi
}

# Vérifier la connexion PostgreSQL
check_postgres() {
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -c '\l' > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} PostgreSQL est connecté"
        return 0
    else
        echo -e "${RED}✗${NC} PostgreSQL n'est pas connecté"
        return 1
    fi
}

# Vérifier la connexion MongoDB
check_mongodb() {
    if mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} MongoDB est connecté"
        return 0
    else
        echo -e "${RED}✗${NC} MongoDB n'est pas connecté"
        return 1
    fi
}

# Vérifier l'API
check_api() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/actuator/health)
    if [ "$response" == "200" ]; then
        echo -e "${GREEN}✓${NC} L'API est en ligne"
        return 0
    else
        echo -e "${RED}✗${NC} L'API n'est pas accessible"
        return 1
    fi
}

# Vérifier les logs récents pour les erreurs
check_logs() {
    local error_count=$(grep -i "error\|exception" app.log 2>/dev/null | wc -l)
    if [ $error_count -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} $error_count erreurs trouvées dans les logs"
        echo "Dernières erreurs :"
        grep -i "error\|exception" app.log | tail -n 3
        return 1
    else
        echo -e "${GREEN}✓${NC} Aucune erreur récente dans les logs"
        return 0
    fi
}

# Afficher le statut global
echo -e "\n=== Services ==="
check_process "java"
check_process "postgres"
check_process "mongod"

echo -e "\n=== Ports ==="
check_port "8082" "API"
check_port "5432" "PostgreSQL"
check_port "27017" "MongoDB"

echo -e "\n=== Connexions aux bases de données ==="
check_postgres
check_mongodb

echo -e "\n=== Ressources système ==="
check_disk_space "/"
check_memory

echo -e "\n=== Application ==="
check_api
check_logs

# Afficher le résumé
echo -e "\n=== Résumé ==="
echo "Base de données : $(du -sh /var/lib/postgresql/14/main 2>/dev/null || echo 'N/A')"
echo "Logs : $(du -sh app.log 2>/dev/null || echo 'N/A')"
echo "Dernier redémarrage : $(uptime -s)"
echo "Uptime : $(uptime -p)"
