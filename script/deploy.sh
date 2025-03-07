#!/bin/bash

# rbenvのセットアップ
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd ~/rails/myapp && \
git pull origin main && \
bundle config set --local without 'development test' && \
bundle install && \
RAILS_ENV=production bundle exec rails assets:precompile && \
RAILS_ENV=production bundle exec rails db:migrate && \
sudo systemctl restart puma 