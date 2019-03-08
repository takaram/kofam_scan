module KofamScan
  class OutputFormatter
    class SimpleTabularFormatter < OutputFormatter
      def initialize
        @report_unannotated = true
      end

      def format(result, output)
        result.query_list.each do |query|
          hit = result.for_gene(query).select(&:above_threshold?).max_by(&:score)
          if hit
            output << "#{query}\t#{hit.ko.name}\n"
          elsif @report_unannotated
            output << query << "\n"
          end
        end
      end
    end
  end
end
