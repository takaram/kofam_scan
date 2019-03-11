require 'kofam_scan/cli/option_parser'

module KofamScan
  module CLI
    class << self
      def run(argv = ARGV)
        # display help first if with -h option
        if ["-h", "--help"].any? { |h| argv.include? h }
          puts OptionParser.usage
          exit 0
        end

        config_file = DEFAULT_CONFIG_FILE
        config = File.exist?(config_file) ? Config.load(config_file) : Config.new
        parse_options(argv, config)
        check_argv_length(argv)
        config.query = argv[0]

        Executor.execute(config)
      end

      private

      def parse_options(argv, config)
        OptionParser.new(config).parse!(argv)
      rescue ::OptionParser::ParseError => e
        abort_with_usage "Error: #{e.message}"
      end

      def check_argv_length(argv)
        abort_with_usage "Error: Specify a query file" if argv.empty?
        abort_with_usage "Error: Too many arguments"   if argv.size > 1
      end

      def abort_with_usage(message = nil)
        message = message ? "#{message}\n" : ""
        message << OptionParser.usage
        abort message
      end
    end
  end
end
