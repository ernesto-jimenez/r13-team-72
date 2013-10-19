require 'rugged'
require './app/models/repository.rb'

class LocalRepoController
  BASE_DIR = './repos'
  attr_reader :repository

  def initialize(repository)
    @repository = repository
  end

  def analyse_last_commits
    pull_master
    walk(@repository.last_commit) do |commit|
      saved_commit = save_commit(commit)
      report_saved = run_rubocop(saved_commit)
      if report_saved
        @repository.last_commit = commit.oid
        @repository.save
      else
        raise "Report not saved for commit #{commit.sha1}"
      end
    end
  end

  def run_rubocop(commit)
    Dir.chdir(work_directory) do
      system('git', 'checkout', commit.sha1)
      report = commit.rubocop || commit.build_rubocop
      report.output = JSON.parse(`rubocop -f json`)
      return report.save
    end
  end

  def save_commit(commit)
    @repository.commits.find_or_create_by(
      subject: commit.message,
      sha1: commit.oid,
      author: commit.author[:name],
      author_email: commit.author[:email],
      parent_hashes: commit.parents.map(&:oid)
    )
  end

  def rugged
    @rugged ||= Rugged::Repository.new(work_directory)
  end

  def walk(since, &block)
    walker = Rugged::Walker.new(rugged)
    walker.sorting(Rugged::SORT_DATE | Rugged::SORT_REVERSE)
    walker.push('master')
    walker.hide(since) if since
    walker.each(&block)
  end

  def checkout(id)
    Dir.chdir(work_directory) do
      system('git', 'checkout', id, '-f')
      system('git', 'clean', '-df')
    end
  end

  def pull_master
    clone
    Dir.chdir(work_directory) do
      system('git', 'pull', 'origin', 'master')
    end
    checkout('master')
  end

  def clone
    if !File.exists?(work_directory)
      Dir.mkdir(work_directory)
      Dir.chdir(work_directory) do
        system('git', 'init', '.')
        system('git', 'remote', 'add', 'origin', @repository.clone_url)
      end
    end
    return true
  end

  private
  def work_directory
    File.join(BASE_DIR, @repository.id)
  end
end

