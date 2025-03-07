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

# リモートサーバーでの処理
echo -e "${GREEN}Running remote commands...${NC}"
cd ~/rails/myapp && \
git pull origin main && \
bundle install --without development test && \
RAILS_ENV=production bundle exec rails assets:precompile && \
RAILS_ENV=production bundle exec rails db:migrate && \
sudo systemctl restart puma

echo -e "${GREEN}Deployment completed!${NC}" 