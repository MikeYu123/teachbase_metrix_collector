require 'dry-configurable'
require "teachbase_metrix_collector/version"
require "teachbase_metrix_collector/update_stat_job"
require "teachbase_metrix_collector/belongs_to_stat"

module Teachbase
  module MetrixCollector
    extend Dry::Configurable
    # Here there will be settings
  end
end
