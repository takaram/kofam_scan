require 'rspec/temp_dir'

RSpec.describe KofamScan::Executor do
  subject(:executor) { described_class.new(config) }

  let(:config) { KofamScan::Config.new }

  describe '#setup_directories' do
    include_context 'uses temp dir'

    shared_examples 'making tabular' do |tmp_path_blk|
      let(:tmp_path, &tmp_path_blk)

      before { config.tmp_dir = tmp_path.to_path }

      it 'makes tmp_dir/tabular' do
        executor.setup_directories
        expect(tmp_path + "tabular").to be_directory
      end
    end

    context 'when tmp_dir is not exist' do
      let(:new_dir) { temp_dir_path + "tmp" }

      before { config.tmp_dir = new_dir.to_path }

      it 'makes tmp_dir' do
        executor.setup_directories
        expect(new_dir).to be_directory
      end

      include_examples 'making tabular', -> { new_dir }
    end

    context 'when create_alignment is true' do
      before do
        config.create_alignment = true
        config.tmp_dir = temp_dir
      end

      it 'makes tmp_dir/output' do
        executor.setup_directories
        expect(temp_dir_path + "output").to be_directory
      end

      it 'makes tmp_dir/alignment' do
        executor.setup_directories
        expect(temp_dir_path + "alignment").to be_directory
      end

      include_examples 'making tabular', -> { temp_dir_path }
    end

    context 'when create_alignment is false' do
      it 'does not make tmp_dir/output' do
        executor.setup_directories
        expect(temp_dir_path + "output").not_to be_exist
      end

      it 'does not make tmp_dir/alignment' do
        executor.setup_directories
        expect(temp_dir_path + "alignment").not_to be_exist
      end

      include_examples 'making tabular', -> { temp_dir_path }
    end
  end

  describe '#lookup_profiles' do
    include_context 'uses temp dir'

    shared_examples 'absolute and relative paths' do |desc, expected_rel, ext|
      let(:expected) do
        expected_rel.map { |x| temp_dir_path.join(x).to_s }
      end

      context 'with absolute paths' do
        it "returns an array #{desc}" do
          profiles = executor.lookup_profiles(temp_dir_path.join("profiles#{ext}").to_s)
          expect(profiles).to match_array(expected)
        end
      end

      context 'with relative paths' do
        include_context 'within temp dir'

        it "returns an array #{desc}" do
          profiles = executor.lookup_profiles("profiles#{ext}")
          expect(profiles).to match_array(expected)
        end
      end
    end

    shared_context 'with profile directory' do
      before do
        prof_dir_path = temp_dir_path + "profiles"
        prof_dir_path.mkdir
        %w[foo.hmm bar.hmm].each do |fname|
          prof_dir_path.join(fname).open("w") {}
        end
      end
    end

    shared_context 'with .hal file' do
      before { IO.write(temp_dir_path + "profiles.hal", "foo.hmm\n./baz.hmm\n") }
    end

    shared_context 'with .hmm file' do
      before { temp_dir_path.join("profiles.hmm").open("w") {} }
    end

    context 'when the argument is a directory' do
      include_context 'with profile directory'

      include_examples 'absolute and relative paths', 'of hmm paths in the directory',
                       %w[profiles/foo.hmm profiles/bar.hmm]

      it 'returns an array including only hmm files' do
        temp_dir_path.join("profiles", "baz.hal").open("w") {}
        profiles = executor.lookup_profiles(temp_dir_path.join("profiles").to_s)
        expected = %w[foo.hmm bar.hmm].map { |x| temp_dir_path.join("profiles", x).to_s }

        expect(profiles).to match_array(expected)
      end
    end

    context 'when the argument is .hal file' do
      context 'without comment lines' do
        include_context 'with .hal file'
        include_examples 'absolute and relative paths',
                         'of hmm paths written in the file', %w[foo.hmm baz.hmm]
      end

      context 'with comment lines' do
        before { IO.write("#{temp_dir}/profiles.hal", <<~HAL) }
          # comment
          foo.hmm
          # another comment
          #
          ./#bar.hmm
        HAL

        include_examples 'absolute and relative paths',
                         'of hmm paths written in the file', %w[foo.hmm #bar.hmm]
      end

      context 'with extension in the argument' do
        include_context 'with .hal file'
        include_examples 'absolute and relative paths',
                         'of hmm paths written in the file', %w[foo.hmm baz.hmm], '.hal'
      end
    end

    context 'when the argument is .hmm file' do
      include_context 'with .hmm file'
      include_examples 'absolute and relative paths',
                       "containing only the hmm's path", ['profiles.hmm']

      context 'with extension in the argument' do
        include_examples 'absolute and relative paths',
                         "containing only the hmm's path", ['profiles.hmm'], '.hmm'
      end
    end

    context 'when the argument file does not exist' do
      include_context 'within temp dir'

      it 'raises an error' do
        expect { executor.lookup_profiles("foo") }.to raise_error(/Database not found/)
      end
    end

    context 'when .hal, .hmm and directory exist' do
      include_context 'with .hal file'
      include_context 'with .hmm file'
      include_context 'with profile directory'

      include_examples 'absolute and relative paths', 'of hmm paths in the directory',
                       %w[profiles/foo.hmm profiles/bar.hmm]
    end

    context 'when .hal and .hmm exist' do
      include_context 'with .hal file'
      include_context 'with .hmm file'

      include_examples 'absolute and relative paths',
                       'of hmm paths in .hal file', %w[foo.hmm baz.hmm]
    end
  end
end
