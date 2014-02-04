class MainController < ApplicationController
  def index
    @branches = CommitMonitorBranch.includes(:repo).sort_by { |b| [b.repo.name, b.name] }
  end
end
