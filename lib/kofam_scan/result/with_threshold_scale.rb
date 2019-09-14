# frozen_string_literal: true

module KofamScan
  class Result
    class WithThresholdScale < Result
      require 'kofam_scan/result/with_threshold_scale/hit'

      def initialize(query_list, scale)
        super(query_list)
        @scale = scale
      end

      def <<(hit)
        wrapped_hit = Hit.new(hit, @scale)
        super(wrapped_hit)
      end
    end
  end
end
