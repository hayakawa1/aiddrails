#!/bin/bash

# rbenvのセットアップ
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# データベース設定
export RAILS_ENV=production
export DATABASE_URL="postgres://ubuntu:ubuntu@localhost/ubuntu_production"

cd ~/rails/myapp && \
git pull origin main && \
bundle config set --local without 'development test' && \
bundle install && \
bundle exec rails assets:precompile && \
bundle exec rails db:migrate && \
systemctl restart puma 