helpers do
  LEVELS = {
    'convention' => 0,
    'warning' => 1,
    'error' => 2,
    'fatal' => 3
  }

  def offences_by_severity(offences)
    return offences.sort{|x, y| LEVELS[x['severity']] <=> LEVELS[y['severity']]}
  end
end
