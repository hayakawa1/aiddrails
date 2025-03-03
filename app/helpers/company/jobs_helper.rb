module Company::JobsHelper
  # スキルレベルの説明を返す
  def level_description(level)
    case level
    when 1
      "基礎レベル"
    when 2
      "初級レベル"
    when 3
      "中級レベル"
    when 4
      "上級レベル"
    when 5
      "エキスパートレベル"
    else
      "未設定"
    end
  end
  
  # 給与の表示形式をフォーマットする
  def format_salary(min, max)
    if min.present?
      "#{min}万円"
    else
      "応相談"
    end
  end
end
