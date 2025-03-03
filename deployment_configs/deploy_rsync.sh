#!/bin/bash
# Simple deployment script using rsync

# Configuration
SERVER="45.76.194.174"
SERVER_USER="root"
APP_DIR="/var/www/aidd/myapp"
SSH_KEY="$HOME/.ssh/aidd_deploy"
LOCAL_DIR="/Users/hiroshihayakawa/rails/myapp"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting deployment with rsync...${NC}"

# Create necessary directories on the server
echo -e "${YELLOW}Creating necessary directories on the server...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER "mkdir -p $APP_DIR/shared/config $APP_DIR/shared/log $APP_DIR/shared/tmp/pids $APP_DIR/shared/tmp/cache $APP_DIR/shared/tmp/sockets $APP_DIR/shared/public/system $APP_DIR/shared/storage"

# Copy master.key to the server if it doesn't exist
if [ -f "$LOCAL_DIR/config/master.key" ]; then
  echo -e "${YELLOW}Copying master.key to the server...${NC}"
  scp -i $SSH_KEY $LOCAL_DIR/config/master.key $SERVER_USER@$SERVER:$APP_DIR/shared/config/
  ssh -i $SSH_KEY $SERVER_USER@$SERVER "chmod 600 $APP_DIR/shared/config/master.key"
fi

# Copy database.yml to the server if it doesn't exist
if [ ! -f "$APP_DIR/shared/config/database.yml" ]; then
  echo -e "${YELLOW}Creating database.yml on the server...${NC}"
  ssh -i $SSH_KEY $SERVER_USER@$SERVER "cat > $APP_DIR/shared/config/database.yml" << 'EOL'
production:
  adapter: postgresql
  encoding: unicode
  database: aidd_production
  pool: 5
  username: aidd
  password: aidd_password
  host: localhost
EOL
fi

# Sync the application code
echo -e "${YELLOW}Syncing application code...${NC}"
rsync -avz --exclude '.git' --exclude 'log' --exclude 'tmp' --exclude 'config/master.key' --exclude 'config/credentials.yml.enc' --exclude 'storage' --exclude 'node_modules' --exclude '.bundle' -e "ssh -i $SSH_KEY" $LOCAL_DIR/ $SERVER_USER@$SERVER:$APP_DIR/current/

# Create symbolic links
echo -e "${YELLOW}Creating symbolic links...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER "cd $APP_DIR/current && ln -sf $APP_DIR/shared/config/master.key config/master.key && ln -sf $APP_DIR/shared/config/database.yml config/database.yml && ln -sf $APP_DIR/shared/log log && ln -sf $APP_DIR/shared/tmp tmp && ln -sf $APP_DIR/shared/storage storage && ln -sf $APP_DIR/shared/public/system public/system"

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER "cd $APP_DIR/current && RAILS_ENV=production bundle install --without development test"

# Precompile assets
echo -e "${YELLOW}Precompiling assets...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER "cd $APP_DIR/current && RAILS_ENV=production bundle exec rake assets:precompile"

# Run migrations
echo -e "${YELLOW}Running migrations...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER "cd $APP_DIR/current && RAILS_ENV=production bundle exec rake db:migrate"

# Restart the application
echo -e "${YELLOW}Restarting the application...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER "systemctl restart puma"

echo -e "${GREEN}Deployment completed successfully!${NC}"
