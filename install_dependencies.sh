#!/bin/bash

echo "=== Installation des dépendances système et Python ==="

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root"
  exit 1
fi

# Mise à jour du système
echo "Mise à jour du système..."
apt-get update
apt-get upgrade -y

# Installation des paquets système
echo "Installation des paquets système..."
while read -r package; do
    # Ignorer les lignes vides et les commentaires
    [[ -z "$package" || "$package" =~ ^#.*$ ]] && continue
    echo "Installation de $package..."
    apt-get install -y $package
done < apt_requirements.txt

# Mise à jour de pip
echo "Mise à jour de pip..."
python3 -m pip install --upgrade pip

# Installation des paquets Python
echo "Installation des paquets Python..."
python3 -m pip install -r requirements.txt

echo "=== Installation des dépendances terminée ==="

# Vérification des versions
echo -e "\nVérification des versions installées :"
echo "Python: $(python3 --version)"
echo "PostgreSQL: $(psql --version)"
echo "Java: $(java --version)"
echo "Maven: $(mvn --version)"
echo "Pip: $(pip3 --version)"
