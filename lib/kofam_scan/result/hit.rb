# frozen_string_literal: true

module KofamScan
  class Result
    class Hit
      attr_reader :gene_name
      attr_reader :ko
      attr_reader :score
      attr_reader :e_value

      def initialize(gene_name, ko, score, e_value)
        @gene_name       = gene_name
        @ko              = ko.kind_of?(KO) ? ko : KO[ko]
        @score           = score
        @e_value         = e_value
      end

      def above_threshold?
        threshold = @ko.threshold
        threshold && @score >= threshold
      end
    end
  end
end
