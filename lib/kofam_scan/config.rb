autoload :YAML, 'yaml'

module KofamScan
  class Config
    attr_accessor :output_file, :profile, :ko_list, :e_value, :hmmsearch, :cpu,
                  :tmp_dir, :parallel, :formatter, :query
    attr_writer   :reannotation, :create_alignment

    def self.load(file)
      file = File.open(file) if file.kind_of? String
      hash = YAML.safe_load(file)
      file.close

      new(hash)
    end

    def initialize(initial_values = {})
      @output_file = nil
      @cpu = 1
      @tmp_dir = "./tmp"
      @hmmsearch = "hmmsearch"
      @mode = :score
      @reannotation = false
      @formatter = OutputFormatter::HitDetailFormatter.new
      @create_alignment = false

      initial_values.each do |k, v|
        public_send(:"#{k}=", v)
      end
    end

    def output_io
      @output_file ? File.open(@output_file, "w") : STDOUT
    end

    def reannotation?
      !!@reannotation
    end

    def create_alignment?
      !!@create_alignment
    end
  end
end
