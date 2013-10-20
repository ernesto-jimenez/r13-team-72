require_relative '../models/repository.rb'
require_relative '../workers/fetch_repo.rb'

get '/repos' do
  redirect to('/')
end

get '/repos/:user/:name/?' do |user, name|
  @repo = Repository.where(owner: user, name: name).first
  raise Sinatra::NotFound if @repo.nil?
  @report = @repo.repo_report
  if @report.nil?
    erb :'repo/loading'
  else
    @last_commit = @repo.commits.reverse.find{|x| not x.rubocop.nil? }
    erb :'repo/show'
  end
end

post '/repos' do
  url = params[:url]
  if url =~ %r{https?://(www\.)?github\.com/[^/]+/[^/]+/?}
    repo = Repository.from_url(url)
    if !repo.repo_report.nil?
      redirect to(repo_url(repo))
    else
      Resque.enqueue(FetchRepo, repo.id)
      erb :'repo/loading'
    end
  else
    erb :'repo/invalid_repo'
  end
end

