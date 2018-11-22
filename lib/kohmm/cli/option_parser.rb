autoload :OptionParser, 'optparse'

module KOHMM
  module CLI
    class OptionParser
      def self.usage
        <<~USAGE
          Usage: #{File.basename($PROGRAM_NAME)} [options] <query>
            <query>                      FASTA formatted query sequence file
            -o <file>                    File to output the result  [stdout]
            -f, --format <num>           Format of the output [1]
              1: Detail for each hits (including hits below threshold)
              2: TSV format with gene name and the top hit KO
              3: TSV format with gene name and all hit KOs
            -p, --profile <dir>          Directory where profile HMM files exist
            -k, --ko_list <file>         KO information file
            -r, --reannotate <dir>       Directory where hmmsearch table files exist
            --cpu <num>                  Number of CPU to use  [1]
            --tmp_dir <dir>              Temporary directory  [./tmp]
            -h, --help                   Show this message and exit
        USAGE
      end

      OUTPUT_FORMATTER_LIST = [
        OutputFormatter::HitDetailFormatter,
        OutputFormatter::SimpleTabularFormatter,
        OutputFormatter::MultiHitTabularFormatter
      ].freeze

      def initialize(config, parser = ::OptionParser.new)
        @parser = parser
        @config = config

        set_options_to_parser

        @parser.version = KOHMM::VERSION
      end

      def parse!(argv = nil)
        argv ? @parser.parse!(argv) : @parser.parse!
      end

      def usage
        self.class.usage
      end

      private

      def set_options_to_parser
        @parser.on("-o f")              { |o| @config.output_file = o }
        @parser.on("-p d", "--profile") { |p| @config.profile_dir = p }
        @parser.on("-k f", "--ko_list") { |t| @config.ko_list = t }
        @parser.on("--cpu n", Integer)  { |c| @config.cpu = c }
        @parser.on("--tmp_dir d")       { |d| @config.tmp_dir = d }
        @parser.on("-h", "--help")      { puts usage; exit }

        @parser.on("-f n", "--format", Integer) do |n|
          @config.formatter = OUTPUT_FORMATTER_LIST[n - 1].new
        end

        @parser.on("-r d", "--reannotate") do |r|
          @config.hmmsearch_result_dir = r
          @config.reannotation = true
        end
      end
    end
  end
end
