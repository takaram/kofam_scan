class KOHMM
  class HitGenes
    def initialize(hmmsearch_files, threshold_list)
      @hmmsearch_files = hmmsearch_files
      @threshold_list = threshold_list
      @hit_list = Hash.new {|h, k| h[k] = [] }

      parse
    end

    def [](gene)
      @hit_list[gene]
    end

    def each(&block)
      @hit_list.each(&block)
    end

    def has_key?(key)
      @hit_list.has_key?(key)
    end

    alias key? has_key?

    private

    def parse
      @hmmsearch_files.each do |file|
        # base name of `file' is assumed to include K number
        ko = File.basename(file).slice(/K\d{5}/)
        threshold = @threshold_list[ko]
        raise "Could not find the threshold for KO #{ko}" unless threshold

        HmmsearchParser.open(file) do |hmm_parser|
          hmm_parser.parse.each do |result|
            score = threshold.full? ? result.score_full : result.score_domain
            @hit_list[result.name] << [ko, score] if score >= threshold.score
          end
        end
      end

      # no more changes to @hit_list
      freeze_hit_list
    end

    def freeze_hit_list
      @hit_list.default_proc = nil
      @hit_list.each_value(&:freeze)
      @hit_list.freeze
    end
  end
end
