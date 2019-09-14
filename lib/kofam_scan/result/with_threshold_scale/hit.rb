# frozen_string_literal: true

require 'forwardable'

module KofamScan
  class Result
    class WithThresholdScale
      class Hit
        extend Forwardable

        def_delegators :@hit, :gene_name, :ko, :score, :e_value

        def initialize(hit, scale)
          @hit = hit
          @scale = scale
        end

        def above_threshold?
          threshold = ko.threshold
          return false unless threshold

          # round off because of floating-point error
          scaled_threshold = (threshold * @scale).round(5)
          score >= scaled_threshold
        end
      end
    end
  end
end
