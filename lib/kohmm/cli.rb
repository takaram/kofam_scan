module KOHMM
  module CLI
    extend Autoload

    autoload :OptionParser

    class << self
      def run(argv = ARGV)
        # display help first if with -h option
        if ["-h", "--help"].any? { |h| argv.include? h }
          puts OptionParser.usage
          exit 0
        end

        config = Config.load(DEFAULT_CONFIG_FILE)
        parse_options(argv, config)
        check_argv_length(argv)
        config.query = argv[0]

        Executor.execute(config)
      end

      private

      def parse_options(argv, config)
        OptionParser.new(config).parse!(argv)
      rescue ::OptionParser::ParseError => e
        warn "Error: #{e.message}", OptionParser.usage
        exit 1
      end

      def check_argv_length(argv)
        abort "Specify a query file"            if argv.empty?
        abort "Too many command line arguments" if argv.size > 1
      end
    end
  end
end
