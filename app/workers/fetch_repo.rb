require_relative '../models/repository.rb'
require_relative '../controllers/local_repo_controller.rb'

class FetchRepo
  @queue = :fetch_repository

  def self.perform(repo_id)
    repo = Repository.find(repo_id)
    controller = LocalRepoController.new(repo)
    controller.analyse_last_commits
  end
end

