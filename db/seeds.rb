# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 勤務地のマスターデータ
locations = [
  { name: "東京", description: "東京都内" },
  { name: "大阪", description: "大阪府内" },
  { name: "名古屋", description: "愛知県名古屋市内" },
  { name: "福岡", description: "福岡県内" },
  { name: "札幌", description: "北海道札幌市内" },
  { name: "仙台", description: "宮城県仙台市内" },
  { name: "広島", description: "広島県内" },
  { name: "神奈川", description: "神奈川県内" },
  { name: "埼玉", description: "埼玉県内" },
  { name: "千葉", description: "千葉県内" }
]

locations.each do |location|
  Location.find_or_create_by!(name: location[:name]) do |loc|
    loc.description = location[:description]
  end
end

puts "勤務地マスターデータを作成しました"

# 雇用形態のマスターデータ
employment_types = [
  { name: "正社員", description: "無期雇用の正社員" },
  { name: "契約社員", description: "有期雇用の契約社員" },
  { name: "業務委託", description: "個人事業主としての業務委託" },
  { name: "パートタイム", description: "時短勤務のパート" },
  { name: "インターン", description: "学生向けインターンシップ" }
]

employment_types.each do |employment_type|
  EmploymentType.find_or_create_by!(name: employment_type[:name]) do |et|
    et.description = employment_type[:description]
  end
end

puts "雇用形態マスターデータを作成しました"

# 勤務形態のマスターデータ
work_styles = [
  { name: "フルリモート", description: "100%リモートワーク" },
  { name: "ハイブリッド", description: "週2〜3日出社、他はリモート" },
  { name: "完全出社", description: "オフィスでの勤務" },
  { name: "フレックス", description: "フレックスタイム制度あり" },
  { name: "時短勤務", description: "時短勤務可能" }
]

work_styles.each do |work_style|
  WorkStyle.find_or_create_by!(name: work_style[:name]) do |ws|
    ws.description = work_style[:description]
  end
end

puts "勤務形態マスターデータを作成しました"

# スキルのマスターデータ
skills = [
  { category: "Java", description: "Javaプログラミング（Spring Boot等）" },
  { category: "Ruby", description: "Rubyプログラミング（Ruby on Rails等）" },
  { category: "Python", description: "Pythonプログラミング（Django, Flask等）" },
  { category: "PHP", description: "PHPプログラミング（Laravel, CakePHP等）" },
  { category: "JavaScript", description: "JavaScript/TypeScript（React, Vue, Angular等）" },
  { category: "C#", description: "C#プログラミング（.NET等）" },
  { category: "Go", description: "Go言語プログラミング" },
  { category: "Swift", description: "iOS/Macアプリ開発" },
  { category: "Kotlin", description: "Androidアプリ開発" },
  { category: "SQL", description: "SQLデータベース（MySQL, PostgreSQL等）" },
  { category: "AWS", description: "AWSクラウド環境構築・運用" },
  { category: "Azure", description: "Microsoftクラウド環境構築・運用" },
  { category: "GCP", description: "Googleクラウド環境構築・運用" },
  { category: "Docker", description: "Docker/コンテナ技術" },
  { category: "Kubernetes", description: "Kubernetesによるコンテナオーケストレーション" },
  { category: "Linux", description: "Linux環境の構築・運用" },
  { category: "ネットワーク", description: "ネットワーク設計・構築" },
  { category: "セキュリティ", description: "情報セキュリティ対策・運用" },
  { category: "機械学習", description: "機械学習/AI技術" },
  { category: "データ分析", description: "ビッグデータ解析・分析" }
]

skills.each do |skill|
  Skill.find_or_create_by!(category: skill[:category]) do |s|
    s.name = skill[:category]
    s.description = skill[:description]
  end
end

puts "スキルマスターデータを作成しました"
