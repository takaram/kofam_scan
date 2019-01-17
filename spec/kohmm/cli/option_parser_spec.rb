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

  describe '-f option' do
    it 'calls config.formatter=' do
      formatter = KOHMM::OutputFormatter::HitDetailFormatter
      expect(config).to receive(:formatter=).with kind_of(formatter)
      parser.parse!(["-f", "detail"])
    end
  end

  describe '-p option' do
    it 'calls config.profile=' do
      dir_name = "fuga"
      expect(config).to receive(:profile=).with dir_name
      parser.parse!(["-p", dir_name])
    end
  end

  describe '-k option' do
    let(:file_name) { "foo" }

    it 'calls config.ko_list=' do
      expect(config).to receive(:ko_list=).with file_name
      parser.parse!(["-k", file_name])
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
    it 'calls config.reannotation = true' do
      expect(config).to receive(:reannotation=).with true
      parser.parse!(["-r", "bar"])
    end
  end

  describe '--[no-]report-unannotated' do
    context 'without no- prefix' do
      it 'calls formatter.report_unannotated= with true' do
        config.formatter = object_double(config.formatter, 'report_unannotated=': true)
        parser.parse!(["--report-unannotated"])

        expect(config.formatter).to have_received(:report_unannotated=).with true
      end
    end

    context 'with no- prefix' do
      it 'calls formatter.report_unannotated= with false' do
        config.formatter = object_double(config.formatter, 'report_unannotated=': false)
        parser.parse!(["--no-report-unannotated"])

        expect(config.formatter).to have_received(:report_unannotated=).with false
      end
    end

    context 'with -f option' do
      it 'correctly sets report_unannotated' do
        parser.parse!(["--no-report-unannotated", "-f", "mapper"])
        expect(config.formatter.report_unannotated).to be_falsey
      end
    end
  end

  describe '--create-domain-alignment option' do
    it 'calls config.create_domain_alignment=' do
      expect(config).to receive(:create_domain_alignment=).with true
      parser.parse!(["--create-domain-alignment"])
    end
  end

  describe '#parse!' do
    let(:opt_array) { %w[-o file1 -p dir1 -t file2 --cpu=1] }

    context 'without arguments' do
      it 'changes ARGV' do
        stub_const("ARGV", opt_array)
        expect { parser.parse! }.to change(opt_array, :size).from(7).to(0)
      end
    end

    context 'with an argument' do
      it 'changes the argument array' do
        expect { parser.parse!(opt_array) }.to change(opt_array, :size).from(7).to(0)
      end
    end
  end
end
