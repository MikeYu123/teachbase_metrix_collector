require 'active_job'
require 'active_record'

module Teachbase
  module MetrixCollector
    class UpdateStatJob < ActiveJob::Base
      queue_as :default

      def perform(model, changes)
        changes.each do |field, delta|
          model[field] = delta + model[field].to_i
        end
        model.save
      rescue ActiveRecord::StaleObjectError
        self.class.perform_later(model.reload, changes)
      end
    end
  end
end
