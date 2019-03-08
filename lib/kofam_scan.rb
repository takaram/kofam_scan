# add ./lib directory to the load path if not included
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

autoload :FileUtils, 'fileutils'

require 'kofam_scan/autoload'

module KofamScan
  extend KofamScan::Autoload

  autoload :CLI
  autoload :Config
  autoload :Executor
  autoload :HMMSearch, 'kofam_scan/hmmsearch'
  autoload :KO
  autoload :OutputFormatter
  autoload :OutputRearranger
  autoload :Parallel
  autoload :Result

  VERSION = '0.1.2'.freeze
  DEFAULT_CONFIG_FILE = File.expand_path("../config.yml", __dir__).freeze
end
