# frozen_string_literal: false

module KofamScan
  class OutputRearranger
    def initialize(from_dir, to_dir)
      @from_dir = from_dir
      @to_dir   = to_dir
      @gene2aln = Hash.new { |h, k| h[k] = [] }

      @current_ko, @current_gene, @current_alignment = nil
    end

    def rearrange
      parse_files
      write_to_files
    end

    private

    def parse_files
      Dir.glob(File.join(@from_dir, "K*")) do |file|
        parse(file)
      end
    end

    def parse(file)
      IO.foreach(file) do |line|
        case line
        when /^Query:\s*(\S+)/
          @current_ko = KO[Regexp.last_match[1]]
        when /^>> (\S+)/
          push_alignment
          @current_gene = Regexp.last_match[1]
          @current_alignment = ">> #{@current_ko.name} #{@current_ko.definition}\n"
        when "Internal pipeline statistics summary:\n"
          2.times { @current_alignment.chomp! }
          push_alignment
        when /\[No hits detected that satisfy reporting thresholds\]/
          break
        else
          @current_alignment << line if @current_alignment
        end
      end
    end

    def push_alignment
      return unless @current_gene

      @gene2aln[@current_gene] << @current_alignment
      @current_gene, @current_alignment = nil
    end

    def write_to_files
      @gene2aln.each do |gene, alignments|
        File.open(File.join(@to_dir, gene), 'w') do |f|
          f.print "Sequence: #{gene}\n\n"
          f.print(*alignments)
        end
      end
    end
  end
end
