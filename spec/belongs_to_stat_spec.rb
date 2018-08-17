require 'spec_helper'
require 'teachbase_metrix_collector'
require 'global_id'
RSpec.describe Teachbase::MetrixCollector::BelongsToStat do
  include ActiveJob::TestHelper

  ActiveJob::Base.queue_adapter = :test
  GlobalID.app = 'bcx'

  after :each do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  class ParentStat < ActiveRecord::Base ; end
  class ChildStat < ActiveRecord::Base
    include Teachbase::MetrixCollector::BelongsToStat
    belongs_to_stat :parent_stat, columns: %i[score]
  end

  describe 'when included to models without optimistic locking' do
    it 'throws OptimisticLockingUnsupported exception' do
      expect do
        class InsuitableChildStat < ActiveRecord::Base
          belongs_to_stat :parent_stat, columns: %i[score]
        end.to raise_error(OptimisticLockingUnsupported)
      end
    end
  end

  describe 'when unsupported fields are tracked' do
    it 'throws UnknownFields exception' do
      expect do
        class InsuitableChildStat < ActiveRecord::Base
          belongs_to_stat :parent_stat, columns: %i[some_weird_column]
        end.to raise_error(UnknownFields)
      end
    end
  end

  it 'updates parent model for child model' do
    parent = ParentStat.create

    child = ChildStat.create(parent_stat: parent, score: 3)

    expect(enqueued_jobs.length).to eq(1)
    expect(enqueued_jobs.last[:job]).to eq(Teachbase::MetrixCollector::UpdateStatJob)
    expect(enqueued_jobs.last[:args][1]['score']).to eq(3)

    child.update(score: 4)

    expect(enqueued_jobs.length).to eq(2)
    expect(enqueued_jobs.last[:job]).to eq(Teachbase::MetrixCollector::UpdateStatJob)
    expect(enqueued_jobs.last[:args][1]['score']).to eq(1)
  end

end
