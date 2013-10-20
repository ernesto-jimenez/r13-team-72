helpers do
  def contributors_by_score(report)
    report.author_scores.sort_by{|key, value| value}.reverse.map do |x|
      {:email => x[0],
       :score => x[1],
       :name => report.author_names[x[0]]}
    end
  end

  def icon_for_severity(severity)
    case severity
    when 'fatal' then 'icon-fire'
    when 'error' then 'icon-remove-sign'
    when 'warning' then 'icon-warning-sign'
    else 'icon-flag'
    end
  end

  def featured_repos
    Repository.where(featured: true).all
  end
end
