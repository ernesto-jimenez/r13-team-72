helpers do
  def repo_url(repo)
    "/repos/#{repo.owner}/#{repo.name}/"
  end

  def commit_url(commit)
    repo = commit.repository
    "/repos/#{repo.owner}/#{repo.name}/#{commit.sha1}/"
  end

  def github_url(repo)
    [github_base_url,repo.owner,repo.name].join('/')
  end

  def github_base_url
    "https://github.com"
  end

  def github_repo_commits_by(repo, email)
    [github_url(repo), "commits?author=#{email}"].join('/')
  end

  def github_commit_url(commit)
    [github_url(commit.repository), commit, commit.sha1].join('/')
  end

  def github_file_url(commit, file, line=nil)
    url = [github_url(commit.repository), commit, commit.sha1, file].join('/')
    url << "#L#{line}" if line
  end

  def gravatar_url(email, size=nil)
    require 'digest/md5'
    hash = Digest::MD5.hexdigest(email)
    query_string = size.nil? ? '' : "?s=#{size}"
    image_src = "http://www.gravatar.com/avatar/#{hash}/#{query_string}"
    return image_src
  end
end
