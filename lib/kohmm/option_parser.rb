autoload :OptionParser, 'optparse'

class KOHMM
  class OptionParser
    def self.usage
      <<~USAGE
        Usage: #{File.basename($PROGRAM_NAME)} [options] <query>
            <query>                      FASTA formatted query sequence file
            -o <file>                    File to output the result  [stdout]
            -p, --profile <dir>          Directory where profile HMM files exist
            -t, --threshold_list <file>  List of bit score threshold
            -E <E-value>                 E-value threshold
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
      @parser.on("-o file") { |o| @config.output_file = o }
      @parser.on("-p dir", "--profile") { |p| @config.profile_dir = p }
      @parser.on("-t file", "--threshold_list") do |t|
        @config.score_mode
        @config.threshold_list = t
      end
      # @parser.on("-E val", Float) do |e|
      #   @config.e_value_mode
      #   @config.e_value = e
      # end
      @parser.on("-r dir", "--reannotate") do |r|
        @config.hmmsearch_result_dir = r
        @config.reannotation = true
      end
      @parser.on("--cpu num", Integer) { |c| @config.cpu = c }
      @parser.on("--tmp_dir dir") { |d| @config.tmp_dir = d }
      @parser.on("-h", "--help") { puts usage; exit }
    end
  end
end
