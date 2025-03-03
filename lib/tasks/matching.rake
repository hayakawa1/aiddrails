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
  
  desc "マッチングプロセスをデバッグするための中間結果を表示する"
  task :debug_matching, [:user_id] => :environment do |t, args|
    unless args[:user_id].present?
      puts "使用方法: rake matching:debug_matching[user_id]"
      exit
    end
    
    user_id = args[:user_id].to_i
    begin
      user = User.find(user_id)
      puts "======================================================="
      puts "ユーザー #{user.user_id} (ID: #{user.id})のマッチングデバッグ"
      puts "======================================================="
      
      puts "\n--- ユーザー情報 ---"
      puts "ユーザータイプ: #{user.user_type}"
      if user.user_type != "個人"
        puts "個人ユーザーでないためマッチング対象外です"
        exit
      end
      
      # 個人プロフィール確認
      individual_profile = user.individual_profile
      puts "個人プロフィール: #{individual_profile.present? ? 'あり' : 'なし'}"
      if individual_profile.blank?
        puts "個人プロフィールがないためマッチング対象外です"
        exit
      end
      
      # 希望条件表示
      puts "\n--- 希望条件 ---"
      location_ids = user.user_locations.pluck(:location_id)
      employment_type_ids = user.user_employment_types.pluck(:employment_type_id)
      work_style_ids = user.user_work_styles.pluck(:work_style_id)
      
      puts "希望勤務地ID: #{location_ids.join(', ')}"
      puts "希望雇用形態ID: #{employment_type_ids.join(', ')}"
      puts "希望勤務形態ID: #{work_style_ids.join(', ')}"
      puts "希望年収: #{individual_profile.desired_salary.present? ? "#{individual_profile.desired_salary}万円" : '未設定'}"
      
      # ユーザースキル表示
      user_skills = user.user_skills.includes(:skill)
      puts "\n--- ユーザースキル情報 (#{user_skills.count}件) ---"
      if user_skills.any?
        user_skills.each do |skill|
          puts "- #{skill.skill.name} (レベル#{skill.level})"
        end
      else
        puts "登録スキルなし"
      end
      
      # マッチング検証（ステップごと）
      puts "\n--- 条件ごとのマッチング結果 ---"
      
      # すべての求人
      all_jobs = Job.all
      puts "求人総数: #{all_jobs.count}件"
      
      # 1. 勤務地のみでマッチング
      location_jobs = all_jobs.where(location_id: location_ids)
      puts "勤務地条件のみ: #{location_jobs.count}件"
      if location_jobs.empty?
        puts "  勤務地条件でマッチする求人がありません。希望勤務地の設定を確認してください。"
      else
        puts "  マッチした求人ID: #{location_jobs.pluck(:id).join(', ')}"
      end
      
      # 2. 雇用形態のみでマッチング
      employment_jobs = all_jobs.where(employment_type_id: employment_type_ids)
      puts "雇用形態条件のみ: #{employment_jobs.count}件"
      if employment_jobs.empty?
        puts "  雇用形態条件でマッチする求人がありません。希望雇用形態の設定を確認してください。"
      else
        puts "  マッチした求人ID: #{employment_jobs.pluck(:id).join(', ')}"
      end
      
      # 3. 勤務形態のみでマッチング
      work_style_jobs = all_jobs.where(work_style_id: work_style_ids)
      puts "勤務形態条件のみ: #{work_style_jobs.count}件"
      if work_style_jobs.empty?
        puts "  勤務形態条件でマッチする求人がありません。希望勤務形態の設定を確認してください。"
      else
        puts "  マッチした求人ID: #{work_style_jobs.pluck(:id).join(', ')}"
      end
      
      # 4. 勤務地+雇用形態+勤務形態
      basic_jobs = all_jobs
        .where(location_id: location_ids)
        .where(employment_type_id: employment_type_ids)
        .where(work_style_id: work_style_ids)
      puts "基本条件（勤務地+雇用形態+勤務形態）: #{basic_jobs.count}件"
      if basic_jobs.empty?
        puts "  基本条件を満たす求人がありません。希望条件の組み合わせを確認してください。"
      else
        puts "  マッチした求人ID: #{basic_jobs.pluck(:id).join(', ')}"
      end
      
      # 5. 年収条件を加える
      if individual_profile.desired_salary.present?
        salary_jobs = basic_jobs.where('salary_min >= ?', individual_profile.desired_salary)
        puts "基本条件＋年収条件: #{salary_jobs.count}件"
        if salary_jobs.empty?
          puts "  年収条件を満たす求人がありません。希望年収の設定を確認してください。"
        else
          puts "  マッチした求人ID: #{salary_jobs.pluck(:id).join(', ')}"
        end
      else
        salary_jobs = basic_jobs
        puts "年収条件: 未設定のため基本条件と同じ"
      end
      
      # 6. スキル条件のチェック
      if user_skills.empty?
        puts "ユーザースキルが未設定のため、スキル条件はチェックしません"
        final_matching = salary_jobs
      else
        puts "\n--- スキル条件の詳細チェック ---"
        skill_matched_jobs = []
        
        salary_jobs.each do |job|
          puts "\n求人ID: #{job.id}, タイトル: #{job.title}"
          job_skills = job.job_skills.includes(:skill)
          
          if job_skills.empty?
            puts "  スキル要件なし → マッチ"
            skill_matched_jobs << job
            next
          end
          
          puts "  求めるスキル:"
          all_matched = true
          
          job_skills.each do |job_skill|
            user_skill = user_skills.find { |s| s.skill_id == job_skill.skill_id }
            if user_skill.present?
              if user_skill.level >= job_skill.level
                puts "  - #{job_skill.skill.name}: 求人Lv#{job_skill.level} <= ユーザーLv#{user_skill.level} → マッチ"
              else
                puts "  - #{job_skill.skill.name}: 求人Lv#{job_skill.level} > ユーザーLv#{user_skill.level} → 不一致"
                all_matched = false
              end
            else
              puts "  - #{job_skill.skill.name}: ユーザーが持っていないスキル → 不一致"
              all_matched = false
            end
          end
          
          if all_matched
            puts "  すべてのスキル要件を満たしています → マッチ"
            skill_matched_jobs << job
          else
            puts "  一部のスキル要件を満たしていません → 不一致"
          end
        end
        
        final_matching = skill_matched_jobs
        puts "\nスキル条件を含む最終マッチング結果: #{final_matching.count}件"
        if final_matching.any?
          puts "マッチした求人ID: #{final_matching.pluck(:id).join(', ')}"
        end
      end
      
      puts "\n======================================================="
      puts "マッチングデバッグ完了"
      puts "======================================================="
      
    rescue ActiveRecord::RecordNotFound
      puts "エラー: ユーザーID #{user_id} は存在しません。"
    end
  end
end 