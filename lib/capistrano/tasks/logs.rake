namespace :logs do
  desc 'Tail production logs'
  task :tail do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/production.log"
    end
  end

  desc 'Show puma logs'
  task :puma do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/puma_access.log #{shared_path}/log/puma_error.log"
    end
  end

  desc 'Show nginx logs'
  task :nginx do
    on roles(:web) do
      execute "tail -f /var/log/nginx/access.log /var/log/nginx/error.log"
    end
  end

  desc 'Show systemd puma service logs'
  task :systemd do
    on roles(:app) do
      execute "journalctl -u puma -f"
    end
  end
end
