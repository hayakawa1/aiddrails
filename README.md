# AIDD.WORK - Job Matching Platform

AIDD.WORK is a job matching platform built with Ruby on Rails.

## System Requirements

* Ruby 3.2.7
* Rails 8.0.1
* PostgreSQL 14
* Node.js & Yarn

## Development Setup

```bash
# Clone the repository
git clone https://github.com/hayakawa1/aiddrails.git
cd aiddrails

# Install dependencies
bundle install
yarn install

# Setup database
rails db:create db:migrate db:seed

# Start the server
rails server
```

## Deployment

This application is configured for automated deployment using GitHub Actions and Capistrano.

### Prerequisites

1. A server with the following installed:
   - Ruby 3.2.7 (via rbenv)
   - PostgreSQL 14
   - Nginx
   - Node.js & Yarn

2. GitHub repository with the following secrets configured:
   - `SSH_PRIVATE_KEY`: SSH private key for server access
   - `KNOWN_HOSTS`: Server SSH fingerprints
   - `RAILS_MASTER_KEY`: Rails master key from `config/master.key`

### Deployment Process

1. Push changes to the `main` branch
2. GitHub Actions will automatically deploy to production
3. Alternatively, you can manually trigger the deployment from the Actions tab

### Manual Deployment

If you need to deploy manually without GitHub Actions:

#### Option 1: Using Capistrano

```bash
# From your local machine
bundle exec cap production deploy
```

#### Option 2: Using rsync (Simpler Alternative)

A simpler deployment option using rsync is available:

```bash
# From your local machine
./deployment_configs/deploy_rsync.sh
```

This script will:
1. Create necessary directories on the server
2. Copy configuration files
3. Sync application code
4. Install dependencies
5. Precompile assets
6. Run database migrations
7. Restart the application

#### Option 3: Super Simple SSH Deployment

The simplest deployment option using SSH and Git:

```bash
# Using SSH key authentication
./deployment_configs/simple_deploy.sh

# Using password authentication (requires sshpass)
./deployment_configs/sshpass_deploy.sh

# Complete workflow with commit, push and deploy (requires sshpass)
./deployment_configs/commit_push_deploy.sh
```

This minimal approach will:
1. SSH into the server
2. Pull the latest code from Git
3. Install dependencies
4. Precompile assets
5. Run migrations
6. Restart the Rails application

The `commit_push_deploy.sh` script additionally:
1. Commits your local changes with a custom message
2. Pushes to your remote Git repository
3. Then performs the server deployment

For first-time server setup:

```bash
# Run this on the server
./deployment_configs/server_setup.sh
```

### Server Setup

For initial server setup, see the documentation in `deployment_configs/README.md`

## Database Management

Automated database backups are configured via the script at `deployment_configs/pg_backup.sh`

To manually backup the database:

```bash
bundle exec cap production db:backup
```

## Monitoring

To check application logs:

```bash
bundle exec cap production logs:rails       # Rails application logs
bundle exec cap production logs:puma        # Puma server logs
bundle exec cap production logs:nginx       # Nginx logs
bundle exec cap production logs:systemd     # Systemd service logs
```

## Security

Never commit sensitive information such as API keys, database credentials, or the Rails master key to the repository. Use environment variables or Rails credentials for sensitive information.

