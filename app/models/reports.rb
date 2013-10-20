require_relative 'repository'

class RepoReport
  INITIAL_REPO_SCORE   = 0
  INITIAL_AUTHOR_SCORE = 0

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :repository

  field :score,             type: Integer
  field :worst_errors,      type: Array
  field :author_scores,     type: Hash
  field :author_commits,    type: Hash
  field :author_names,      type: Hash
  field :processed_commits, type: Array

  def calculate_score
    self.score             = INITIAL_REPO_SCORE
    self.author_scores     = nil
    self.author_names      = nil
    self.author_commits    = nil
    self.processed_commits = nil

    repository.commits.each do |commit|
      process_commit(commit)
    end
  end

  def process_commit(commit)
    self.score             ||= INITIAL_REPO_SCORE
    self.author_scores     ||= {}
    self.author_commits    ||= {}
    self.author_names      ||= {}
    self.processed_commits ||= []

    return if self.processed_commits.include?(commit.sha1)

    score = CommitReport.new(commit).author_score

    self.score += score
    author_score = (
      self.author_scores[commit.author_email] || INITIAL_AUTHOR_SCORE) + score
    self.author_scores[commit.author_email] = author_score
    self.processed_commits << commit.sha1

    self.author_names[commit.author_email]   ||= commit.author
    self.author_commits[commit.author_email] ||= 0
    self.author_commits[commit.author_email] += 1

    commit.score = score
    commit.save
  rescue CommitReport::NoRubocop
  end

  def recalculate_score!
    calculate_score
    save
  end

  before_create :calculate_score
end

class CommitReport
  class NoRubocop < StandardError; end
  attr_reader :commit

  def initialize(commit)
    @commit = commit
    @previous_commit = unless @commit.parent_hashes.empty?
      Commit.where(:sha1 => @commit.parent_hashes.first).first
    else
      nil
    end
    raise NoRubocop if @commit.rubocop.nil?

    @delta_offences = nil
  end

  def changed_files
    @commit.changed_files
  end

  def author
    @commit.author
  end

  def author_score
    total_changed = changed_files.size
    # No points when no files have been changed
    return 0 if total_changed == 0

    # Calculate amount of offences added
    added_offences = delta_offences.collect { |f| f['delta_amount'] }.sum

    # 10 is the base punctuation when no offences are added/removed
    return 10 if added_offences == 0

    if added_offences > 0
      # Take less points when changing more files
      multiplier = added_offences / total_changed
    elsif
      # Add more points when changing more files
      multiplier = added_offences * total_changed
    end
    return (multiplier * -10)
  end

  def delta_offences
    return @delta_offences unless @delta_offences.nil?

    @delta_offences = []
    @commit.changed_files.each do |filename|
      if self.has_new_offence_status(filename)
        file = self.files.find{|x| x['path'] == filename}
        file['delta_amount'] = offence_delta_for_file(filename)
        @delta_offences.push(file)
      end
    end

    @delta_offences
  end

  def delta_offence_free_files
    self.delta_offences.select{|x| x['offences'].empty?}
  end

  def delta_offence_files
    self.delta_offences.reject{|x| x['offences'].empty?}
  end

  protected

  def has_new_offence_status(filename)
    file = self.files.find{|x| x['path'] == filename}
    prev_file = self.previous_files.find{|x| x['path'] == filename}
    return file && (prev_file.nil? || file['offences'] != prev_file['offences'])
  end

  def offence_delta_for_file(filename)
    file = self.files.find{|x| x['path'] == filename}
    prev_file = self.previous_files.find{|x| x['path'] == filename}

    if prev_file.nil?
      file['offences'].size
    else
      file['offences'].size - prev_file['offences'].size
    end
  end

  def files
    @commit.rubocop.output['files']
  end

  def previous_files
    return [] if @previous_commit.nil?
    @previous_commit.rubocop.output['files']
  end
end
