module KOHMM
  module OutputFormatter
    class HitDetailFormatter
      COLUMN_WIDTH = {
        gene_name:     20,
        ko:             6,
        score:          6,
        e_value:        9,
        ko_definition: 21
      }
      private_constant :COLUMN_WIDTH

      def format(result, output)
        output << header
        result.each do |hit|
          output << format_hit(hit) << "\n"
        end
      end

      private

      def header
        "#{header_first_line}\n#{header_delimiter_line}\n"
      end

      def header_first_line
        template = "# %-#{COLUMN_WIDTH[:gene_name]}s %-#{COLUMN_WIDTH[:ko]}s " \
                   "%#{COLUMN_WIDTH[:score]}s %#{COLUMN_WIDTH[:e_value]}s %-s"
        template % %w[gene\ name KO score E-value KO\ definition]
      end

      def header_delimiter_line
        "#-" +
          COLUMN_WIDTH.values_at(:gene_name, :ko, :score, :e_value, :ko_definition)
                      .map { |i| '-' * i }.join(' ')
      end

      def format_hit(hit)
        
      end
    end
  end
end
