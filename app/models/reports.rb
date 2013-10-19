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
    puts "Computing delta offences..."
    @delta_offences = []
    self.files.each do |f|
      puts "Scanning #{f['path']}"
      previous_file = self.previous_files.find{|x| x['path'] == f['path']}
      puts "Found previous one! #{previous_file['path']}" unless previous_file.nil?

      if previous_file.nil? or f['offences'] != previous_file['offences']
        puts "Different file!"
        @delta_offences.push f
      end
      puts @delta_offences
      @delta_offences
    end

    return @delta_offences
  end

  def delta_offence_free_files
    self.delta_offences.select{|x| x['offences'].empty?}
  end

  def delta_offence_files
    self.delta_offences.reject{|x| x['offences'].empty?}
  end

  def offence_free_files
    self.files.select{|x| x['offences'].empty?}
  end

  def offence_files
    self.files.reject{|x| x['offences'].empty?}
  end

  def files
    @commit.rubocop.output['files']
  end

  def previous_files
    return [] if @previous_commit.nil?
    @previous_commit.rubocop.output['files']
  end
end
