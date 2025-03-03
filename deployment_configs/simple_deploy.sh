#!/bin/bash
# Simple deployment script using SSH and Git

# Configuration
SERVER="45.76.194.174"
SERVER_USER="root"
APP_DIR="/var/www/aidd/myapp/current"
SSH_KEY="$HOME/.ssh/aidd_deploy"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting simple deployment...${NC}"

# SSH to server, pull latest code, install dependencies, and restart Rails
ssh -i $SSH_KEY $SERVER_USER@$SERVER << 'EOL'
  cd /var/www/aidd/myapp/current
  
  # Pull latest code
  echo "Pulling latest code from repository..."
  git pull origin main
  
  # Setup Ruby environment
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$($HOME/.rbenv/bin/rbenv init -)"
  
  # Install dependencies
  echo "Installing dependencies..."
  bundle install --without development test
  
  # Precompile assets if needed
  echo "Precompiling assets..."
  RAILS_ENV=production bundle exec rake assets:precompile
  
  # Run migrations
  echo "Running migrations..."
  RAILS_ENV=production bundle exec rake db:migrate
  
  # Restart Rails application
  echo "Restarting Rails application..."
  systemctl restart puma
  
  # Check status
  echo "Checking service status..."
  systemctl status puma --no-pager
EOL

echo -e "${GREEN}Deployment completed!${NC}"
