module KOHMM
  module OutputFormatter
    class MultiHitTabularFormatter
      def format(result, output)
        result.query_list.each do |query|
          ko_list = result.for_gene(query).select(&:above_threshold?)
                          .sort_by(&:score).reverse.map { |hit| hit.ko.name }
          output << [query, *ko_list].join("\t") << "\n"
        end
      end
    end
  end
end
