describe CommitMonitorHandlers::CommitRange::GemChangesLabeler do
  let(:branch)         { create(:pr_branch) }
  let(:git_service)    { double("GitService", :diff => double("RuggedDiff", :new_files => new_files)) }
  let(:github_service) { stub_github_service }

  before do
    stub_sidekiq_logger
    stub_settings(:gem_changes_labeler, :enabled_repos, [branch.repo.name])
    expect_any_instance_of(Branch).to receive(:git_service).and_return(git_service)
  end

  context "when there are Gemfile changes" do
    let(:new_files) { ["Gemfile", "some/other/file.rb"] }

    it "adds a label to the PR" do
      expect(github_service).to receive(:add_issue_labels).with(branch.pr_number, "gem changes")

      described_class.new.perform(branch.id, nil)
    end
  end

  context "when there are Gemfile changes to deep Gemfiles" do
    let(:new_files) { ["gems/pending/Gemfile", "some/other/file.rb"] }

    it "adds a label to the PR" do
      expect(github_service).to receive(:add_issue_labels).with(branch.pr_number, "gem changes")

      described_class.new.perform(branch.id, nil)
    end
  end

  context "where there are no Gemfile changes" do
    let(:new_files) { ["some/other/file.rb"] }

    it "does not add a label to the PR" do
      expect(github_service).to_not receive(:add_issue_labels)

      described_class.new.perform(branch.id, nil)
    end
  end
end
