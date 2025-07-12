# Prérequis pour LOTO API

## Versions des composants

### Java
- OpenJDK 21.0.7 ou supérieur

### Bases de données
- PostgreSQL 14.11
- MongoDB 7.0.5

### Python (pour les scripts)
- Python 3.8.10 ou supérieur
- pip 20.0.2 ou supérieur

### Outils système
- Maven 3.9.6
- Git (dernière version)
- curl ou wget

## Configuration système recommandée

### Système d'exploitation
- Linux (Ubuntu 22.04 LTS recommandé)
- Windows 10/11 avec WSL2
- macOS 12 ou supérieur

### Ressources minimales
- CPU : 2 cœurs
- RAM : 4 GB minimum
- Espace disque : 10 GB minimum

### Ports requis
- 8082 : API
- 5432 : PostgreSQL
- 27017 : MongoDB

## Installation des dépendances

### Sur Ubuntu/Debian
```bash
# Java
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk

# Maven
sudo apt-get install -y maven

# PostgreSQL
sudo apt-get install -y postgresql-14 postgresql-contrib-14

# MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Python et dépendances
sudo apt-get install -y python3 python3-pip python3-venv
```

### Sur Windows (avec WSL)
1. Installer WSL2
```powershell
wsl --install
```

2. Installer Ubuntu sur WSL
```powershell
wsl --install -d Ubuntu
```

3. Suivre les instructions pour Ubuntu ci-dessus dans le terminal WSL

### Sur macOS (avec Homebrew)
```bash
# Java
brew tap adoptopenjdk/openjdk
brew install --cask adoptopenjdk21

# Maven
brew install maven

# PostgreSQL
brew install postgresql@14

# MongoDB
brew tap mongodb/brew
brew install mongodb-community@7.0

# Python
brew install python@3.8
```

## Configuration des bases de données

### PostgreSQL
```bash
# Créer l'utilisateur et la base de données
sudo -u postgres createuser -P lotouser
sudo -u postgres createdb -O lotouser lotodb

# Configurer l'accès
echo "host all all 127.0.0.1/32 md5" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
```

### MongoDB
```bash
# Créer l'utilisateur admin
mongosh admin --eval '
  db.createUser({
    user: "lotouser",
    pwd: "lotopass",
    roles: ["userAdminAnyDatabase", "readWriteAnyDatabase"]
  })
'
```

## Configuration de l'environnement Python
```bash
# Créer un environnement virtuel
python3 -m venv venv

# Activer l'environnement
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt
```

## Vérification de l'installation

### Versions des composants
```bash
java -version          # Doit afficher Java 21
mvn -version          # Doit afficher Maven 3.9.6
python3 --version     # Doit afficher Python 3.8.10 ou supérieur
psql --version        # Doit afficher PostgreSQL 14
mongosh --version     # Doit afficher MongoDB 7.0.5
```

### Services
```bash
systemctl status postgresql  # Doit être actif
systemctl status mongod     # Doit être actif
```

### Connexions
```bash
# Test PostgreSQL
psql -h localhost -U lotouser -d lotodb -c "\conninfo"

# Test MongoDB
mongosh --eval "db.serverStatus()"
