class MatchingService
  # 特定の個人ユーザーがマッチする求人を検索
  def self.find_matching_jobs_for_user(user_id)
    user = User.find(user_id)
    
    # 個人ユーザーでない場合は空の配列を返す
    return [] unless user.user_type == "個人"
    
    # 個人プロフィールがない場合は空の配列を返す
    individual_profile = user.individual_profile
    return [] unless individual_profile.present?
    
    # 基本条件でSQL絞り込み：勤務地、雇用形態、勤務形態
    # 希望年収も条件に加える
    matching_jobs = Job.joins(:company_profile)
      .where(location_id: user.user_locations.pluck(:location_id))
      .where(employment_type_id: user.user_employment_types.pluck(:employment_type_id))
      .where(work_style_id: user.user_work_styles.pluck(:work_style_id))
    
    # 年収条件（求人の提示年収 >= 個人の希望年収）
    matching_jobs = matching_jobs.where('salary_min >= ?', individual_profile.desired_salary) if individual_profile.desired_salary.present?
    
    # スキル条件のチェック（Rubyで詳細フィルタリング）
    # ユーザーのスキルとレベルを取得
    user_skills = user.user_skills.includes(:skill).index_by(&:skill_id)
    
    # マッチする求人のみ選択
    matching_jobs.select do |job|
      # 求人のすべてのスキル要件を満たしているか確認
      job_skills = job.job_skills.includes(:skill)
      
      # 求人がスキル要件を持っていない場合はマッチとみなす
      next true if job_skills.empty?
      
      # すべてのスキル要件を満たしているかチェック
      job_skills.all? do |job_skill|
        user_skill = user_skills[job_skill.skill_id]
        # ユーザーがこのスキルを持っており、かつレベルが求人の要求以上であること
        user_skill.present? && user_skill.level >= job_skill.level
      end
    end
  end
  
  # 特定の求人にマッチする個人ユーザーを検索
  def self.find_matching_users_for_job(job_id)
    job = Job.find(job_id)
    
    # 求人が存在しない場合は空の配列を返す
    return [] unless job.present?
    
    # 基本条件でSQL絞り込み：勤務地、雇用形態、勤務形態
    matching_users = User.joins(:user_locations, :user_employment_types, :user_work_styles, :individual_profile)
      .where(user_type: "個人")
      .where(user_locations: { location_id: job.location_id })
      .where(user_employment_types: { employment_type_id: job.employment_type_id })
      .where(user_work_styles: { work_style_id: job.work_style_id })
      .distinct
    
    # 年収条件（求人の提示年収 >= 個人の希望年収）
    if job.salary_min.present?
      matching_users = matching_users.where('individual_profiles.desired_salary <= ? OR individual_profiles.desired_salary IS NULL', job.salary_min)
    end
    
    # 求人のスキル要件を取得
    job_skills = job.job_skills.includes(:skill).index_by(&:skill_id)
    
    # スキル要件がない場合は、ここまでの条件でマッチングOK
    return matching_users if job_skills.empty?
    
    # スキル条件のチェック（Rubyで詳細フィルタリング）
    matching_users.select do |user|
      user_skills = user.user_skills.includes(:skill).index_by(&:skill_id)
      
      # 求人のすべてのスキル要件を満たしているかチェック
      job_skills.values.all? do |job_skill|
        user_skill = user_skills[job_skill.skill_id]
        # ユーザーがこのスキルを持っており、かつレベルが求人の要求以上であること
        user_skill.present? && user_skill.level >= job_skill.level
      end
    end
  end
end 