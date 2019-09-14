require 'kofam_scan/cli'

RSpec.describe KofamScan::CLI::OptionParser do
  let(:parser) { described_class.new(config) }
  let(:config) { KofamScan::Config.new }

  describe '-o option' do
    it 'calls config.output_file=' do
      file_name = "hoge"
      expect(config).to receive(:output_file=).with file_name
      parser.parse!(["-o", file_name])
    end
  end

  describe '-f option' do
    it 'calls config.formatter=' do
      formatter = KofamScan::OutputFormatter::HitDetailFormatter
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

  describe '--tmp-dir option' do
    it 'calls config.tmp_dir=' do
      dir = "foo"
      expect(config).to receive(:tmp_dir=).with dir
      parser.parse!(["--tmp-dir", dir])
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

  describe '--create-alignment option' do
    it 'calls config.create_alignment=' do
      expect(config).to receive(:create_alignment=).with true
      parser.parse!(["--create-alignment"])
    end
  end

  describe '-E option' do
    it 'calls config.e_value=' do
      e_value = 0.01
      expect(config).to receive(:e_value=).with e_value
      parser.parse!(['-E', e_value.to_s])
    end
  end

  describe '-T option' do
    it 'calls config.threshold_scale=' do
      scale = 1.1
      expect(config).to receive(:threshold_scale=).with scale
      parser.parse!(['-T', scale.to_s])
    end
  end

  describe '#parse!' do
    let(:opt_array) { %w[-o file1 -p dir1 --tmp-dir file2 --cpu=1] }

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
