# frozen_string_literal: true

module KofamScan
  class OutputFormatter
    class OneLineTabularFormatter < OutputFormatter
      def initialize
        @report_unannotated = true
      end

      def format(result, output)
        result.query_list.each do |query|
          ko_list = result.for_gene(query).select(&:above_threshold?)
                          .sort_by(&:score).reverse.map { |hit| hit.ko.name }
          next if ko_list.empty? && !@report_unannotated

          output << [query, *ko_list].join("\t") << "\n"
        end
      end
    end
  end
end
