#!/bin/bash

echo "=== Nettoyage et reconstruction du projet ==="

# Nettoyer le cache Maven local pour les dépendances problématiques
echo "Nettoyage du cache Maven..."
rm -rf ~/.m2/repository/org/springframework/boot/spring-boot-starter-data-mongodb
rm -rf ~/.m2/repository/org/mongodb

# Nettoyer le projet
echo "Nettoyage du projet..."
./mvnw clean

# Mettre à jour les dépendances Maven
echo "Mise à jour des dépendances..."
./mvnw dependency:purge-local-repository

# Compiler le projet
echo "Compilation du projet..."
./mvnw compile

# Installation des dépendances
echo "Installation des dépendances..."
./mvnw install -DskipTests

echo "=== Nettoyage et reconstruction terminés ==="

# Vérifier la présence des JAR nécessaires
echo "Vérification des dépendances..."
ls -l ~/.m2/repository/org/springframework/boot/spring-boot-starter-data-mongodb
ls -l ~/.m2/repository/org/mongodb

# Afficher le statut final
if [ $? -eq 0 ]; then
    echo "Build réussi!"
else
    echo "Erreur lors du build. Vérifiez les logs ci-dessus."
    exit 1
fi
