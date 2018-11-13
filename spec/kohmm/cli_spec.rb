RSpec.describe KOHMM::CLI do
  describe '.run' do
    subject { described_class.run(options) }

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
        it 'invokes KOHMM::Executor.execute' do
          expect(KOHMM::Executor).to receive(:execute)
          described_class.run(options)
        end
      end

      context 'with invalid options' do
        before do
          allow_any_instance_of(KOHMM::CLI::OptionParser).to(
            receive(:parse!).and_raise(::OptionParser::ParseError)
          )
        end

        it 'shows usage to stderr and exit with error' do
          expect { subject }.to output(/Usage/i).to_stderr.and exit_script.unsuccessfully
        end
      end

      context 'without query' do
        let(:options) { %w[-o out_file] }

        it 'shows an error message to stderr and exit with error' do
          expect { subject }.to output(/specify a query/i).to_stderr.and exit_script.unsuccessfully
        end
      end

      context 'with too many args' do
        let(:options) { %w[file_a file_b] }

        it 'shows an error message to stderr and exit with error' do
          expect { subject }.to output(/too many/i).to_stderr.and exit_script.unsuccessfully
        end
      end
    end
  end
end
