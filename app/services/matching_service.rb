class MatchingService
  # 個人ユーザーに一致する求人を検索
  def self.find_matching_jobs_for_user(user_id)
    user = User.find(user_id)
    individual_profile = user.individual_profile
    
    return [] unless individual_profile
    
    # 基本的なクエリの構築
    matching_jobs = Job.active
    
    # 必須条件でフィルタリング
    # 勤務地のマッチング
    if individual_profile.respond_to?(:location_id) && individual_profile.location_id.present?
      matching_jobs = matching_jobs.where(location_id: individual_profile.location_id)
    end
    
    # 雇用形態のマッチング
    if individual_profile.respond_to?(:employment_type_id) && individual_profile.employment_type_id.present?
      matching_jobs = matching_jobs.where(employment_type_id: individual_profile.employment_type_id)
    end
    
    # 勤務形態のマッチング
    if individual_profile.respond_to?(:work_style_id) && individual_profile.work_style_id.present?
      matching_jobs = matching_jobs.where(work_style_id: individual_profile.work_style_id)
    end
    
    # 給与のマッチング（希望給与以上の求人のみ）
    if individual_profile.desired_salary.present?
      matching_jobs = matching_jobs.where('salary >= ?', individual_profile.desired_salary)
    end
    
    # スキルのマッチング
    # ユーザーが持つスキルをすべて取得
    user_skills = user.user_skills.includes(:skill)
    
    if user_skills.any?
      user_skill_ids = user_skills.map(&:skill_id)
      user_skill_levels = user_skills.map { |us| [us.skill_id, us.level] }.to_h
      
      # サブクエリで各求人のスキル要件がユーザーのスキルを満たしているか確認
      matching_jobs = matching_jobs.joins(:job_skills)
                       .where(job_skills: { skill_id: user_skill_ids })
                       .group('jobs.id')
                       .having('COUNT(DISTINCT job_skills.skill_id) = COUNT(DISTINCT CASE WHEN job_skills.level <= ? THEN job_skills.skill_id END)', 
                               user_skills.minimum(:level))
    end
    
    matching_jobs
  end
  
  # 求人に一致する個人ユーザーを検索
  def self.find_matching_users_for_job(job_id)
    job = Job.find(job_id)
    
    # 基本的なクエリの構築 - 個人ユーザーのみを対象
    matching_users = User.joins(:individual_profile).where.not(individual_profile: nil)
    
    # 必須条件でフィルタリング
    # 勤務地のマッチング
    if job.location_id.present?
      # location_idカラムが存在するか確認
      if ActiveRecord::Base.connection.column_exists?(:individual_profiles, :location_id)
        matching_users = matching_users.where(individual_profiles: { location_id: job.location_id })
      end
    end
    
    # 雇用形態のマッチング
    if job.employment_type_id.present?
      # employment_type_idカラムが存在するか確認
      if ActiveRecord::Base.connection.column_exists?(:individual_profiles, :employment_type_id)
        matching_users = matching_users.where(individual_profiles: { employment_type_id: job.employment_type_id })
      end
    end
    
    # 勤務形態のマッチング
    if job.work_style_id.present?
      # work_style_idカラムが存在するか確認
      if ActiveRecord::Base.connection.column_exists?(:individual_profiles, :work_style_id)
        matching_users = matching_users.where(individual_profiles: { work_style_id: job.work_style_id })
      end
    end
    
    # 給与のマッチング（求人の給与が希望給与以上）
    matching_users = matching_users.where('individual_profiles.desired_salary <= ?', job.salary)
    
    # スキルのマッチング
    job_skills = job.job_skills.includes(:skill)
    
    if job_skills.any?
      job_skill_ids = job_skills.map(&:skill_id)
      job_skill_levels = job_skills.map { |js| [js.skill_id, js.level] }.to_h
      
      # ユーザーが求人の必要なスキルを全て持っているか確認
      matching_users = matching_users.joins(:user_skills)
                      .where(user_skills: { skill_id: job_skill_ids })
                      .group('users.id')
                      .having('COUNT(DISTINCT user_skills.skill_id) = COUNT(DISTINCT CASE WHEN user_skills.level >= ? THEN user_skills.skill_id END)',
                             job_skills.minimum(:level))
    end
    
    matching_users
  end
  
  # 両方向からのマッチングが一致しているかを確認するメソッド
  def self.is_mutual_match(user_id, job_id)
    job_matches_user = find_matching_jobs_for_user(user_id).where(id: job_id).exists?
    user_matches_job = find_matching_users_for_job(job_id).where(id: user_id).exists?
    
    job_matches_user && user_matches_job
  end
  
  # 相互マッチしているユーザーと求人の組み合わせを取得
  def self.get_mutual_matches_for_user(user_id)
    matching_jobs = find_matching_jobs_for_user(user_id)
    
    # 相互マッチしている求人のみをフィルタリング
    mutual_matches = matching_jobs.select do |job|
      find_matching_users_for_job(job.id).where(id: user_id).exists?
    end
    
    mutual_matches
  end
  
  # 相互マッチしているユーザーを求人IDから取得
  def self.get_mutual_matches_for_job(job_id)
    matching_users = find_matching_users_for_job(job_id)
    
    # 相互マッチしているユーザーのみをフィルタリング
    mutual_matches = matching_users.select do |user|
      find_matching_jobs_for_user(user.id).where(id: job_id).exists?
    end
    
    mutual_matches
  end

  # マッチングスコアを計算するメソッド
  def self.calculate_matching_score(user_id, job_id)
    user = User.find(user_id)
    job = Job.find(job_id)
    individual_profile = user.individual_profile
    
    # デフォルトのスコア
    condition_match_score = 0
    skill_match_score = 0
    
    # 条件マッチスコアの計算（最大50点）
    max_condition_score = 50
    condition_matches = 0
    total_conditions = 0
    
    # 勤務地のマッチング（10点）
    if job.location_id.present? && individual_profile.respond_to?(:location_id) && individual_profile.location_id.present?
      total_conditions += 1
      if job.location_id == individual_profile.location_id
        condition_matches += 1
      end
    end
    
    # 雇用形態のマッチング（10点）
    if job.employment_type_id.present? && individual_profile.respond_to?(:employment_type_id) && individual_profile.employment_type_id.present?
      total_conditions += 1
      if job.employment_type_id == individual_profile.employment_type_id
        condition_matches += 1
      end
    end
    
    # 勤務形態のマッチング（10点）
    if job.work_style_id.present? && individual_profile.respond_to?(:work_style_id) && individual_profile.work_style_id.present?
      total_conditions += 1
      if job.work_style_id == individual_profile.work_style_id
        condition_matches += 1
      end
    end
    
    # 給与のマッチング（10点）- 求人の給与が希望給与以上
    if job.salary.present? && individual_profile.desired_salary.present?
      total_conditions += 1
      if job.salary >= individual_profile.desired_salary
        condition_matches += 1
      end
    end
    
    # 条件スコアの計算（該当条件数に応じて配点）
    condition_match_score = total_conditions > 0 ? (condition_matches.to_f / total_conditions * max_condition_score).round : 0
    
    # スキルマッチスコアの計算（最大50点）
    max_skill_score = 50
    
    # 求人が要求するスキル
    job_skills = job.job_skills.includes(:skill)
    user_skills = user.user_skills.includes(:skill)
    
    if job_skills.any? && user_skills.any?
      # ユーザーのスキルをハッシュマップで取得
      user_skill_map = user_skills.map { |us| [us.skill_id, us.level] }.to_h
      
      # 各求人スキルについてマッチング度を評価
      total_skill_points = 0
      max_possible_points = 0
      
      job_skills.each do |job_skill|
        required_level = job_skill.level
        user_level = user_skill_map[job_skill.skill_id] || 0
        
        # 各スキルの最大ポイント
        skill_max_points = 10 
        max_possible_points += skill_max_points
        
        # ユーザーのスキルレベルが求人の要求レベル以上であれば満点
        if user_level >= required_level
          total_skill_points += skill_max_points
        elsif user_level > 0
          # レベルが低い場合は部分的にポイント加算
          match_percentage = user_level.to_f / required_level
          total_skill_points += (skill_max_points * match_percentage).round
        end
      end
      
      # スキルスコアの計算
      skill_match_score = max_possible_points > 0 ? (total_skill_points.to_f / max_possible_points * max_skill_score).round : 0
    end
    
    # 総合スコア
    total_score = condition_match_score + skill_match_score
    
    {
      total_score: total_score,
      condition_match_score: condition_match_score,
      skill_match_score: skill_match_score
    }
  end
end 