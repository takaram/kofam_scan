# frozen_string_literal: true

module KofamScan
  Config = Struct.new(:output_file, :profile, :ko_list, :e_value, :hmmsearch,
                      :cpu, :tmp_dir, :parallel, :formatter, :reannotation,
                      :threshold_scale, :create_alignment, :keep_output,
                      :keep_tabular, :query) do
    def self.load(file)
      require 'yaml'
      file = File.open(file) if file.kind_of? String
      hash = YAML.safe_load(file)
      file.close

      new(hash)
    end

    def initialize(initial_values = {})
      initial_values = {
        cpu:              1,
        tmp_dir:          "./tmp",
        reannotation:     false,
        formatter:        OutputFormatter::HitDetailFormatter.new,
        create_alignment: false,
        keep_output:      false,
        keep_tabular:     false
      }.merge(initial_values.map { |k, v| [k.intern, v] }.to_h)

      super(*members.map { |k| initial_values[k] })
    end

    def output_io
      output_file ? File.open(output_file, "w") : STDOUT
    end

    alias reannotation? reannotation

    alias create_alignment? create_alignment

    alias keep_output? keep_output

    alias keep_tabular? keep_tabular
  end
end
