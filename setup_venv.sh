#!/bin/bash

echo "=== Configuration de l'environnement Python pour LOTO API ==="

# Vérifier la version de Python
python3 --version
if [ $? -ne 0 ]; then
    echo "Python3 n'est pas installé. Installation..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
fi

# Créer un environnement virtuel
echo "Création de l'environnement virtuel..."
python3 -m venv venv
if [ $? -ne 0 ]; then
    echo "Erreur lors de la création de l'environnement virtuel"
    exit 1
fi

# Activer l'environnement virtuel
echo "Activation de l'environnement virtuel..."
source venv/bin/activate

# Mettre à jour pip
echo "Mise à jour de pip..."
pip install --upgrade pip

# Installer les dépendances système requises
echo "Installation des dépendances système..."
sudo apt-get install -y \
    build-essential \
    python3-dev \
    libpq-dev \
    gcc

# Installer les dépendances Python
echo "Installation des dépendances Python..."
pip install -r requirements.txt

# Vérifier les installations
echo -e "\nVérification des installations :"
pip list

echo -e "\n=== Configuration terminée ==="
echo "Pour activer l'environnement : source venv/bin/activate"
echo "Pour désactiver : deactivate"
