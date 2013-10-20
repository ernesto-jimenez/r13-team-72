require 'octokit'

class Repository
  include Mongoid::Document
  include Mongoid::Timestamps
  field :owner, type: String
  field :name, type: String
  field :last_commit, type: String, default: nil

  has_many :commits

  validates_presence_of :owner
  validates_presence_of :name

  def self.from_url(url)
    repo = Octokit::Repository.from_url(url)
    Repository.find_or_create_by(owner: repo.owner, name: repo.name)
  end

  def octokit_repo
    Octokit::Repository.new(self.attributes.symbolize_keys)
  end

  def clone_url
    "#{octokit_repo.url}.git"
  end
end

class Commit
  include Mongoid::Document
  include Mongoid::Timestamps
  field :subject, type: String      # Commit short message
  field :sha1, type: String         # Commit hash
  field :parent_hashes, type: Array # List of parent commit Hashes
  field :author, type: String       # Commit author name
  field :author_email, type: String # Commit author email
  field :changed_files, type: Array # List of files changed

  belongs_to :repository
  has_one :rubocop

  validates_presence_of :subject
  validates_presence_of :sha1
  #validates_presence_of :parent_hashes
  validates_presence_of :author
  validates_presence_of :author_email
  #validates_presence_of :changed_files
  validates_presence_of :repository_id

  #validates_length_of :parent_hashes, minimum: 1
end

class Rubocop
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :commit
  field :output, type: Hash

  validates_presence_of :output
  validates_presence_of :commit_id
end

