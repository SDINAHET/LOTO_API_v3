#!/bin/bash

echo "=== Configuration de PostgreSQL ==="

# Vérifier les droits sudo
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté avec sudo"
  exit 1
fi

# Démarrer PostgreSQL
service postgresql start

# Chemin vers pg_hba.conf
PG_HBA_PATH="/etc/postgresql/14/main/pg_hba.conf"

# Sauvegarder le fichier original
cp $PG_HBA_PATH "${PG_HBA_PATH}.backup"

# Modifier pg_hba.conf
cat > $PG_HBA_PATH << EOF
# PostgreSQL Client Authentication Configuration File
local   all             postgres                                trust
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
EOF

# Redémarrer PostgreSQL
service postgresql restart

# Créer l'utilisateur et la base de données
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgres';\""
su - postgres -c "psql -c \"CREATE DATABASE lotodb;\""

echo "=== Configuration terminée ==="
echo "PostgreSQL est configuré avec :"
echo "- Base de données : lotodb"
echo "- Utilisateur : postgres"
echo "- Mot de passe : postgres"
echo "- Port : 5432"
