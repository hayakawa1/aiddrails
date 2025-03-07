#!/bin/bash

# 設定
REMOTE_USER="deploy"
REMOTE_HOST="202.182.100.5"
REMOTE_DIR="/var/www/myapp"
APP_NAME="myapp"

# 色の設定
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Deploying to ${REMOTE_HOST}...${NC}"

# GitHubから最新のコードを取得
echo -e "${GREEN}Pulling latest changes...${NC}"
git pull origin main

# アプリケーションファイルをサーバーに転送
echo -e "${GREEN}Syncing files to server...${NC}"
rsync -avz --exclude='.git' \
          --exclude='log' \
          --exclude='tmp' \
          --exclude='node_modules' \
          --exclude='.env' \
          --exclude='storage' \
          ./ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/

# リモートサーバーでの処理
echo -e "${GREEN}Running remote commands...${NC}"
ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && \
    bundle install --without development test && \
    RAILS_ENV=production bundle exec rails assets:precompile && \
    RAILS_ENV=production bundle exec rails db:migrate && \
    sudo systemctl restart puma"

echo -e "${GREEN}Deployment completed!${NC}" 