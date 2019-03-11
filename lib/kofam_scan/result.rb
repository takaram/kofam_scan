require 'set'

require 'kofam_scan/result/hit'
require 'kofam_scan/result/parser'

# TODO: alignment
module KofamScan
  class Result
    extend Autoload

    autoload :Hit
    autoload :Parser

    attr_reader :query_list

    def initialize(query_list)
      @hits        = Set.new
      @genes_index = Hash.new { |h, k| h[k] = Set.new }
      @ko_index    = Hash.new { |h, k| h[k] = Set.new }
      @query_list  = query_list
    end

    def parse(*tabular_files)
      Parser.parse(tabular_files, self)
      self
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
