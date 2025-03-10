require "test_helper"

class JobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # バリデーションのテスト
  test "should not save job without title" do
    company = company_profiles(:one)
    location = locations(:one)
    employment_type = employment_types(:one)
    work_style = work_styles(:one)
    
    job = Job.new(
      description: "仕事の説明",
      company_profile: company,
      location: location,
      employment_type: employment_type,
      work_style: work_style,
      salary: 300000
    )
    
    assert_not job.save, "タイトルなしで求人が保存されました"
  end

  test "should not save job without description" do
    company = company_profiles(:one)
    location = locations(:one)
    employment_type = employment_types(:one)
    work_style = work_styles(:one)
    
    job = Job.new(
      title: "テスト求人",
      company_profile: company,
      location: location,
      employment_type: employment_type,
      work_style: work_style,
      salary: 300000
    )
    
    assert_not job.save, "説明なしで求人が保存されました"
  end

  test "should not save job with non-positive salary" do
    company = company_profiles(:one)
    location = locations(:one)
    employment_type = employment_types(:one)
    work_style = work_styles(:one)
    
    job = Job.new(
      title: "テスト求人",
      description: "仕事の説明",
      company_profile: company,
      location: location,
      employment_type: employment_type,
      work_style: work_style,
      salary: 0
    )
    
    assert_not job.save, "0円の給与で求人が保存されました"
    
    job.salary = -1000
    assert_not job.save, "マイナスの給与で求人が保存されました"
  end

  # 関連付けのテスト
  test "should have job_skills association" do
    job = jobs(:one)
    assert_respond_to job, :job_skills, "求人にはスキルとの関連付けが必要です"
  end

  test "should belong to company_profile" do
    job = jobs(:one)
    assert_respond_to job, :company_profile, "求人には会社プロフィールとの関連付けが必要です"
  end

  test "should belong to location" do
    job = jobs(:one)
    assert_respond_to job, :location, "求人には勤務地との関連付けが必要です"
  end

  test "should belong to employment_type" do
    job = jobs(:one)
    assert_respond_to job, :employment_type, "求人には雇用形態との関連付けが必要です"
  end

  test "should belong to work_style" do
    job = jobs(:one)
    assert_respond_to job, :work_style, "求人には勤務形態との関連付けが必要です"
  end
end
