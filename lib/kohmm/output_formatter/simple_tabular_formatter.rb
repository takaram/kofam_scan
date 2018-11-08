module KOHMM
  module OutputFormatter
    class SimpleTabularFormatter
      def format(result, output)
        result.query_list.each do |query|
          hit = result.for_gene(query).select(&:above_threshold?).max_by(&:score)
          output << (hit ? "#{query}\t#{hit.ko.name}" : query) << "\n"
        end
      end
    end
  end
end
