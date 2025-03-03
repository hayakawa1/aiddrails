module ApplicationHelper
  def level_description(level)
    case level
    when 1
      "基礎知識あり"
    when 2
      "簡単な業務経験あり"
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
end
