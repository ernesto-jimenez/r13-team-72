class FetchRepo
  @queue = :fetch_repository

  def self.perform(repo, last_commit = nil)
    puts "Fetch #{repo} from #{last_commit}"
  end
end
