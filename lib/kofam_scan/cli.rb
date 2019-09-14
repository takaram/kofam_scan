# frozen_string_literal: false

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

        config_file = config_option(argv) || DEFAULT_CONFIG_FILE
        config = File.exist?(config_file) ? Config.load(config_file) : Config.new
        parse_options(argv, config)
        check_argv_length(argv)
        config.query = argv[0]

        Executor.execute(config)
      rescue Error => e
        abort "Error: #{e.message}"
      end

      private

      def config_option(argv)
        index = argv.index { |i| i.match(/\A(?:-c(.+)?|--config(?:=(.*))?)\z/) }
        return nil unless index

        match = Regexp.last_match
        if (conf_file = match[1] || match[2])
          argv.delete_at(index)
        else
          _c, conf_file = argv.slice!(index, 2)
        end
        abort "File not found: #{conf_file}" unless File.exist?(conf_file)

        conf_file
      end

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
