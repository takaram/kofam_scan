autoload :OptionParser, 'optparse'

module KOHMM
  module CLI
    class OptionParser
      def self.usage
        <<~USAGE
        Usage: #{File.basename($PROGRAM_NAME)} [options] <query>
          <query>                      FASTA formatted query sequence file
        -o <file>                    File to output the result  [stdout]
        -p, --profile <dir>          Directory where profile HMM files exist
        -t, --threshold_list <file>  List of bit score threshold
        -r, --reannotate <dir>       Directory where hmmsearch table files exist
        --cpu <num>                  Number of CPU to use  [1]
        --tmp_dir <dir>              Temporary directory  [./tmp]
            -h, --help                   Show this message and exit
        USAGE
      end

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
        @parser.on("-o f")                     { |o| @config.output_file = o }
        @parser.on("-p d", "--profile")        { |p| @config.profile_dir = p }
        @parser.on("-t f", "--threshold_list") { |t| @config.threshold_list = t }
        @parser.on("--cpu n", Integer)         { |c| @config.cpu = c }
        @parser.on("--tmp_dir d")              { |d| @config.tmp_dir = d }
        @parser.on("-h", "--help")             { puts usage; exit }

        @parser.on("-r d", "--reannotate") do |r|
          @config.hmmsearch_result_dir = r
          @config.reannotation = true
        end
      end
    end
  end
end
