# frozen_string_literal: true

module KofamScan
  class Result
    class WithEvalueThreshold < Result
      require 'kofam_scan/result/with_evalue_threshold/hit'

      def initialize(query_list, e_value_threshold)
        super(query_list)
        @threshold = e_value_threshold
      end

      def <<(hit)
        wrapped_hit = Hit.new(hit, @threshold)
        super(wrapped_hit)
      end
    end
  end
end
