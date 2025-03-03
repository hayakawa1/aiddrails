#!/bin/bash
# Server setup script for Rails application

# Configuration
APP_NAME="aidd"
APP_DIR="/var/www/$APP_NAME/myapp"
RUBY_VERSION="3.2.7"
RAILS_ENV="production"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting server setup...${NC}"

# Update system packages
echo -e "${YELLOW}Updating system packages...${NC}"
apt-get update
apt-get upgrade -y

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev postgresql postgresql-contrib nginx nodejs yarn git curl

# Install rbenv and ruby-build
echo -e "${YELLOW}Installing rbenv and Ruby...${NC}"
if [ ! -d "$HOME/.rbenv" ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  source ~/.bashrc
fi

# Install Ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION

# Install Bundler
echo -e "${YELLOW}Installing Bundler...${NC}"
gem install bundler

# Create application directories
echo -e "${YELLOW}Creating application directories...${NC}"
mkdir -p $APP_DIR/shared/config $APP_DIR/shared/log $APP_DIR/shared/tmp/pids $APP_DIR/shared/tmp/cache $APP_DIR/shared/tmp/sockets $APP_DIR/shared/public/system $APP_DIR/shared/storage $APP_DIR/current

# Configure Nginx
echo -e "${YELLOW}Configuring Nginx...${NC}"
cat > /etc/nginx/sites-available/$APP_NAME << EOL
server {
    listen 80;
    server_name _;

    root $APP_DIR/current/public;

    access_log $APP_DIR/shared/log/nginx.access.log;
    error_log $APP_DIR/shared/log/nginx.error.log;

    location ^~ /assets/ {
        gzip_static on;
        expires max;
        add_header Cache-Control public;
    }

    location ^~ /packs/ {
        gzip_static on;
        expires max;
        add_header Cache-Control public;
    }

    try_files \$uri/index.html \$uri @puma;
    location @puma {
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
        proxy_pass http://unix:$APP_DIR/shared/tmp/sockets/puma.sock;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 10M;
    keepalive_timeout 10;
}
EOL

ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Configure Puma systemd service
echo -e "${YELLOW}Configuring Puma systemd service...${NC}"
cat > /etc/systemd/system/puma.service << EOL
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR/current
Environment=RAILS_ENV=$RAILS_ENV
Environment=PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$HOME/.rbenv/shims/bundle exec puma -C $APP_DIR/current/config/puma.rb
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable puma

# Create database
echo -e "${YELLOW}Setting up PostgreSQL database...${NC}"
sudo -u postgres psql -c "CREATE DATABASE aidd_production;"
sudo -u postgres psql -c "CREATE USER aidd WITH PASSWORD 'password';"
sudo -u postgres psql -c "ALTER USER aidd WITH SUPERUSER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE aidd_production TO aidd;"

echo -e "${GREEN}Server setup completed successfully!${NC}"
echo -e "${YELLOW}Remember to:${NC}"
echo -e "1. Update the database password in $APP_DIR/shared/config/database.yml"
echo -e "2. Deploy your application code"
echo -e "3. Run database migrations"
