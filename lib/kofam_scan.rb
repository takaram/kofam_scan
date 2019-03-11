# add ./lib directory to the load path if not included
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

require 'kofam_scan/autoload'
require 'kofam_scan/config'
require 'kofam_scan/executor'
require 'kofam_scan/ko'
require 'kofam_scan/result'

module KofamScan
  extend Autoload

  autoload :HMMSearch, 'kofam_scan/hmmsearch'
  autoload :OutputFormatter
  autoload :Parallel

  VERSION = '0.1.2'.freeze
  DEFAULT_CONFIG_FILE = File.expand_path("../config.yml", __dir__).freeze

  class Error < StandardError; end
end
