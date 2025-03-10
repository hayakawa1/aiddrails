class LegalController < ApplicationController
  # 認証をスキップ（誰でも閲覧可能）
  skip_before_action :require_login, only: [:commerce, :privacy, :terms]
  
  # 特定商取引法に基づく表記
  def commerce
  end
  
  # プライバシーポリシー
  def privacy
  end
  
  # 利用規約
  def terms
  end
end 