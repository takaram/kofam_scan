RSpec.describe KOHMM::HmmsearchParser do
  let(:parser) { KOHMM::HmmsearchParser.new(file) }
  let(:file_name) { File.expand_path("../test_data/K00001", __dir__) }
  let(:file) { File.open(file_name) }
  count = 6 # number of genes in `file' is 6

  describe '.open' do
    context 'without block' do
      let(:open) { described_class.open(file_name) }

      it 'opens the file and returns HmmsearchParser object' do
        expect(open).to be_an_instance_of described_class
      end
    end

    context 'with block' do
      it 'yields with HmmsearchParser object' do
        expect { |b|
          described_class.open(file_name, &b)
        }.to yield_with_args described_class
      end

      it 'closes the file after the block is called' do
        parser = described_class.open(file_name, &:itself)
        io = parser.instance_variable_get(:@io)
        expect(io).to be_closed
      end
    end
  end

  describe '#parse' do
    it "returns HmmsearchParser::Results" do
      expect(parser.parse).to be_an_instance_of described_class::Results
    end

    it 'closes the file when parse has finished' do
      parser.parse
      expect(file).to be_closed
    end
  end

  describe described_class::Results do
    let(:results) { parser.parse }

    describe '#each' do
      it "iterates #{count} times" do
        expect { |b| results.each(&b) }.to yield_control.exactly(count).times
      end
    end

    describe 'the item of results' do
      let(:item) { results.first }

      it 'has "name" attribute' do
        expect(item.name).to eq "apr:Apre_1614"
      end

      it 'has "ko" attribute' do
        expect(item.ko).to eq "K00001"
      end

      it 'has "score_full" attribute' do
        expect(item.score_full).to eq 170.5
      end

      it 'has "score_domain" attribute' do
        expect(item.score_domain).to eq 170.2
      end
    end
  end
end
