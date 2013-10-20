require_relative '../models/repository.rb'
require_relative '../models/reports.rb'

get '/repos/:user/:name/:hash/?' do |user, name, hash|
  @repo = Repository.where(owner: user, name: name).first
  @commit = Commit.where(repository: @repo, sha1: hash).reject{|x| x.rubocop.nil?}.first unless @repo.nil?
  @report = CommitReport.new(@commit)

  @report.delta_offences

  raise Sinatra::NotFound if @repo.nil? or @commit.nil? or @report.nil?

  erb :'commit/show'
end
