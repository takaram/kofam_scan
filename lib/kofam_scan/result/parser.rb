# frozen_string_literal: true

module KofamScan
  class Result
    class Parser
      NAME_POSITION           = 0
      KO_POSITION             = 2
      FULL_SCORE_POSITION     = 5
      DOMAIN_SCORE_POSITION   = 8
      FULL_E_VALUE_POSITION   = 4
      DOMAIN_E_VALUE_POSITION = 7

      def self.parse(tabular_files, result)
        new(tabular_files, result).parse
      end

      # @param [Array] tabular_files Array of IO of result files
      # @param [IO] ko_file
      def initialize(tabular_files, result)
        @tabular_files = tabular_files
        @result        = result
      end

      def parse
        @tabular_files.each do |result_file|
          File.open(result_file) do |f|
            f.grep_v(/^#/).map do |line|
              data = line.split
              name = data[NAME_POSITION]
              ko   = KO[data[KO_POSITION]]

              raise Error, "Unknown KO: #{data[KO_POSITION]}" unless ko

              if ko.domain?
                score   = data[DOMAIN_SCORE_POSITION].to_f
                e_value = data[DOMAIN_E_VALUE_POSITION].to_f
              else
                score   = data[FULL_SCORE_POSITION].to_f
                e_value = data[FULL_E_VALUE_POSITION].to_f
              end

              @result << Hit.new(name, ko, score, e_value)
            end
          end
        end
      end
    end
  end
end
