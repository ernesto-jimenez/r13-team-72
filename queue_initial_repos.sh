for repo in $(cat initial_repos); do bundle exec rake queue_repo\[$repo\]; done
