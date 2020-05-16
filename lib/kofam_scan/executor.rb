# frozen_string_literal: true

module KofamScan
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
      check_query_names

      if config.reannotation?
        tabular_dir = File.join(config.tmp_dir, "tabular")
        unless File.exist?(tabular_dir)
          raise Error, <<~ERROR
            Could not find hmmsearch tabular output files.
            They must be in #{tabular_dir}.
          ERROR
        end
      else
        setup_directories
        run_hmmsearch
      end

      search_hit_genes
      output_hits
      rearrange_alignments if config.create_alignment?

      unless config.keep_tabular?
        combine_kofile("tabular", "tabular.txt")
        rm_kofile("tabular")
      end

      if config.create_alignment? && !config.keep_output?
        combine_kofile("output", "output.txt")
        rm_kofile("output")
      end
    end

    def rm_kofile(ko_dir)
      File.delete(*list_kofile(ko_dir))
    end

    def combine_kofile(ko_dir, outfile)
      save_file = File.join(config.tmp_dir, ko_dir, outfile)
      File.open(save_file, 'w') do |dest|
        list_kofile(ko_dir).each do |src|
          dest.puts File.basename(src)
          IO.copy_stream(src, dest)
          dest.puts
        end
      end
    end

    def list_kofile(ko_dir)
      dir = File.join(config.tmp_dir, ko_dir)
      if File.directory?(dir)
        output_ko = File.join(dir, "K*")
        Dir.glob(output_ko)
      end
    end

    def parse_ko
      raise Error, "KO list not given" unless config.ko_list
      raise Error, "KO list not exist: #{config.ko_list}" unless File.exist?(config.ko_list)

      File.open(config.ko_list) { |file| KO.parse(file) }
    end

    def query_list
      @query_list ||= File.open(config.query) do |f|
        f.grep(/^>(\S*)/) { $1 }
      end
    end

    def setup_directories
      require 'fileutils'

      dirs_to_make = ["tabular"]
      dirs_to_make.push("output", "alignment") if config.create_alignment?

      dirs_to_make.each do |dir|
        FileUtils.mkdir_p(File.join(config.tmp_dir, dir))
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
      result = File.join(config.tmp_dir, "tabular", "{/.}")
      if config.create_alignment?
        out = File.join(config.tmp_dir, "output", "{/.}")
      else
        out = File::NULL
      end

      HMMSearch.command_path = config.hmmsearch
      HMMSearch.new("{}", config.query, cpu: 1, o: out, T: 0, tblout: result).to_a
    end

    def search_hit_genes
      result_option = {
        e_value_threshold: config.e_value,
        threshold_scale:   config.threshold_scale,
      }.compact
      @result = Result.create(query_list, **result_option)
      @result.parse(*list_kofile("tabular"))
    end

    def output_hits
      out = config.output_io
      config.formatter.format(@result, out)
      out.close
    end

    def rearrange_alignments
      require 'kofam_scan/output_rearranger'

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

    def check_query_names
      if query_list.find(&:empty?)
        raise Error, "Unnamed query found. Each query must have a unique name."
      elsif (dup_name, _ = query_list.group_by(&:itself).find { |_, v| v.size > 1 })
        raise Error, "Non-unique query name found: #{dup_name}. " \
                     "Each query must have a unique name."
      end
    end

    def parse_hal(hal)
      base_dir = File.dirname(hal)
      IO.foreach(hal).with_object([]) do |line, ary|
        ary << File.expand_path(line.chomp, base_dir) unless line.start_with?("#")
      end
    end
  end
end
