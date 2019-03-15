# frozen_string_literal: true

module KofamScan
  class OutputFormatter
    class SimpleTabularFormatter < OutputFormatter
      def initialize
        @report_unannotated = true
      end

      def format(result, output)
        result.query_list.each do |query|
          ko_list = result.for_gene(query).select(&:above_threshold?)
                          .sort_by(&:score).reverse.map { |hit| hit.ko.name }

          output << query << "\n" if ko_list.empty? && @report_unannotated
          ko_list.each { |ko| output << "#{query}\t#{ko}\n" }
        end
      end
    end
  end
end
