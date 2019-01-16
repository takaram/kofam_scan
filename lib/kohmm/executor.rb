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

    def run_hmmsearch
      parallel = Parallel.new(full_path: config.parallel)

      parallel.command = hmmsearch_command
      parallel.inputs = lookup_profiles(config.profile)
      parallel.cpu = config.cpu

      _out, err = parallel.exec

      unless parallel.success?
        warn "hmmsearch was not run successfully"
        warn err if err && !err.empty?
        exit 2
      end
    end

    def hmmsearch_command
      result = File.join(@hmmsearch_result_dir, "{/.}")
      if config.create_domain_alignment?
        out = File.join(config.tmp_dir, "output", "{/.}")
      else
        out = null_device
      end

      HMMSearch.command_path = config.hmmsearch
      HMMSearch.new("{}", config.query, cpu: 1, o: out, T: 0, tblout: result).to_a
    end

    def search_hit_genes
      files = Dir.entries(@hmmsearch_result_dir).grep_v(/\A\./)
      files.map! { |f| File.join(@hmmsearch_result_dir, f) }
      @result = Result.new(query_list)
      @result.parse(*files)
    end

    def output_hits
      out = config.output_io
      config.formatter.format(@result, out)
      out.close
    end

    def rearrange_alignments
      from_dir = File.join(config.tmp_dir, "output")
      to_dir = File.join(config.tmp_dir, "alignment")
      OutputRearranger.new(from_dir, to_dir).rearrange
    end

    def lookup_profiles(db)
      if db.end_with?(".hal")
        parse_hal(db)
      elsif db.end_with?(".hmm")
        [File.expand_path(db)]
      elsif File.directory?(db)
        Dir.glob(File.expand_path("*.hmm", db))
      elsif File.exist?("#{db}.hal")
        parse_hal("#{db}.hal")
      elsif File.exist?("#{db}.hmm")
        [File.expand_path("#{db}.hmm")]
      else
        raise "Database not found: #{db}"
      end
    end

    private

    def null_device
      ["/dev/null", "NUL"].find { |nul| File.exist?(nul) }
    end

    def parse_hal(hal)
      base_dir = File.dirname(hal)
      IO.foreach(hal).with_object([]) do |line, ary|
        ary << File.expand_path(line.chomp, base_dir) unless line.start_with?("#")
      end
    end
  end
end
