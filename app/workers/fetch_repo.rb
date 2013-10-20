require_relative '../models/repository.rb'
require_relative '../services/repo_analyzer.rb'

class FetchRepo
  @queue = :fetch_repository

  def self.perform(repo_id)
    repo = Repository.find(repo_id)
    analyzer = RepoAnalyzer.new(repo)
    analyzer.analyze_last_commits
  rescue Exception => e
    Resque.enqueue self, repo_id
    puts "Performing #{self} caused an exception (#{e}). Retrying..."
    Kernel.exit
  end

  def on_failure_retry(e, *args)
    Resque.enqueue self, *args
    puts "Performing #{self} caused an exception (#{e}). Retrying..."
    Kernel.exit
  end
end

