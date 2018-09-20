module KOHMM
  class Executor
    attr_reader :config

    def self.execute(config)
      new(config).execute
    end

    def initialize(config = nil)
      @config = config
      @config ||= File.exist?(DEFAULT_CONFIG_FILE) ? Config.load(DEFAULT_CONFIG_FILE) : Config.new
    end

    def execute
      read_thresholds
      setup_directories
      run_hmmsearch unless config.reannotation?
      search_hit_genes
      output_hits
    end

    def read_thresholds(path = nil)
      path ||= config.threshold_list
      list_file = File.open(path)
      begin
        @threshold_list = ThresholdList.new(list_file)
      ensure
        list_file.close
      end
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
                              File.join(config.tmp_dir, "hmmsearch_result")
      dir = @hmmsearch_result_dir
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end

    def ko_list
      profiles_path = File.join(config.profile_dir, "K?????")
      Dir.glob(profiles_path).map { |path| File.basename(path) }
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
      result  = File.join(Shellwords.escape(@hmmsearch_result_dir), "{}")
      profile = File.join(Shellwords.escape(config.profile_dir), "{}")
      hmmsearch = Shellwords.escape(config.hmmsearch)
      query = Shellwords.escape(config.query)

      "#{hmmsearch} --cpu=1 -T0 --tblout=#{result}" \
      " #{profile} #{query} > #{null_device}"
    end

    def search_hit_genes
      result_files_path = File.join(@hmmsearch_result_dir, "K?????")
      files = Dir.glob(result_files_path)
      @hit_genes = HitGenes.new(files, @threshold_list)
    end

    def output_hits(all = true)
      all ? output_all_hits : output_only_top_hit
    end

    private

    def output_all_hits
      query_list.each do |q|
        if @hit_genes.has_key?(q)
          hit_genes_of_q = @hit_genes[q].sort_by { |ary| ary[1] }.reverse
          output_file.puts [q, *hit_genes_of_q].join("\t")
        else
          output_file.puts q
        end
      end
    end

    def output_only_top_hit
      annotation_result = {}
      @hit_genes.each do |gene, ko_and_val|
        annotation_result[gene] = ko_and_val.max_by { |ary| ary[1] }
      end

      query_list.each do |q|
        if annotation_result.has_key?(q)
          ko = annotation_result[q][0]
          output_file.puts "#{q}\t#{ko}"
        else
          output_file.puts q
        end
      end
    end

    def null_device
      ["/dev/null", "NUL"].find { |nul| File.exist?(nul) }
    end
  end
end
