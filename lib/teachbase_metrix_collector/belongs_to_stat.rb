require 'active_support'
require 'active_support/core_ext'
# require 'update_stat_job'

module Teachbase
  module MetrixCollector
    module BelongsToStat
      class OptimisticLockingUnsupported < StandardError; end
      class UnknownFields < StandardError; end
      extend ActiveSupport::Concern
      # Separate service method to be tested separately
      def prepare_changes(columns)
        self.changes.symbolize_keys.slice(*columns).map do |column, vals|
          [column, vals.last.to_i - vals.first.to_i]
        end.to_h
      end

      class_methods do
        def belongs_to_stat(name, columns:)
          belongs_to name
          other_class = reflect_on_association(name).klass
          columns_exist = columns.all? do |column|
            has_attribute?(column) &&
              other_class.has_attribute?(column)
          end
          raise UnknownFields unless columns_exist
          raise OptimisticLockingUnsupported.new unless lock_optimistically && other_class.lock_optimistically
          before_save do
            tracked_columns = prepare_changes(columns)
            parent = send(name)
            if parent
              Teachbase::MetrixCollector::UpdateStatJob.perform_later(parent, tracked_columns)
            end
          end
        end
      end
    end
  end
end
