class KOHMM
  class ThresholdList
    def initialize(io)
      @list = {}
      io.each_line do |line|
        ko, score, full_or_domain, _ = line.chomp.split
        score = score
        full_or_domain = full_or_domain.to_sym
        add(ko, score, full_or_domain)
      end
    rescue ArgumentError => err
      raise FormatError, err.message + " (at line #{io.lineno})"
    end

    def add(ko, score, full_or_domain)
      @list[ko] = Item.new(ko, score, full_or_domain)
    end

    def [](ko)
      @list[ko]
    end

    def has_key?(ko)
      @list.has_key?(ko)
    end

    alias key? has_key?

    class Item
      attr_reader :ko, :score

      def initialize(ko, score, full_or_domain)
        @ko = ko
        @score = Float(score)

        unless [:full, :domain].include? full_or_domain
          raise ArgumentError, 'Third column must be "full" or "domain"'
        end
        @full_or_domain = full_or_domain
      end

      def full?
        @full_or_domain == :full
      end

      def domain?
        @full_or_domain == :domain
      end
    end
    private_constant :Item

    class FormatError < StandardError
      def initialize(line_no)
        super
      end
    end
  end
end
