#!/bin/bash

# PostgreSQLバックアップスクリプト
# crontabに以下のように設定して毎日3時に実行
# 0 3 * * * /var/www/aidd/myapp/current/deployment_configs/pg_backup.sh

# バックアップディレクトリ
BACKUP_DIR="/var/www/aidd/myapp/shared/db_backups"
mkdir -p $BACKUP_DIR

# バックアップファイル名（日付を含む）
DATE=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/postgres_backup_$DATE.sql.gz"

# 7日以上前のバックアップを削除
find $BACKUP_DIR -name "postgres_backup_*.sql.gz" -type f -mtime +7 -delete

# データベースのバックアップを作成
echo "Creating backup of all PostgreSQL databases..."
PGPASSWORD=postgres pg_dumpall -h localhost -U postgres | gzip > $BACKUP_FILE

# バックアップの結果を確認
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $BACKUP_FILE"
  echo "Backup size: $(du -h $BACKUP_FILE | cut -f1)"
else
  echo "Backup failed!"
  exit 1
fi

# 個別のデータベースもバックアップ
for DB in myapp_production myapp_cable_production myapp_queue_production myapp_cache_production; do
  BACKUP_FILE="$BACKUP_DIR/${DB}_backup_$DATE.sql.gz"
  echo "Creating backup of $DB database..."
  PGPASSWORD=postgres pg_dump -h localhost -U postgres $DB | gzip > $BACKUP_FILE
  
  if [ $? -eq 0 ]; then
    echo "Backup of $DB completed successfully: $BACKUP_FILE"
    echo "Backup size: $(du -h $BACKUP_FILE | cut -f1)"
  else
    echo "Backup of $DB failed!"
  fi
done

# バックアップの一覧を表示
echo "Available backups:"
ls -lh $BACKUP_DIR | grep "postgres_backup_"
