require_relative 'repository'

class RepoReport
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :repository

  field :score, type: Integer
  field :worst_errors, type: Array
end

class CommitReport
  attr_reader :commit

  def initialize(commit)
    @commit = commit
    @previous_commit = unless @commit.parent_hashes.empty?
      Commit.where(:sha1 => @commit.parent_hashes.first).first
    else
      nil
    end
    raise 'Need Rubocop data' if @commit.rubocop.nil?

    @delta_offenses = nil
  end

  def changed_files
    @commit.changed_files
  end

  def author
    @commit.author
  end

  def author_score
    100
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
