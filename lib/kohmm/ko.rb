module KOHMM
  class KO
    def self.[](k_num)
      @instances[k_num]
    end

    def self.parse(ko_file)
      @instances ||= {}
      ko_file.gets
      ko_file.each_line do |line|
        data = line.chomp.split("\t")
        name = data[0]
        @instances[name] = new(*data)
      end
    end

    attr_reader :k_number, :threshold, :score_type, :profile_type, :f_measure,
                :nseq, :nseq_used, :alen, :mlen, :eff_nseq, :re_pos, :definition

    alias name k_number

    def initialize(k_number, threshold, score_type, profile_type, f_measure,
                   nseq, nseq_used, alen, mlen, eff_nseq, re_pos, definition)
      @k_number     = k_number
      @threshold    = threshold.to_f
      @score_type   = score_type.intern
      @profile_type = profile_type.intern
      @f_measure    = f_measure.to_f
      @nseq         = nseq.to_i
      @nseq_used    = nseq_used.to_i
      @alen         = alen.to_i
      @mlen         = mlen.to_i
      @eff_nseq     = eff_nseq.to_f
      @re_pos       = re_pos.to_f
      @definition   = definition
    end
    private_class_method :new

    def full?
      @score_type == :full
    end

    def domain?
      @score_type == :domain
    end

    def whole?
      @profile_type == :whole
    end

    def trim?
      @profile_type == :trim
    end
  end
end
