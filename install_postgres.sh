#!/bin/bash

echo "Installation de PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

echo "Démarrage du service PostgreSQL..."
sudo service postgresql start

echo "Création de la base de données..."
sudo -u postgres psql -c "CREATE DATABASE lotodb;"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

echo "Test de la connexion..."
sudo -u postgres psql -d lotodb -c "\l"

echo "Installation terminée!"
echo "Base de données 'lotodb' créée avec succès."
echo "Utilisateur: postgres"
echo "Mot de passe: postgres"
echo "Port: 5432"
