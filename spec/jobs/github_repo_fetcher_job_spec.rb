require 'rails_helper'

describe GithubRepoFetcherJob, type: :job do
  describe '.perform' do
    it 'should work' do
      expect(User).to receive(:fetch_github_repositories).with(234).once
      GithubRepoFetcherJob.perform_later(234)
    end
  end
end
