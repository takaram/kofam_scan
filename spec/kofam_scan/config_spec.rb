require 'rspec/its'
require 'tempfile'

RSpec.describe KofamScan::Config do
  let(:config) { described_class.new }

  describe 'default values' do
    subject { config }

    its(:output_file)   { is_expected.to be_nil }
    its(:output_io)     { is_expected.to eq STDOUT }
    its(:cpu)           { is_expected.to eq 1 }
    its(:tmp_dir)       { is_expected.to eq "./tmp" }
    its(:parallel)      { is_expected.to be_nil }
    its(:reannotation?) { is_expected.to be_falsy }
    its(:formatter)     { is_expected.to be_kind_of KofamScan::OutputFormatter::HitDetailFormatter }
    its(:create_alignment?) { is_expected.to be_falsy }
  end

  describe 'initial values are passed to #initialize' do
    init_values = {
      output_file: "file",
      profile:     "dir",
      ko_list:     "file2",
      e_value:     0.1,
      cpu:         5,
      hmmsearch:   "/usr/local/bin/hmmsearch",
      tmp_dir:     "/tmp",
      parallel:    "/usr/local/bin/parallel",
      formatter:   KofamScan::OutputFormatter::SimpleTabularFormatter.new
    }
    subject { described_class.new(init_values) }

    init_values.each do |key, val|
      its(key) { is_expected.to eq val }
    end
  end

  describe '.load' do
    let(:yaml_str) {
      "profile: dir
       ko_list: file
       cpu: 10
       hmmsearch: /usr/local/bin/hmmsearch".gsub(/^\s+/, "")
    }

    shared_examples 'test attributes of loaded config' do
      it 'loads configuration from the argument' do
        aggregate_failures do
          expect(loaded_config.profile).to eq "dir"
          expect(loaded_config.ko_list).to eq "file"
          expect(loaded_config.cpu).to eq 10
          expect(loaded_config.hmmsearch).to eq "/usr/local/bin/hmmsearch"
        end
      end
    end

    context 'when the argument is an IO object' do
      let(:io) { StringIO.new(yaml_str) }
      let(:loaded_config) { described_class.load(io) }

      include_examples 'test attributes of loaded config'
    end

    context 'when the argument is a string' do
      let(:tmp_file) { Tempfile.open { |f| f.puts yaml_str; f } }
      let(:loaded_config) { described_class.load(tmp_file.path) }

      after { tmp_file.close }

      include_examples 'test attributes of loaded config'
    end
  end

  describe 'attributes' do
    describe '#output_file' do
      subject(:output_file) { config.output_file }

      it 'returns the file name' do
        file = "foo"
        config.output_file = file
        expect(output_file).to eq file
      end
    end

    %i[profile ko_list hmmsearch tmp_dir parallel query].each do |attr|
      describe "##{attr} and ##{attr}=" do
        it 'can set and get a value' do
          path = "/path/to/file"
          eval <<~CODE, binding, __FILE__, __LINE__ + 1
            config.#{attr} = path
            expect(config.#{attr}).to eq path
          CODE
        end
      end
    end

    describe '#e_value and #e_value=' do
      it 'can set and get a value' do
        config.e_value = 1e-5
        expect(config.e_value).to eq 1e-5
      end
    end

    describe '#threshold_scale and #threshold_scale=' do
      it 'can set and get a value' do
        config.threshold_scale = 1.1
        expect(config.threshold_scale).to eq 1.1
      end
    end

    describe '#cpu and #cpu=' do
      it 'can set and get a value' do
        config.cpu = 2
        expect(config.cpu).to eq 2
      end
    end

    describe '#reannotation? and #reannnotation=' do
      it 'can set and get a boolean' do
        config.reannotation = true
        expect(config).to be_reannotation
      end
    end

    describe '#create_alignment? and #create_alignment=' do
      it 'can set and get a boolean' do
        config.create_alignment = true
        expect(config).to be_create_alignment
      end
    end
  end

  describe '#output_io' do
    subject(:output_io) { config.output_io }

    after { output_io.close unless output_io == $stdout }

    context 'when output_file is nil' do
      it 'returns stdout' do
        config.output_file = nil
        expect(output_io).to eq STDOUT
      end
    end

    context 'when output_file is specified by a file name' do
      let(:tempfile) { Tempfile.new }
      let(:path)     { tempfile.path }

      after { tempfile.close! }

      it 'returns the file IO' do
        config.output_file = path
        output_io.write "test"
        output_io.flush
        expect(IO.read(path)).to eq "test"
      end
    end
  end
end
