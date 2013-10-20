require_relative '../models/repository.rb'

get '/repos/:user/:name/?' do |user, name|
  @repo = Repository.where(owner: user, name: name).first
  @report = @repo.repo_report
  raise Sinatra::NotFound if @repo.nil?
  erb :'repo/show'
end

