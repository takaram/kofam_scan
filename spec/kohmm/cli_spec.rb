RSpec.describe KOHMM::CLI do
  describe '.run' do
    subject(:execute_run) { described_class.run(options) }

    let(:options) { ["query"] }

    before do
      allow(KOHMM::Executor).to receive(:execute)
    end

    context 'with -h or --help option' do
      it 'prints help message and exit' do
        %w[-h --help].each do |option|
          expect { described_class.run([option]) }.to output(/\AUsage/i).to_stdout.and exit_script.successfully
        end
      end
    end

    context 'without help option' do
      context 'with vaild arguments' do
        context 'with config file' do
          unless File.exist?(KOHMM::DEFAULT_CONFIG_FILE)
            around do |example|
              IO.write(KOHMM::DEFAULT_CONFIG_FILE, "cpu: 1\n")
              example.run
              File.delete(KOHMM::DEFAULT_CONFIG_FILE)
            end
          end

          it 'invokes KOHMM::Executor.execute' do
            expect(KOHMM::Executor).to receive(:execute)
            described_class.run(options)
          end
        end

        context 'without config file' do
          if File.exist?(KOHMM::DEFAULT_CONFIG_FILE)
            include_context 'uses temp dir'
            around do |example|
              tmp_file = File.expand_path("tmp", temp_dir)
              File.rename(KOHMM::DEFAULT_CONFIG_FILE, tmp_file)
              example.run
              File.rename(tmp_file, KOHMM::DEFAULT_CONFIG_FILE)
            end
          end

          it 'invokes KOHMM::Executor.execute' do
            expect(KOHMM::Executor).to receive(:execute)
            described_class.run(options)
          end
        end
      end

      context 'with invalid options' do
        before do
          allow_any_instance_of(KOHMM::CLI::OptionParser).to(
            receive(:parse!).and_raise(::OptionParser::ParseError)
          )
        end

        it 'shows usage to stderr and exit with error' do
          expect { execute_run }.to output(/Usage/i).to_stderr.and exit_script.unsuccessfully
        end
      end

      context 'without query' do
        let(:options) { %w[-o out_file] }

        it 'shows an error message to stderr and exit with error' do
          expect { execute_run }.to output(/specify a query/i).to_stderr.and exit_script.unsuccessfully
        end
      end

      context 'with too many args' do
        let(:options) { %w[file_a file_b] }

        it 'shows an error message to stderr and exit with error' do
          expect { execute_run }.to output(/too many/i).to_stderr.and exit_script.unsuccessfully
        end
      end
    end
  end
end
