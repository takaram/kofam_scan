require 'stringio'

RSpec.shared_context 'basic context' do
  subject(:formatter) { described_class.new }

  let(:result) { KofamScan::Result.new(%w[gene1 gene2 gene3 gene4 gene5]) }
  let(:out_file) { StringIO.new("", "w") }
  let(:ko1) do
    KofamScan::KO.new("K00001", 99.52, :full, :all, 0.8, 100, 100, 200, 100,
                      10, 0.5, "alcohol dehydrogenase [EC:1.1.1.1]")
  end
  let(:ko2) do
    KofamScan::KO.new("K00002", 150, :domain, :trim, 0.7, 100, 100, 300, 200,
                      12, 0.5, "alcohol dehydrogenase (NADP+) [EC:1.1.1.2]")
  end
  let(:ko3) do
    KofamScan::KO.new("K00003", 200, :domain, :all, 0.9, 100, 100, 200, 150,
                      20, 0.5, "homoserine dehydrogenase [EC:1.1.1.3]")
  end

  def output
    formatter.format(result, out_file) if out_file.string.empty?
    out_file.string.dup
  end
end

RSpec.shared_context 'one hit for one gene' do
  before do
    result << KofamScan::Result::Hit.new("gene1", ko1, 50.1, 0.0009)
    result << KofamScan::Result::Hit.new("gene2", ko2, 180,  0.00005)
    result << KofamScan::Result::Hit.new("gene4", ko3, 200,  1.2e-10)
  end

  include_context 'basic context'
end

RSpec.shared_context 'multiple hits for one gene' do
  before do
    result << KofamScan::Result::Hit.new("gene1", ko1, 101, 0.7)
    result << KofamScan::Result::Hit.new("gene1", ko2, 180, 0.5)
    result << KofamScan::Result::Hit.new("gene4", ko2, 200, 0.9)
    result << KofamScan::Result::Hit.new("gene1", ko3, 20,  0.3)
  end

  include_context 'basic context'
end

RSpec.shared_context 'multiple hits for one KO' do
  before do
    result << KofamScan::Result::Hit.new("gene1", ko1, 50.1, 0.0009)
    result << KofamScan::Result::Hit.new("gene2", ko1, 180,  0.00005)
    result << KofamScan::Result::Hit.new("gene4", ko2, 200,  1.2e-10)
  end

  include_context 'basic context'
end

RSpec.shared_context 'with a long gene name' do
  include_context 'basic context'

  let(:result) { KofamScan::Result.new([long_name]) }
  let(:name_length) { 100 }
  let(:long_name) { "a" * name_length }

  before do
    result << KofamScan::Result::Hit.new(long_name, ko1, 200, 1e-10)
  end
end

RSpec.shared_examples 'when report_unannotated is false' do |expected|
  include_context 'one hit for one gene'
  before { formatter.report_unannotated = false }

  it 'reports annotated genes only' do
    expect(output).to eq expected
  end
end

RSpec.shared_examples 'when report_unannotated is true' do |expected|
  include_context 'one hit for one gene'
  before { formatter.report_unannotated = true }

  it 'reports all the queries' do
    expect(output).to eq expected
  end
end
