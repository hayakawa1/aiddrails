namespace :matching do
  desc "特定のユーザーIDにマッチする求人を検索する"
  task :find_jobs_for_user, [:user_id] => :environment do |t, args|
    unless args[:user_id].present?
      puts "使用方法: rake matching:find_jobs_for_user[user_id]"
      exit
    end
    
    user_id = args[:user_id].to_i
    begin
      user = User.find(user_id)
      puts "ユーザー #{user.user_id} (ID: #{user.id})のマッチング求人を検索しています..."
      
      matching_jobs = MatchingService.find_matching_jobs_for_user(user_id)
      
      if matching_jobs.empty?
        puts "マッチする求人はありませんでした。"
      else
        puts "マッチする求人が#{matching_jobs.count}件見つかりました："
        
        matching_jobs.each do |job|
          company = job.company_profile.company_name
          puts "---------------------------------------------------"
          puts "求人ID: #{job.id}"
          puts "タイトル: #{job.title}"
          puts "会社名: #{company}"
          puts "勤務地: #{job.location.name}"
          puts "雇用形態: #{job.employment_type.name}"
          puts "勤務形態: #{job.work_style.name}"
          puts "年収: #{job.salary_min}万円"
          
          if job.job_skills.any?
            puts "求めるスキル:"
            job.job_skills.includes(:skill).each do |job_skill|
              puts "  - #{job_skill.skill.name} (レベル#{job_skill.level})"
            end
          end
        end
      end
    rescue ActiveRecord::RecordNotFound
      puts "エラー: ユーザーID #{user_id} は存在しません。"
    end
  end
  
  desc "特定の求人IDにマッチするユーザーを検索する"
  task :find_users_for_job, [:job_id] => :environment do |t, args|
    unless args[:job_id].present?
      puts "使用方法: rake matching:find_users_for_job[job_id]"
      exit
    end
    
    job_id = args[:job_id].to_i
    begin
      job = Job.find(job_id)
      puts "求人「#{job.title}」(ID: #{job.id})にマッチするユーザーを検索しています..."
      
      matching_users = MatchingService.find_matching_users_for_job(job_id)
      
      if matching_users.empty?
        puts "マッチするユーザーはいませんでした。"
      else
        puts "マッチするユーザーが#{matching_users.count}人見つかりました："
        
        matching_users.each do |user|
          profile = user.individual_profile
          puts "---------------------------------------------------"
          puts "ユーザーID: #{user.id}"
          puts "ユーザー名: #{user.user_id}"
          if profile
            puts "表示名: #{profile.display_name}" if profile.display_name.present?
            puts "希望年収: #{profile.desired_salary}万円" if profile.desired_salary.present?
          end
          
          puts "勤務地:"
          user.user_locations.includes(:location).each do |ul|
            puts "  - #{ul.location.name}"
          end
          
          puts "希望雇用形態:"
          user.user_employment_types.includes(:employment_type).each do |uet|
            puts "  - #{uet.employment_type.name}"
          end
          
          puts "希望勤務形態:"
          user.user_work_styles.includes(:work_style).each do |uws|
            puts "  - #{uws.work_style.name}"
          end
          
          if user.user_skills.any?
            puts "スキル:"
            user.user_skills.includes(:skill).each do |user_skill|
              puts "  - #{user_skill.skill.name} (レベル#{user_skill.level})"
            end
          end
        end
      end
    rescue ActiveRecord::RecordNotFound
      puts "エラー: 求人ID #{job_id} は存在しません。"
    end
  end
end 