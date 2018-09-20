RSpec.describe KOHMM::CLI::OptionParser do
  let(:parser) { described_class.new(config) }
  let(:config) { KOHMM::Config.new }

  describe '-o option' do
    it 'calls config.output_file=' do
      file_name = "hoge"
      expect(config).to receive(:output_file=).with file_name
      parser.parse!(["-o", file_name])
    end
  end

  describe '-p option' do
    it 'calls config.profile_dir=' do
      dir_name = "fuga"
      expect(config).to receive(:profile_dir=).with dir_name
      parser.parse!(["-p", dir_name])
    end
  end

  describe '-t option' do
    let(:file_name) { "foo" }

    it 'calls config.threshold_list=' do
      expect(config).to receive(:threshold_list=).with file_name
      parser.parse!(["-t", file_name])
    end

    xit 'enables score_mode' do
      expect(config).to receive(:score_mode)
      parser.parse!(["-t", file_name])
    end
  end

  xdescribe '-E option' do
    let(:value) { "1e-2" }

    it 'calls config.e_value=' do
      expect(config).to receive(:e_value=).with value.to_f
      parser.parse!(["-E", value])
    end

    it 'enables e_value_mode' do
      expect(config).to receive(:e_value_mode)
      parser.parse!(["-E", value])
    end

    context 'argument is not a number' do
      it 'fails to parse' do
        expect { parser.parse!(["-E", "string"]) }
          .to raise_error OptionParser::InvalidArgument
      end
    end
  end

  describe '--cpu option' do
    it 'calls config.cpu=' do
      expect(config).to receive(:cpu=)
      parser.parse!(["--cpu=5"])
    end
  end

  describe '--tmp_dir option' do
    it 'calls config.tmp_dir=' do
      dir = "foo"
      expect(config).to receive(:tmp_dir=).with dir
      parser.parse!(["--tmp_dir", dir])
    end
  end

  describe '-r option' do
    it 'calls config.hmmsearch_result_dir=' do
      dir = "bar"
      expect(config).to receive(:hmmsearch_result_dir=).with dir
      parser.parse!(["-r", dir])
    end

    it 'calls config.reannotation = true' do
      expect(config).to receive(:reannotation=).with true
      parser.parse!(["-r", "bar"])
    end
  end

  describe '#parse!' do
    let(:opt_array) { %w[-o file1 -p dir1 -t file2 --cpu=1] }

    context 'without arguments' do
      it 'changes ARGV' do
        stub_const("ARGV", opt_array)
        expect { parser.parse! }.to change { opt_array.size }.from(7).to(0)
      end
    end

    context 'with an argument' do
      it 'changes the argument array' do
        expect { parser.parse!(opt_array) }.to change { opt_array.size }.from(7).to(0)
      end
    end
  end
end
