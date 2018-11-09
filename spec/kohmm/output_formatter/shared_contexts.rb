require 'stringio'

RSpec.shared_context :basic_context do
  let(:result) { KOHMM::Result.new(%w[gene1 gene2 gene3 gene4 gene5]) }
  let(:out_file) { StringIO.new("", "w") }
  let(:ko1) do
    KOHMM::KO.new("K00001", 100, :full, :whole, 0.8, 100, 100, 200, 100,
                  10, 0.5, "alcohol dehydrogenase [EC:1.1.1.1]")
  end
  let(:ko2) do
    KOHMM::KO.new("K00002", 150, :domain, :trim, 0.7, 100, 100, 300, 200,
                  12, 0.5, "alcohol dehydrogenase (NADP+) [EC:1.1.1.2]")
  end
  let(:ko3) do
    KOHMM::KO.new("K00003", 200, :domain, :whole, 0.9, 100, 100, 200, 150,
                  20, 0.5, "homoserine dehydrogenase [EC:1.1.1.3]")
  end

  before { described_class.new.format(result, out_file) }

  def output
    out_file.string.dup
  end
end

RSpec.shared_context 'one hit for one gene' do
  before do
    result << KOHMM::Result::Hit.new("gene1", ko1, 50.1, 0.0009)
    result << KOHMM::Result::Hit.new("gene2", ko2, 180,  0.00005)
    result << KOHMM::Result::Hit.new("gene4", ko3, 200,  1.2e-10)
  end

  include_context :basic_context
end

RSpec.shared_context 'multiple hits for one gene' do
  before do
    result << KOHMM::Result::Hit.new("gene1", ko1, 101, 0.7)
    result << KOHMM::Result::Hit.new("gene1", ko2, 180, 0.5)
    result << KOHMM::Result::Hit.new("gene1", ko3, 20,  0.3)
    result << KOHMM::Result::Hit.new("gene4", ko3, 200, 0.9)
  end

  include_context :basic_context
end

RSpec.shared_context 'multiple hits for one KO' do
  before do
    result << KOHMM::Result::Hit.new("gene1", ko1, 50.1, 0.0009)
    result << KOHMM::Result::Hit.new("gene2", ko1, 180,  0.00005)
    result << KOHMM::Result::Hit.new("gene4", ko2, 200,  1.2e-10)
  end

  include_context :basic_context
end
