require 'open3'
require 'rugged'
require_relative '../models/repository.rb'

class RepoAnalyzer
  BASE_DIR = './repos'
  attr_reader :repository

  def initialize(repository)
    @repository = repository
  end

  def analyze_last_commits
    pull_master
    walk(@repository.last_commit) do |commit|
      saved_commit = save_commit(commit)
      update_commit_changed_files(saved_commit)
      report_saved = run_rubocop(saved_commit)
      if report_saved
        @repository.last_commit = commit.oid
        @repository.save
      else
        raise "Report not saved for commit #{commit.sha1}"
      end
    end
    return true
  end

  def complete_missing_changed_files
    pull_master
    @repository.commits.where(changed_files: nil).each do |commit|
      update_commit_changed_files(commit)
    end
    return true
  end

  private
  def update_commit_changed_files(commit)
    git_show = ""
    Dir.chdir(work_directory) do
      git_show = run('git', 'show', '--name-only', '--oneline', commit.sha1)
    end
    changed_files = git_show.split("\n")[1..-1]
    commit.changed_files = changed_files
    commit.save
  end

  def run(*cmds)
    stdout, stderr, status = Open3.capture3(*cmds)
    stderr.strip.split("\n").each do |msg|
      Resque.logger.error(msg)
    end
    return stdout
  end

  def run_rubocop(commit)
    Dir.chdir(work_directory) do
      run('git', 'checkout', commit.sha1)
      report = commit.rubocop || commit.build_rubocop
      report.output = JSON.parse(run('rubocop', '-f', 'json'))
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
    return true
  end

  def checkout(id)
    Dir.chdir(work_directory) do
      run('git', 'checkout', id, '-f')
      run('git', 'clean', '-df')
    end
    return true
  end

  def pull_master
    clone
    Dir.chdir(work_directory) do
      run('git', 'pull', 'origin', 'master')
    end
    checkout('master')
    return true
  end

  def clone
    if !File.exists?(work_directory)
      Dir.mkdir(work_directory)
      Dir.chdir(work_directory) do
        run('git', 'init', '.')
        run('git', 'remote', 'add', 'origin', @repository.clone_url)
      end
    end
    return true
  end

  def work_directory
    File.join(BASE_DIR, @repository.id)
  end
end

