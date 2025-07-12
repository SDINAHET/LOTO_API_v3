#!/bin/bash

echo "Configuration de PostgreSQL..."

# Vérifier si PostgreSQL est installé
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL n'est pas installé. Installation en cours..."
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib
fi

# Démarrer PostgreSQL
echo "Démarrage de PostgreSQL..."
sudo service postgresql start

# Attendre que PostgreSQL démarre
echo "Attente du démarrage de PostgreSQL..."
sleep 5

# Configurer l'accès local
echo "Configuration de l'accès local..."
sudo sed -i "s/local.*all.*postgres.*peer/local   all             postgres                                trust/" /etc/postgresql/14/main/pg_hba.conf
sudo sed -i "s/host.*all.*all.*127.0.0.1\/32.*scram-sha-256/host    all             all             127.0.0.1\/32            md5/" /etc/postgresql/14/main/pg_hba.conf

# Redémarrer PostgreSQL pour appliquer les changements
echo "Redémarrage de PostgreSQL..."
sudo service postgresql restart
sleep 5

# Configurer l'utilisateur postgres
echo "Configuration de l'utilisateur postgres..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# Créer la base de données
echo "Création de la base de données..."
sudo -u postgres createdb -O postgres lotodb || echo "La base de données existe déjà"

# Vérifier la connexion
echo "Test de la connexion..."
export PGPASSWORD=postgres
psql -h localhost -U postgres -d lotodb -c "\l"

echo "Configuration terminée !"
echo "Base de données : lotodb"
echo "Utilisateur : postgres"
echo "Mot de passe : postgres"
echo "Port : 5432"
