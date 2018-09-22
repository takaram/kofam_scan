autoload :YAML, 'yaml'

module KOHMM
  class Config
    attr_accessor :profile_dir, :threshold_list, :e_value, :hmmsearch,
                  :cpu, :tmp_dir, :hmmsearch_result_dir, :parallel, :query
    # reader for these two attributes are defined later
    attr_writer   :output_file, :reannotation

    def self.load(file)
      file = File.open(file) if file.kind_of? String
      hash = YAML.safe_load(file)
      file.close

      new(hash)
    end

    def initialize(initial_values = {})
      @output_file = "-"
      @cpu = 1
      @tmp_dir = "./tmp"
      @hmmsearch = "hmmsearch"
      @mode = :score
      @reannotation = false

      initial_values.each do |k, v|
        public_send(:"#{k}=", v)
      end
    end

    # when @output_file == "-", this method returns 1 (stdout file descriptor)
    # so that you can give it to Kernel#open as an argument
    def output_file
      @output_file == "-" ? 1 : @output_file
    end

    def reannotation?
      !!@reannotation
    end
  end
end
