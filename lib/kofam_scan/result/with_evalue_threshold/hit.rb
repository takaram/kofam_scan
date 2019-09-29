# frozen_string_literal: true

require 'forwardable'

module KofamScan
  class Result
    class WithEvalueThreshold
      class Hit
        extend Forwardable

        def_delegators :@hit, :gene_name, :ko, :score, :e_value

        def initialize(hit, threshold)
          @hit = hit
          @threshold = threshold
        end

        def above_threshold?
          e_value <= @threshold && @hit.above_threshold?
        end
      end
    end
  end
end
