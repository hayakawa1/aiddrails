ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# テスト環境でのみ使用するモックユーザーを作成
class MockUser
  attr_accessor :id, :user_id, :user_type
  
  def initialize(id, user_id, user_type)
    @id = id
    @user_id = user_id
    @user_type = user_type
  end
end

# ApplicationControllerをモンキーパッチ
ApplicationController.class_eval do
  # ログインしていない場合はログインページにリダイレクト
  def require_login
    # テスト環境では認証をスキップ
    return true
  end
  
  # 現在ログインしているユーザーを取得
  def current_user
    # テスト環境ではモックユーザーを返す
    @current_user ||= MockUser.new(1, "test_user", "個人")
  end
  
  # ユーザーがログインしているかどうかを確認
  def logged_in?
    # テスト環境では常にtrueを返す
    return true
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module SignInHelper
  # 個人ユーザーとしてログイン
  def sign_in_as_individual(user)
    post login_path, params: { session: { user_id: user.user_id, password: user.password } }
  end

  # 会社ユーザーとしてログイン
  def sign_in_as_company(user)
    post login_path, params: { session: { user_id: user.user_id, password: user.password } }
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
