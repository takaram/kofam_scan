module KOHMM
  class Result
    class Hit
      attr_reader :gene_name
      attr_reader :ko
      attr_reader :score
      attr_reader :e_value

      def initialize(gene_name, ko, score, e_value, above_threshold)
        @gene_name       = gene_name
        @ko              = ko.kind_of?(KO) ? ko : KO[ko]
        @score           = score
        @e_value         = e_value
        @above_threshold = above_threshold
      end

      def above_threshold?
        @above_threshold
      end
    end
  end
end
