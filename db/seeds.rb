# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# マスターデータの作成
puts "マスターデータを作成中..."

# 勤務地
locations = ["東京", "大阪", "名古屋", "福岡", "札幌", "仙台", "広島", "沖縄"]
locations.each do |name|
  Location.find_or_create_by!(name: name)
end

# 雇用形態
employment_types = ["正社員", "契約社員", "パート・アルバイト", "派遣社員", "業務委託"]
employment_types.each do |name|
  EmploymentType.find_or_create_by!(name: name)
end

# 勤務形態
work_styles = ["オフィス勤務", "リモートワーク", "ハイブリッド"]
work_styles.each do |name|
  WorkStyle.find_or_create_by!(name: name)
end

# スキル
skill_data = [
  # プログラミング言語
  { name: "Ruby", category: "プログラミング言語", description: "Rubyプログラミング言語" },
  { name: "JavaScript", category: "プログラミング言語", description: "JavaScriptプログラミング言語" },
  { name: "Python", category: "プログラミング言語", description: "Pythonプログラミング言語" },
  { name: "Java", category: "プログラミング言語", description: "Javaプログラミング言語" },
  { name: "PHP", category: "プログラミング言語", description: "PHPプログラミング言語" },
  { name: "TypeScript", category: "プログラミング言語", description: "静的型付けされたJavaScript" },
  { name: "Swift", category: "プログラミング言語", description: "AppleのiOSアプリケーション開発言語" },
  { name: "Kotlin", category: "プログラミング言語", description: "Androidアプリケーション開発言語" },
  { name: "Objective-C", category: "プログラミング言語", description: "AppleのiOSアプリケーション開発に使われていた言語" },

  # フレームワーク
  { name: "Rails", category: "フレームワーク", description: "Ruby on Railsフレームワーク" },
  { name: "React", category: "フレームワーク", description: "ReactJSフロントエンドフレームワーク" },
  { name: "Vue.js", category: "フレームワーク", description: "Vue.jsフロントエンドフレームワーク" },
  { name: "Next.js", category: "フレームワーク", description: "Reactベースのフルスタックフレームワーク" },
  { name: "Angular", category: "フレームワーク", description: "Googleが開発したWeb アプリケーションフレームワーク" },
  { name: "Django", category: "フレームワーク", description: "Pythonの高機能Webフレームワーク" },
  { name: "Flask", category: "フレームワーク", description: "Pythonの軽量Webフレームワーク" },
  { name: "Spring Boot", category: "フレームワーク", description: "Javaベースのアプリケーションフレームワーク" },
  { name: "Laravel", category: "フレームワーク", description: "PHPのMVCフレームワーク" },
  { name: "Express", category: "フレームワーク", description: "Node.js向けWebアプリケーションフレームワーク" },
  { name: ".NET", category: "フレームワーク", description: "Microsoftのアプリケーション開発フレームワーク" },

  # フロントエンド
  { name: "Tailwind CSS", category: "フロントエンド", description: "ユーティリティファーストのCSSフレームワーク" },
  { name: "SCSS/SASS", category: "フロントエンド", description: "CSSのメタ言語" },
  { name: "HTML", category: "フロントエンド", description: "Webページの構造を定義するマークアップ言語" },
  { name: "CSS", category: "フロントエンド", description: "Webページのスタイルを定義する言語" },
  { name: "jQuery", category: "フロントエンド", description: "JavaScriptライブラリ" },
  { name: "Bootstrap", category: "フロントエンド", description: "レスポンシブWebデザイン用CSSフレームワーク" },

  # バックエンド
  { name: "Node.js", category: "バックエンド", description: "JavaScriptランタイム環境" },

  # データベース
  { name: "SQL", category: "データベース", description: "SQL言語" },
  { name: "MySQL", category: "データベース", description: "オープンソースのリレーショナルデータベース" },
  { name: "PostgreSQL", category: "データベース", description: "高機能なオープンソースデータベース" },
  { name: "MongoDB", category: "データベース", description: "ドキュメント指向データベース" },
  { name: "Redis", category: "データベース", description: "インメモリデータベース" },
  { name: "Oracle", category: "データベース", description: "オラクル社の商用リレーショナルデータベース" },
  { name: "DB2", category: "データベース", description: "IBMの商用リレーショナルデータベース" },
  { name: "SQL Server", category: "データベース", description: "Microsoft の商用リレーショナルデータベース" },

  # クラウド
  { name: "AWS", category: "クラウド", description: "Amazon Web Services" },
  { name: "Azure", category: "クラウド", description: "Microsoftのクラウドプラットフォーム" },
  { name: "GCP", category: "クラウド", description: "Google Cloud Platform" },
  { name: "Firebase", category: "クラウド", description: "Googleのモバイル/Webアプリケーション開発プラットフォーム" },

  # インフラ
  { name: "Docker", category: "インフラ", description: "Dockerコンテナ技術" },
  { name: "Kubernetes", category: "インフラ", description: "コンテナオーケストレーションツール" },
  { name: "Terraform", category: "インフラ", description: "インフラストラクチャ・アズ・コード（IaC）ツール" },

  # AI/ML
  { name: "TensorFlow", category: "AI/ML", description: "オープンソース機械学習ライブラリ" },
  { name: "PyTorch", category: "AI/ML", description: "機械学習ライブラリ" },
  { name: "OpenAI API", category: "AI/ML", description: "ChatGPTなどのAIモデルを利用するAPI" },
  { name: "データ分析", category: "AI/ML", description: "データの収集・解析・可視化" },
  { name: "機械学習", category: "AI/ML", description: "機械学習アルゴリズムの設計と実装" },
  { name: "ChatGPT", category: "AI/ML", description: "OpenAIの対話型AIモデル" },
  { name: "プロンプトエンジニアリング", category: "AI/ML", description: "AIモデルから最適な結果を得るためのプロンプト設計" },
  { name: "RAG", category: "AI/ML", description: "検索拡張生成（Retrieval-Augmented Generation）" },
  { name: "LangChain", category: "AI/ML", description: "LLMアプリケーション開発フレームワーク" },
  { name: "ディープラーニング", category: "AI/ML", description: "多層ニューラルネットワークを使用した機械学習手法" },
  { name: "Gemini", category: "AI/ML", description: "Googleが開発した大規模言語モデル" },
  { name: "Claude", category: "AI/ML", description: "Anthropicが開発した大規模言語モデル" },
  { name: "Cursor", category: "AI/ML", description: "AIを活用したコード開発IDE" },
  { name: "Windsurf", category: "AI/ML", description: "コードAIアシスタントツール" },
  { name: "Cline", category: "AI/ML", description: "AIによるコーディング支援ツール" },
  { name: "V0", category: "AI/ML", description: "画像処理に特化したAIモデル" },
  { name: "Bolt.new", category: "AI/ML", description: "高速なAIコーディング支援ツール" },
  { name: "DEVIN", category: "AI/ML", description: "自律型AI開発者エージェント" },
  { name: "REPLIT", category: "AI/ML", description: "AIを搭載したコラボレーティブコーディング環境" },
  { name: "LOVABLE", category: "AI/ML", description: "AIを活用したUI/UX設計ツール" },
  { name: "Kamui", category: "AI/ML", description: "高性能なコード生成AIアシスタント" },
  { name: "Dify", category: "AI/ML", description: "LLMアプリケーション開発プラットフォーム" },
  { name: "StableDiffusion", category: "AI/ML", description: "画像生成AIモデル" },

  # モバイル
  { name: "React Native", category: "モバイル", description: "クロスプラットフォームモバイルアプリケーション開発フレームワーク" },
  { name: "Flutter", category: "モバイル", description: "Googleのクロスプラットフォームフレームワーク" },

  # デザイン
  { name: "UI/UX デザイン", category: "デザイン", description: "ユーザーインターフェース・ユーザーエクスペリエンスデザイン" },
  { name: "Photoshop", category: "デザイン", description: "画像編集ソフトウェア" },
  { name: "Figma", category: "デザイン", description: "UI/UXデザインツール" },

  # API
  { name: "GraphQL", category: "API", description: "APIのためのクエリ言語" },
  { name: "REST API", category: "API", description: "RESTfulなAPI設計・開発" },

  # アーキテクチャ
  { name: "マイクロサービス", category: "アーキテクチャ", description: "マイクロサービスアーキテクチャの設計・開発" },
  { name: "DDD", category: "アーキテクチャ", description: "ドメイン駆動設計（Domain-Driven Design）" },

  # 開発手法
  { name: "Scrum", category: "開発手法", description: "アジャイル開発手法の一つ" },
  { name: "Agile", category: "開発手法", description: "アジャイル開発手法" },

  # 設計
  { name: "システム設計", category: "設計", description: "効率的で拡張性のあるシステム設計" },

  # ツール
  { name: "Git", category: "ツール", description: "Gitバージョン管理" },
  { name: "Webpack", category: "ツール", description: "モジュールバンドラー" },

  # DevOps
  { name: "CI/CD", category: "DevOps", description: "継続的インテグレーション/継続的デリバリー" },

  # マーケティング
  { name: "SEO", category: "マーケティング", description: "検索エンジン最適化技術" },
  { name: "Google Analytics", category: "マーケティング", description: "Webサイト分析ツール" },

  # コミュニケーション
  { name: "Slack", category: "コミュニケーション", description: "ビジネスコミュニケーションツール" },

  # プロジェクト管理
  { name: "JIRA", category: "プロジェクト管理", description: "イシュートラッキングツール" },

  # ドキュメント
  { name: "Confluence", category: "ドキュメント", description: "チームコラボレーションツール" },
  { name: "Notion", category: "ドキュメント", description: "多機能ワークスペースツール" },

  # オフィス
  { name: "Excel", category: "オフィス", description: "表計算ソフト" },
  { name: "PowerPoint", category: "オフィス", description: "プレゼンテーションソフト" },
  { name: "Word", category: "オフィス", description: "ワープロソフト" },

  # OS
  { name: "Linux", category: "OS", description: "オープンソースのオペレーティングシステム" },
  { name: "Windows Server", category: "OS", description: "Microsoftのサーバー向けオペレーティングシステム" }
]

skill_data.each do |data|
  Skill.find_or_create_by!(name: data[:name], category: data[:category]) do |skill|
    skill.description = data[:description]
  end
end

puts "マスターデータ作成完了"
puts "シードデータの作成が完了しました"
