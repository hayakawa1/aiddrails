namespace :db do
  desc 'Create a database backup'
  task :backup do
    on roles(:db) do
      within current_path do
        execute :mkdir, '-p', "#{shared_path}/db_backups"
        backup_path = "#{shared_path}/db_backups/backup_#{Time.now.strftime('%Y%m%d%H%M%S')}.sql"
        execute :pg_dump, "-U postgres -h localhost myapp_production > #{backup_path}"
        execute :gzip, backup_path
        puts "Database backup created at #{backup_path}.gz"
      end
    end
  end

  desc 'Download the latest database backup'
  task :download do
    on roles(:db) do
      within current_path do
        latest_backup = capture("ls -t #{shared_path}/db_backups/*.gz | head -n 1").strip
        if latest_backup.empty?
          puts "No backups found"
        else
          download! latest_backup, "db_backups/#{File.basename(latest_backup)}"
          puts "Downloaded #{latest_backup} to db_backups/#{File.basename(latest_backup)}"
        end
      end
    end
  end
end
