autoload :OptionParser, 'optparse'

class KOHMM
  class OptionParser
    def self.usage
      usage_str = <<~EOS
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
      EOS
      usage_str.sub(/^\s+-E .+\n/, "") # remove the explanation of -E option
    end

    def initialize(config, parser = ::OptionParser.new)
      @parser = parser
      @config = config

      @parser.on("-o file") {|o| @config.output_file = o }
      @parser.on("-p dir", "--profile") {|p| @config.profile_dir = p }
      @parser.on("-t file", "--threshold_list") {|t|
        @config.score_mode
        @config.threshold_list = t
      }
      @parser.on("-E val", Float) {|e|
        @config.e_value_mode
        @config.e_value = e
      }
      @parser.on("-r dir", "--reannotate") {|r|
        @config.hmmsearch_result_dir = r
        @config.reannotation = true
      }
      @parser.on("--cpu num", Integer) {|c| @config.cpu = c }
      @parser.on("--tmp_dir dir") {|d| @config.tmp_dir = d }
      @parser.on("-h", "--help") { puts usage; exit }

      @parser.version = KOHMM::VERSION
    end

    def parse!(argv = nil)
      argv ? @parser.parse!(argv) : @parser.parse!
    end

    def usage
      self.class.usage
    end
  end
end
