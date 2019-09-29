# frozen_string_literal: true

require 'kofam_scan/result/hit'
require 'kofam_scan/result/parser'

# TODO: alignment
module KofamScan
  class Result
    extend Autoload

    autoload :WithEvalueThreshold
    autoload :WithThresholdScale
    autoload :WithThresholdScaleAndEvalueThreshold

    def self.create(query_list, threshold_scale: nil, e_value_threshold: nil)
      if threshold_scale && e_value_threshold
        WithThresholdScaleAndEvalueThreshold.new(query_list, threshold_scale, e_value_threshold)
      elsif e_value_threshold
        WithEvalueThreshold.new(query_list, e_value_threshold)
      elsif threshold_scale
        WithThresholdScale.new(query_list, threshold_scale)
      else
        Result.new(query_list)
      end
    end

    attr_reader :query_list

    def initialize(query_list)
      @hits        = []
      @genes_index = Hash.new { |h, k| h[k] = [] }
      @ko_index    = Hash.new { |h, k| h[k] = [] }
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
