# frozen_string_literal: true

module KofamScan
  class OutputFormatter
    class HitDetailTsvFormatter < OutputFormatter
      def initialize
        @report_unannotated = false
      end

      def format(result, output)
        @max_query_name_length = result.query_list.map(&:size).max

        output << header
        result.query_list.each do |query|
          hits = result.for_gene(query)
          if hits.empty?
            output << format_empty_hit(query) << "\n" if @report_unannotated
            next
          end

          hits.sort_by(&:score).reverse_each do |hit|
            output << format_hit(hit) << "\n"
          end
        end
      end

      private

      def template
        @template ||= "%s\t%s\t%s\t%.2f\t%.1f\t%.2g\t\"%s\""
      end

      def template_for_string
        template.gsub(/\.\d+[fg]/, "s")
      end

      def template_for_empty
        @template_for_empty ||= "%s\t%s\t%s\t%s\t%s\t%s\t%s"
      end

      def header
        "#{header_first_line}\n#{header_delimiter_line}\n"
      end

      def header_first_line
        template_for_string % %w[# gene\ name KO thrshld score E-value KO\ definition]
      end

      def header_delimiter_line
        lengths = [9, 6, 7, 6, 9, 13]
        "#\t" + lengths.map { |i| '-' * i }.join("\t")
      end

      def format_hit(hit)
        if (threshold = hit.ko.threshold)
          mark = hit.above_threshold? ? '*' : nil
          tmpl = template
        else
          mark = nil
          threshold = ""

          template_array = template.split("\t")
          template_array[3] = "%s"
          tmpl = template_array.join("\t")
        end

        tmpl % [mark, hit.gene_name, hit.ko.name, threshold,
                hit.score, hit.e_value, hit.ko.definition.gsub(/\"/, '""')]
      end

      def format_empty_hit(query)
        template_for_empty % ([nil, query] + [nil] * 5)
      end
    end
  end
end
