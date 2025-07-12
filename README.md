# LOTO API

## Prérequis système
- Python 3.8+
- Java 21
- PostgreSQL 14+
- MongoDB 7.0+

## Installation

### 1. Cloner le projet
```bash
git clone <repository_url>
cd LOTO_API_v3
```

### 2. Configurer l'environnement

#### A. Configuration Python
```bash
# Rendre le script exécutable
chmod +x setup_venv.sh

# Exécuter le script de configuration Python
./setup_venv.sh

# Activer l'environnement virtuel
source venv/bin/activate
```

#### B. Configuration des bases de données
```bash
# Rendre les scripts exécutables
chmod +x install_dependencies.sh config_postgres.sh

# Installer les dépendances système
sudo ./install_dependencies.sh

# Configurer PostgreSQL et MongoDB
sudo ./config_postgres.sh
```

### 3. Configuration de l'application

```bash
# Copier le fichier d'environnement exemple
cp .env.example .env

# Éditer les configurations
nano .env
```

### 4. Migration des données

```bash
# Rendre le script exécutable
chmod +x migrate_db.sh

# Lancer la migration
./migrate_db.sh
```

### 5. Démarrage de l'application

#### Option A : Démarrage direct
```bash
./mvnw spring-boot:run
```

#### Option B : Démarrage avec Docker
```bash
# Construire et démarrer les conteneurs
docker-compose up -d
```

## Test de l'installation

```bash
# Rendre le script exécutable
chmod +x test_connections.sh

# Lancer les tests
./test_connections.sh
```

## Versions des dépendances

### Python
```
python-dotenv==1.0.0
ruamel.yaml==0.17.21
psycopg2-binary==2.9.9
SQLAlchemy==1.4.47
pymongo==4.6.1
```

### Java
```xml
<java.version>21</java.version>
<postgresql.version>42.7.5</postgresql.version>
<mongodb.version>4.11.1</mongodb.version>
```

### Bases de données
- PostgreSQL 14.11
- MongoDB 7.0.5

## Structure du projet
```
LOTO_API_v3/
├── src/
│   └── main/
│       ├── java/
│       └── resources/
├── docker/
├── scripts/
└── config/
```

## Commandes utiles

### Gestion des bases de données
```bash
# Démarrer les bases de données
./start_databases.sh

# Arrêter les bases de données
./stop_databases.sh

# Vérifier l'état
./status_databases.sh
```

### Maintenance
```bash
# Backup des données
./backup_databases.sh

# Restauration
./restore_databases.sh

# Nettoyage des logs
./clean_logs.sh
```

## Support

Pour toute question ou problème :
1. Consulter les logs : `./view_logs.sh`
2. Vérifier l'état des services : `./check_status.sh`
3. Contacter l'équipe de support

## Contributions

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request
