helpers do
  def repo_url(repo)
    "/repos/#{repo.owner}/#{repo.name}/"
  end

  def commit_url(commit)
    repo = commit.repository
    "/repos/#{repo.owner}/#{repo.name}/#{commit.sha1}/"
  end
end
