require_relative '../models/repository.rb'

get '/repos/:user/:name/?' do |user, name|
  @repo = Repository.where(owner: user, name: name).first
  @report = @repo.repo_report
  @last_commit = @repo.commits.reverse.find{|x| not x.rubocop.nil? }
  raise Sinatra::NotFound if @repo.nil?
  erb :'repo/show'
end

