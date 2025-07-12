#!/bin/bash

echo "=== Sauvegarde des bases de données LOTO API ==="

# Vérifier les privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root"
    exit 1
fi

# Charger les variables d'environnement
source .env

# Configuration
BACKUP_DIR=${BACKUP_PATH:-/var/backups/lotodb}
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}

# Créer le répertoire de backup s'il n'existe pas
mkdir -p $BACKUP_DIR

# Fonction pour logger
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Backup PostgreSQL
backup_postgres() {
    local pg_backup_file="$BACKUP_DIR/postgres_${DATE}.sql.gz"
    log_message "Démarrage de la sauvegarde PostgreSQL..."

    if PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h localhost -U $POSTGRES_USER $POSTGRES_DB | gzip > $pg_backup_file; then
        log_message "✅ Sauvegarde PostgreSQL terminée : $pg_backup_file"
    else
        log_message "❌ Erreur lors de la sauvegarde PostgreSQL"
        return 1
    fi
}

# Backup MongoDB
backup_mongodb() {
    local mongo_backup_dir="$BACKUP_DIR/mongodb_${DATE}"
    log_message "Démarrage de la sauvegarde MongoDB..."

    if mongodump --host localhost --port $MONGODB_PORT \
                 --username $MONGODB_USER --password $MONGODB_PASSWORD \
                 --authenticationDatabase admin \
                 --db $MONGODB_DATABASE \
                 --out $mongo_backup_dir; then
        # Compresser le dossier de backup
        tar -czf "${mongo_backup_dir}.tar.gz" -C $BACKUP_DIR "mongodb_${DATE}"
        rm -rf $mongo_backup_dir
        log_message "✅ Sauvegarde MongoDB terminée : ${mongo_backup_dir}.tar.gz"
    else
        log_message "❌ Erreur lors de la sauvegarde MongoDB"
        return 1
    fi
}

# Nettoyer les anciennes sauvegardes
cleanup_old_backups() {
    log_message "Nettoyage des anciennes sauvegardes (> $RETENTION_DAYS jours)..."
    find $BACKUP_DIR -name "postgres_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    find $BACKUP_DIR -name "mongodb_*.tar.gz" -mtime +$RETENTION_DAYS -delete
}

# Créer un rapport de sauvegarde
create_backup_report() {
    local report_file="$BACKUP_DIR/backup_report_${DATE}.txt"

    echo "Rapport de sauvegarde - ${DATE}" > $report_file
    echo "================================" >> $report_file
    echo "" >> $report_file
    echo "PostgreSQL:" >> $report_file
    ls -lh $BACKUP_DIR/postgres_${DATE}.sql.gz >> $report_file
    echo "" >> $report_file
    echo "MongoDB:" >> $report_file
    ls -lh $BACKUP_DIR/mongodb_${DATE}.tar.gz >> $report_file
    echo "" >> $report_file
    echo "Espace disque restant:" >> $report_file
    df -h $BACKUP_DIR >> $report_file
}

# Exécution principale
main() {
    log_message "Démarrage du processus de sauvegarde..."

    # Vérifier l'espace disque
    SPACE=$(df -P $BACKUP_DIR | awk 'NR==2 {print $4}')
    if [ $SPACE -lt 1048576 ]; then  # Moins de 1GB
        log_message "❌ Espace disque insuffisant"
        exit 1
    fi

    # Effectuer les sauvegardes
    backup_postgres
    backup_mongodb

    # Nettoyage et rapport
    cleanup_old_backups
    create_backup_report

    log_message "✅ Processus de sauvegarde terminé"

    # Afficher les informations de sauvegarde
    echo -e "\nFichiers de sauvegarde créés :"
    ls -lh $BACKUP_DIR/*_${DATE}*
}

# Lancer le processus
main
