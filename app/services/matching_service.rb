class MatchingService
  # 個人ユーザーに一致する求人を検索
  def self.find_matching_jobs_for_user(user_id)
    user = User.find(user_id)
    individual_profile = user.individual_profile
    
    return [] unless individual_profile
    
    # 基本的なクエリの構築
    jobs = Job.active
    
    # カラムがない場合はフィルタリングをスキップ
    # 希望勤務地でフィルタリング
    if individual_profile.respond_to?(:location_id) && individual_profile.location_id.present?
      jobs = jobs.where(location_id: individual_profile.location_id)
    end
    
    # 希望雇用形態でフィルタリング
    if individual_profile.respond_to?(:employment_type_id) && individual_profile.employment_type_id.present?
      jobs = jobs.where(employment_type_id: individual_profile.employment_type_id)
    end
    
    # 希望勤務形態でフィルタリング
    if individual_profile.respond_to?(:work_style_id) && individual_profile.work_style_id.present?
      jobs = jobs.where(work_style_id: individual_profile.work_style_id)
    end
    
    # 希望年収でフィルタリング
    if individual_profile.desired_salary.present?
      jobs = jobs.where('salary_min >= ?', individual_profile.desired_salary * 0.9)
    end
    
    # ユーザーのスキルレベル以下の求人を選択
    user_skills = user.user_skills.includes(:skill)
    if user_skills.any?
      skill_ids = user_skills.map(&:skill_id)
      min_level = user_skills.minimum(:level)
      
      jobs = jobs.joins(:job_skills)
                 .where(job_skills: { skill_id: skill_ids })
                 .where('job_skills.level <= ?', min_level)
                 .group('jobs.id')
                 .having('COUNT(DISTINCT job_skills.skill_id) >= ?', skill_ids.size / 2)
    end
    
    # 求人ごとのマッチングスコアを計算して降順にソート
    jobs_with_scores = jobs.map do |job|
      {
        job: job,
        score: calculate_matching_score(user_id, job.id)[:total_score]
      }
    end
    
    # スコアで降順ソート（高いスコアが上位に来るように）
    jobs_with_scores.sort_by { |job_data| -job_data[:score] }.map { |job_data| job_data[:job] }
  end
  
  # 求人に一致する個人ユーザーを検索
  def self.find_matching_users_for_job(job_id)
    job = Job.find(job_id)
    
    # 基本的なクエリの構築 - 個人ユーザーのみを対象
    users = User.joins(:individual_profile).where.not(individual_profile: nil)
    
    # individual_profilesテーブルにカラムがあるか確認し、フィルタリング
    # 勤務地でフィルタリング
    if job.location_id.present?
      # location_idカラムが存在するか確認
      if ActiveRecord::Base.connection.column_exists?(:individual_profiles, :location_id)
        users = users.where(individual_profiles: { location_id: job.location_id })
      end
    end
    
    # 雇用形態でフィルタリング
    if job.employment_type_id.present?
      # employment_type_idカラムが存在するか確認
      if ActiveRecord::Base.connection.column_exists?(:individual_profiles, :employment_type_id)
        users = users.where(individual_profiles: { employment_type_id: job.employment_type_id })
      end
    end
    
    # 勤務形態でフィルタリング
    if job.work_style_id.present?
      # work_style_idカラムが存在するか確認
      if ActiveRecord::Base.connection.column_exists?(:individual_profiles, :work_style_id)
        users = users.where(individual_profiles: { work_style_id: job.work_style_id })
      end
    end
    
    # 給与でフィルタリング
    if job.salary_min.present?
      users = users.where('individual_profiles.desired_salary <= ?', job.salary_min * 1.1)
    end
    
    # 求人が要求するスキルを持つユーザーをフィルタリング
    job_skills = job.job_skills.includes(:skill)
    
    if job_skills.any?
      required_skill_ids = job_skills.map(&:skill_id)
      
      users = users.joins(:user_skills)
                   .where(user_skills: { skill_id: required_skill_ids })
                   .where('user_skills.level >= ?', job_skills.minimum(:level))
                   .group('users.id')
                   .having('COUNT(DISTINCT user_skills.skill_id) >= ?', required_skill_ids.size / 2)
    end
    
    # ユーザーごとのマッチングスコアを計算して降順にソート
    users_with_scores = users.map do |user|
      {
        user: user,
        score: calculate_matching_score(user.id, job_id)[:total_score]
      }
    end
    
    # スコアで降順ソート（高いスコアが上位に来るように）
    users_with_scores.sort_by { |user_data| -user_data[:score] }.map { |user_data| user_data[:user] }
  end
  
  # マッチングスコアを計算するメソッド
  def self.calculate_matching_score(user_id, job_id)
    user = User.find(user_id)
    job = Job.find(job_id)
    individual_profile = user.individual_profile
    
    # 条件マッチスコア（50点満点）
    condition_score = 0
    
    # 勤務地のマッチ（10点）
    if individual_profile.respond_to?(:location_id) && individual_profile.location_id.present? && job.location_id.present?
      condition_score += 10 if individual_profile.location_id == job.location_id
    end
    
    # 雇用形態のマッチ（10点）
    if individual_profile.respond_to?(:employment_type_id) && individual_profile.employment_type_id.present? && job.employment_type_id.present?
      condition_score += 10 if individual_profile.employment_type_id == job.employment_type_id
    end
    
    # 勤務形態のマッチ（10点）
    if individual_profile.respond_to?(:work_style_id) && individual_profile.work_style_id.present? && job.work_style_id.present?
      condition_score += 10 if individual_profile.work_style_id == job.work_style_id
    end
    
    # 給与のマッチ（20点）
    if individual_profile.desired_salary.present? && job.salary_min.present?
      salary_ratio = job.salary_min.to_f / individual_profile.desired_salary.to_f
      if salary_ratio >= 0.9 && salary_ratio <= 1.1
        condition_score += 20
      elsif salary_ratio >= 0.8 && salary_ratio <= 1.2
        condition_score += 10
      end
    end
    
    # 条件マッチスコアを50点満点に正規化
    condition_match_score = condition_score.to_f / 50.0 * 100
    
    # スキルマッチスコア（50点満点）
    skill_score = 0
    total_skill_weight = 0
    
    # ユーザースキルと求人スキルを比較
    job.job_skills.each do |job_skill|
      user_skill = user.user_skills.find_by(skill_id: job_skill.skill_id)
      if user_skill
        skill_weight = job_skill.level * 2 # スキルレベルに応じた重み付け
        total_skill_weight += skill_weight
        
        # ユーザーのスキルレベルが求人のスキルレベル以上なら満点、そうでなければ比率で点数を付ける
        if user_skill.level >= job_skill.level
          skill_score += skill_weight
        else
          skill_score += skill_weight * (user_skill.level.to_f / job_skill.level.to_f)
        end
      end
    end
    
    # 求人のスキル要件がない場合は満点とする
    skill_match_score = total_skill_weight > 0 ? (skill_score / total_skill_weight * 100) : 100
    
    # 総合スコア（条件50%、スキル50%）
    total_score = (condition_match_score * 0.5 + skill_match_score * 0.5).round
    
    {
      total_score: total_score,
      condition_match_score: condition_match_score.round,
      skill_match_score: skill_match_score.round
    }
  end
end 