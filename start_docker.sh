#!/bin/bash

echo "=== Démarrage de l'environnement Docker ==="

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
fi

# Vérifier que Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose n'est pas installé. Installation..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Arrêter les conteneurs existants
echo "Arrêt des conteneurs existants..."
docker-compose down

# Construire les images
echo "Construction des images..."
docker-compose build --no-cache

# Démarrer les services
echo "Démarrage des services..."
docker-compose up -d

# Attendre que les services soient prêts
echo "Attente du démarrage des services..."
sleep 10

# Vérifier l'état des services
echo -e "\nÉtat des conteneurs :"
docker-compose ps

# Afficher les logs
echo -e "\nLogs des services :"
docker-compose logs --tail=20

echo -e "\n=== Services démarrés ==="
echo "PostgreSQL : localhost:5432"
echo "MongoDB : localhost:27017"
echo "API : localhost:8082"
echo ""
echo "Pour voir les logs en temps réel : docker-compose logs -f"
echo "Pour arrêter les services : docker-compose down"
