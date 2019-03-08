autoload :OptionParser, 'optparse'

module KofamScan
  module CLI
    class OptionParser
      def self.usage
        <<~USAGE
          Usage: #{File.basename($PROGRAM_NAME)} [options] <query>
            <query>                      FASTA formatted query sequence file
            -o <file>                    File to output the result  [stdout]
            -f, --format <format>        Format of the output [detail]
              detail:          Detail for each hits (including hits below threshold)
              mapper:          KEGG Mapper compatible format
              mapper-one-line: Similar to mapper, but all hit KOs are listed in one line
            --[no-]report-unannotated    Sequence name will be shown even if no KOs are assigned
                                         Default is true when format=mapper or mapper-all,
                                         false when format=detail
            -p, --profile <dir>          Profile HMM database
            -k, --ko_list <file>         KO information file
            -r, --reannotate             Skip hmmsearch
            --cpu <num>                  Number of CPU to use  [1]
            --tmp_dir <dir>              Temporary directory  [./tmp]
            --create-domain-alignment    Create domain annotation files for each sequence
                                         They will be located in the tmp directory
            -h, --help                   Show this message and exit
        USAGE
      end

      OUTPUT_FORMATTER_MAP = {
        "detail"          => OutputFormatter::HitDetailFormatter,
        "mapper"          => OutputFormatter::TabularAllHitFormatter,
        "mapper-one-line" => OutputFormatter::MultiHitTabularFormatter
      }.freeze
      OUTPUT_FORMATTER_MAP.each_key(&:freeze)

      def initialize(config, parser = ::OptionParser.new)
        @parser = parser
        @config = config
        @after_hook = []

        set_options_to_parser

        @parser.version = KofamScan::VERSION
      end

      def parse!(argv = nil)
        argv ? @parser.parse!(argv) : @parser.parse!
        @after_hook.each(&:call)
      end

      def usage
        self.class.usage
      end

      private

      def set_options_to_parser
        @parser.on("-o f")               { |o| @config.output_file = o }
        @parser.on("-p d", "--profile")  { |p| @config.profile = p }
        @parser.on("-k f", "--ko_list")  { |t| @config.ko_list = t }
        @parser.on("--cpu n", Integer)   { |c| @config.cpu = c }
        @parser.on("--tmp_dir d")        { |d| @config.tmp_dir = d }
        @parser.on("-r", "--reannotate") { |r| @config.reannotation = r }
        @parser.on("-h", "--help")       { puts usage; exit }

        @parser.on("-f n", "--format") do |f|
          @config.formatter = OUTPUT_FORMATTER_MAP[f].new
        end

        # This is done as an after hook because formatter can be changed
        # during the option parse
        @parser.on("--[no-]report-unannotated") do |b|
          @after_hook << -> { @config.formatter.report_unannotated = b }
        end

        @parser.on("--create-domain-alignment") do |b|
          @config.create_domain_alignment = b
        end
      end
    end
  end
end
