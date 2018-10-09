module KOHMM
  class ThresholdList
    def initialize(io)
      @list = {}
      io.each do |line|
        ko, score, score_to_use = line.chomp.split
        add(ko, score, score_to_use)
      end
    rescue ArgumentError => err
      raise FormatError, err.message + " (at line #{io.lineno})"
    end

    def add(ko, score, score_to_use)
      @list[ko] = Item.new(ko, score, score_to_use)
    end

    def [](ko)
      @list[ko]
    end

    def has_key?(ko)
      @list.has_key?(ko)
    end

    alias key? has_key?

    def score(ko)
      self[ko].score
    end

    def full?(ko)
      self[ko].full?
    end

    def domain?(ko)
      self[ko].domain?
    end

    class Item
      attr_reader :ko, :score

      def initialize(ko, score, score_to_use)
        @ko = ko
        # Favor `Kernel#Float` over `Object#to_f` because ArgumentError is raised
        # when the format is invalid
        @score = Float(score)
        @score_to_use = score_to_use.to_sym

        unless [:full, :domain].include? @score_to_use
          raise ArgumentError, 'Third column must be "full" or "domain"'
        end
      end

      def full?
        @score_to_use == :full
      end

      def domain?
        @score_to_use == :domain
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
