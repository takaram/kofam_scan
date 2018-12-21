module KOHMM
  class Executor
    attr_reader :config

    def self.execute(config)
      new(config).execute
    end

    def initialize(config = nil)
      if config
        @config = config
      elsif File.exist?(DEFAULT_CONFIG_FILE)
        @config = Config.load(DEFAULT_CONFIG_FILE)
      else
        @config = Config.new
      end
    end

    def execute
      parse_ko
      setup_directories
      run_hmmsearch unless config.reannotation?
      search_hit_genes
      output_hits
      rearrange_alignments if config.create_domain_alignment?
    end

    def parse_ko
      File.open(config.ko_list) { |file| KO.parse(file) }
    end

    def output_file
      @output_file ||= File.open(config.output_file, "w")
    end

    def query_list
      @query_list ||= File.open(config.query) do |f|
        f.grep(/^>(\S+)/) { $1 }
      end
    end

    def setup_directories
      @hmmsearch_result_dir = config.hmmsearch_result_dir ||
                              File.join(config.tmp_dir, "tabular")
      dir = @hmmsearch_result_dir
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

      if config.create_domain_alignment?
        FileUtils.mkdir_p(File.join(config.tmp_dir, "output"))
        FileUtils.mkdir_p(File.join(config.tmp_dir, "alignment"))
      end
    end

    def ko_list
      KO.all.select(&:profile_available?).map(&:name)
    end

    def run_hmmsearch
      parallel = ParallelCommand.create(config.parallel)

      parallel.command = hmmsearch_command
      parallel.inputs = ko_list
      parallel.cpu = config.cpu

      _out, err = parallel.exec

      unless parallel.success?
        warn "hmmsearch was not run successfully"
        warn err if err && !err.empty?
        exit 2
      end
    end

    def hmmsearch_command
      result  = File.join(@hmmsearch_result_dir, "{}")
      profile = File.join(config.profile_dir, "{}.hmm")
      if config.create_domain_alignment?
        out = File.join(config.tmp_dir, "output", "{}")
      else
        out = null_device
      end

      HMMSearch.command_path = config.hmmsearch
      HMMSearch.new(profile, config.query, cpu: 1, o: out, T: 0, tblout: result).to_a
    end

    def search_hit_genes
      result_files_path = File.join(@hmmsearch_result_dir, "K?????")
      files = Dir.glob(result_files_path)
      @result = Result.new(query_list)
      @result.parse(*files)
    end

    def output_hits
      config.formatter.format(@result, output_file)
    end

    def rearrange_alignments
      from_dir = File.join(config.tmp_dir, "output")
      to_dir = File.join(config.tmp_dir, "alignment")
      AlignmentRearranger.new(from_dir, to_dir).rearrange
    end

    private

    def null_device
      ["/dev/null", "NUL"].find { |nul| File.exist?(nul) }
    end
  end
end
