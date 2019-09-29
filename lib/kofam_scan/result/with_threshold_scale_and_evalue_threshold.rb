# frozen_string_literal: true

module KofamScan
  class Result
    class WithThresholdScaleAndEvalueThreshold < Result
      require 'kofam_scan/result/with_threshold_scale_and_evalue_threshold/hit'

      def initialize(query_list, scale, e_val_threshold)
        super(query_list)
        @scale = scale
        @threshold = e_val_threshold
      end

      def <<(hit)
        wrapped_hit = Hit.new(hit, @scale, @threshold)
        super(wrapped_hit)
      end
    end
  end
end
