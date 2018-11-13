require 'rspec/its'
require 'tempfile'

RSpec.describe KOHMM::Config do
  let(:config) { described_class.new }

  describe 'default values' do
    subject { config }

    its(:output_file) { is_expected.to eq 1 }
    its(:cpu) { is_expected.to eq 1 }
    its(:hmmsearch) { is_expected.to eq "hmmsearch" }
    its(:tmp_dir) { is_expected.to eq "./tmp" }
    its(:parallel) { is_expected.to be_nil }
    its(:reannotation?) { is_expected.to be_falsey }
  end

  describe 'initial values are passed to #initialize' do
    init_values = {
      output_file:          "file",
      profile_dir:          "dir",
      threshold_list:       "file2",
      e_value:              0.1,
      cpu:                  5,
      hmmsearch:            "/usr/local/bin/hmmsearch",
      tmp_dir:              "/tmp",
      hmmsearch_result_dir: "dir2",
      parallel:             "/usr/local/bin/parallel",
    }
    subject { described_class.new(init_values) }

    init_values.each do |key, val|
      its(key) { is_expected.to eq val }
    end
  end

  describe '.load' do
    let(:yaml_str) {
      "profile_dir: dir
       threshold_list: file
       cpu: 10
       hmmsearch: /usr/local/bin/hmmsearch".gsub(/^\s+/, "")
    }

    shared_examples 'test attributes of loaded config' do
      it 'loads configuration from the argument' do
        aggregate_failures do
          expect(loaded_config.profile_dir).to eq "dir"
          expect(loaded_config.threshold_list).to eq "file"
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
      context 'when output_file = "-"' do
        it 'returns 1' do
          config.output_file = "-"
          expect(config.output_file).to eq 1
        end
      end

      context 'when output_file is specified by a file name' do
        it 'returns the file name' do
          file = "foo"
          config.output_file = file
          expect(config.output_file).to eq file
        end
      end
    end

    %i[profile_dir threshold_list hmmsearch
       tmp_dir hmmsearch_result_dir parallel query].each do |attr|
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
  end
end
