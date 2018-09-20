# add ./lib directory to the load path if not included
$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

autoload :FileUtils,  'fileutils'
autoload :Shellwords, 'shellwords'

module KOHMM
  autoload :Config,          'kohmm/config'
  autoload :Executor,        'kohmm/executor'
  autoload :HitGenes,        'kohmm/hit_genes'
  autoload :HmmsearchParser, 'kohmm/hmmsearch_parser'
  autoload :OptionParser,    'kohmm/option_parser'
  autoload :ParallelCommand, 'kohmm/parallel_command'
  autoload :ThresholdList,   'kohmm/threshold_list'

  VERSION = '0.1.2'.freeze
  DEFAULT_CONFIG_FILE = File.expand_path("../config.yml", __dir__).freeze
end
