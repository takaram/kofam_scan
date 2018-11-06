require 'set'

# TODO: alignment
module KOHMM
  class Result
    extend Autoload

    autoload :Hit
    autoload :Parser

    def initialize(tabular_files, ko_file)
      @hits        = Set.new
      @genes_index = Hash.new { |h, k| h[k] = Set.new }
      @ko_index    = Hash.new { |h, k| h[k] = Set.new }

      tabular_files = Array(tabular_files)
      Parser.parse(tabular_files, ko_file, self)

      # Freeze this after parsing inputs
      [@hits, @genes_index, @ko_index].each(&:freeze)
      singleton_class.module_eval do
        undef_method :<<
      end
    end

    def each(&block)
      @hits.each(&block)
    end

    def for_gene(gene)
      @genes_index[gene]
    end

    def for_ko(ko)
      @ko_index[ko]
    end

    def <<(hit)
      @hits << hit
      @genes_index[hit.gene_name] << hit
      @ko_index[hit.ko.name] << hit
    end
  end
end
