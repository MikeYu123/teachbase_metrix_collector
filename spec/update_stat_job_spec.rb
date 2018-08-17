require 'spec_helper'
require 'teachbase_metrix_collector'
require 'global_id'
RSpec.describe Teachbase::MetrixCollector::UpdateStatJob, type: :job do
  include ActiveJob::TestHelper

  ActiveJob::Base.queue_adapter = :test
  GlobalID.app = 'bcx'

  class ParentStat < ActiveRecord::Base
    include GlobalID::Identification
  end

  before :each do
    ParentStat.create(score: 2, time_spent: 3)
  end

  after :each do
    clear_enqueued_jobs
    clear_performed_jobs
    # TODO: databasecleaner
    ParentStat.delete_all
  end

  let(:parent_stat) {ParentStat.first}

  subject(:job) do
    described_class.perform_later(parent_stat, {score: 2, time_spent: 3})
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'updates the model' do
    perform_enqueued_jobs do
      job
      parent_stat.reload
      expect(parent_stat.score).to eq(4)
      expect(parent_stat.time_spent).to eq(6)
    end
  end

  describe 'when obtaining lock fails' do
    it 'restarts with a new job' do
      ps1 = parent_stat
      allow_any_instance_of(ParentStat).to receive(:save).and_raise(ActiveRecord::StaleObjectError)
      described_class.perform_now(parent_stat, {score: 2, time_spent: 3})
      expect(enqueued_jobs.length).to eq(1)
      expect(enqueued_jobs.first[:job]).to eq(described_class)
      expect(enqueued_jobs.first[:args][1]['score']).to eq(2)
      expect(enqueued_jobs.first[:args][1]['time_spent']).to eq(3)
    end
  end


end
