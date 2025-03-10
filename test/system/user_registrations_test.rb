require "application_system_test_case"

class UserRegistrationsTest < ApplicationSystemTestCase
  test "visiting the signup page" do
    visit signup_path
    
    assert_selector "h1", text: "会員登録"
    assert_selector "form"
  end
  
  test "registering a new individual user" do
    visit signup_path
    
    # フォームに入力
    within "form" do
      fill_in "user[user_id]", with: "test_system_user"
      fill_in "user[password]", with: "password123"
      choose "user[user_type]", option: "individual"
      
      click_on "登録する"
    end
    
    # ログインページにリダイレクトされるか確認
    assert_current_path login_path
    assert_text "会員登録が完了しました"
    
    # 登録したユーザーでログイン
    fill_in "user_id", with: "test_system_user"
    fill_in "password", with: "password123"
    click_on "ログイン"
    
    # 個人ユーザーのダッシュボードにリダイレクトされるか確認
    assert_current_path individual_root_path
    assert_text "プロフィール"
  end
  
  test "registering a new company user" do
    visit signup_path
    
    # フォームに入力
    within "form" do
      fill_in "user[user_id]", with: "test_company_user"
      fill_in "user[password]", with: "password123"
      choose "user[user_type]", option: "company"
      
      click_on "登録する"
    end
    
    # ログインページにリダイレクトされるか確認
    assert_current_path login_path
    assert_text "会員登録が完了しました"
    
    # 登録したユーザーでログイン
    fill_in "user_id", with: "test_company_user"
    fill_in "password", with: "password123"
    click_on "ログイン"
    
    # 会社ユーザーのダッシュボードにリダイレクトされるか確認
    assert_current_path company_root_path
    assert_text "プロフィール"
  end
  
  test "trying to register with invalid data" do
    visit signup_path
    
    # 空のフォームを送信
    within "form" do
      click_on "登録する"
    end
    
    # エラーメッセージが表示されるか確認
    assert_text "登録に失敗しました"
    
    # ユーザーIDが空の場合
    within "form" do
      fill_in "user[password]", with: "password123"
      choose "user[user_type]", option: "individual"
      
      click_on "登録する"
    end
    
    # エラーメッセージが表示されるか確認
    assert_text "登録に失敗しました"
  end
end 