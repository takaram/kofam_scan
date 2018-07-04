class KOHMM
  class HmmsearchParser
    FULL_SCORE_POSITION = 5
    DOMAIN_SCORE_POSITION = 8
    NAME_POSITION = 0
    KO_POSITION = 2

    class << self
      def open(file)
        f = File.open(file)
        parser = new(f)

        if block_given?
          begin
            yield parser
          ensure
            f.close
          end
        else
          parser
        end
      end
    end

    def initialize(io)
      @io = io
    end

    def parse
      results = Results.new
      @io.grep_v(/^#/) do |line|
        name, ko, full, domain =
          line.split.values_at(NAME_POSITION, KO_POSITION,
                               FULL_SCORE_POSITION, DOMAIN_SCORE_POSITION)
        results << {
          name: name, ko: ko, score_full: full.to_f, score_domain: domain.to_f
        }
      end
      @io.close

      results
    end

    class Results
      include Enumerable

      Item = Struct.new(:name, :ko, :score_full, :score_domain)

      def initialize
        @collection = []
      end

      def each(&block)
        @collection.each(&block)
      end

      def <<(item)
        @collection << Item.new(*Item.members.map {|i| item[i] })
      end
    end
  end
end
