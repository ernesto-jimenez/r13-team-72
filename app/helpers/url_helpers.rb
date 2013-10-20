helpers do
  def repo_url(repo)
    "/repos/#{repo.owner}/#{repo.name}/"
  end

  def commit_url(commit)
    repo = commit.repository
    "/repos/#{repo.owner}/#{repo.name}/#{commit.sha1}/"
  end

  def gravatar_url(email, size=nil)
    require 'digest/md5'
    hash = Digest::MD5.hexdigest(email)
    query_string = size.nil? ? '' : "?s=#{size}"
    image_src = "http://www.gravatar.com/avatar/#{hash}/#{query_string}"
  end
end
