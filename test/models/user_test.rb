require "test_helper"

class UserTest < ActiveSupport::TestCase
  # バリデーションのテスト
  test "should not save user without user_id" do
    user = User.new(password: "password123", user_type: "individual")
    assert_not user.save, "ユーザーIDなしでユーザーが保存されました"
  end

  test "should not save user without password" do
    user = User.new(user_id: "test_user", user_type: "individual")
    assert_not user.save, "パスワードなしでユーザーが保存されました"
  end

  test "should not save user without user_type" do
    user = User.new(user_id: "test_user", password: "password123")
    assert_not user.save, "ユーザータイプなしでユーザーが保存されました"
  end

  test "should not save user with duplicate user_id" do
    User.create(user_id: "test_user", password: "password123", user_type: "individual")
    user = User.new(user_id: "test_user", password: "different_password", user_type: "company")
    assert_not user.save, "重複するユーザーIDでユーザーが保存されました"
  end

  # 認証機能のテスト
  test "should authenticate user with correct password" do
    user = User.create(user_id: "test_auth", password: "correct_password", user_type: "individual")
    assert user.authenticate("correct_password"), "正しいパスワードで認証に失敗しました"
  end

  test "should not authenticate user with incorrect password" do
    user = User.create(user_id: "test_auth", password: "correct_password", user_type: "individual")
    assert_not user.authenticate("wrong_password"), "誤ったパスワードで認証に成功しました"
  end

  # 関連付けのテスト
  test "should destroy associated profiles when user is destroyed" do
    user = User.create(user_id: "test_associations", password: "password123", user_type: "individual")
    
    # 個人プロフィールを作成
    user.create_individual_profile(
      display_name: "テスト太郎", 
      birth_year: 1990, 
      bio: "テストプロフィール"
    )
    
    assert_difference('IndividualProfile.count', -1) do
      user.destroy
    end
  end
end
