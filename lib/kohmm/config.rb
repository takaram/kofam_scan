autoload :YAML, 'yaml'

class KOHMM
  class Config
    attr_accessor :profile_dir, :threshold_list, :e_value, :hmmsearch,
                  :cpu, :tmp_dir, :hmmsearch_result_dir, :parallel, :query
    # reader for these two attributes are defined later
    attr_writer   :output_file, :reannotation

    def self.load(file)
      file = File.open(file) if file.is_a? String
      hash = YAML.load(file)
      file.close

      self.new(hash)
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

    def score_mode
      @mode = :score
    end

    def score_mode?
      @mode && @mode == :score
    end

    def e_value_mode
      @mode = :e_value
    end

    def e_value_mode?
      @mode && @mode == :e_value
    end
  end
end
