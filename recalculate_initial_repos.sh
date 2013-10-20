for repo in $(cat initial_repos); do bundle exec rake recalculate_scores_for\[$repo\]; done
