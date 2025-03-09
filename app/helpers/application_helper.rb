module ApplicationHelper
  # 簡潔なレベル説明（ドロップダウン用）
  def level_description(level)
    case level
    when 1
      "基礎知識あり"
    when 2
      "業務経験あり"
    when 3
      "一人で実務可能"
    when 4
      "高度な業務経験あり"
    when 5
      "エキスパート"
    else
      ""
    end
  end
  
  # レベルの詳細説明
  def level_detailed_description(level)
    case level
    when 1
      "その技術について業務経験が無いかまたは少ない。スクールや独学で学んだ。業務ではサポートが必要。"
    when 2
      "その技術について簡単な業務なら独力でできる。複雑な作業なら指示や指導が必要。個人開発で収益化している。"
    when 3
      "その技術について複雑な作業を単独でできる。その技術について初心者等を指導することができる。"
    when 4
      "その技術について社内の相談役になることができる程度に精通している。"
    when 5
      "その技術自体の内部構造まで理解している。OSSならコミッターレベルに達している。"
    else
      ""
    end
  end
  
  # スキルレベル目安の配列を取得
  def skill_level_definitions
    (1..5).map do |level|
      {
        level: level,
        short: level_description(level),
        detailed: level_detailed_description(level)
      }
    end
  end
end
