RSpec.describe KOHMM::CLI do
  describe '.run' do
    context 'with -h or --help option' do
      it 'prints help message' do
        %w[-h --help].each do |option|
          expect { KOHMM::CLI.run([option]) }.to output(/\AUsage/i).to_stdout
        end
      end

      it 'terminates the script' do
        %w[-h --help].each do |option|
          expect { KOHMM::CLI.run([option]) }.to exit_script.successfully
        end
      end
    end

    context 'without help option' do
      it 'invokes KOHMM::Executor.execute' do
        expect(KOHMM::Executor).to receive(:execute)
        KOHMM::CLI.run(['query'])
      end
    end

    context 'with invalid options' do
      before do
        allow_any_instance_of(KOHMM::OptionParser).to(
          receive(:parse!).and_raise(::OptionParser::ParseError)
        )
      end

      it 'shows usage to stderr' do
        expect { KOHMM::CLI.run(['query']) }.to output(/Usage/i).to_stderr
      end

      it 'exits with exit status > 0' do
        expect { KOHMM::CLI.run(['query']) }.to exit_script.unsuccessfully
      end
    end

    context 'without query' do
      it 'shows an error message to stderr and' do
        expect { KOHMM::CLI.run(%w[-o out_file]) }.to output(/specify a query/i).to_stderr
      end

      it 'exits with exit status > 0' do
        expect { KOHMM::CLI.run(%w[-o out_file]) }.to exit_script.unsuccessfully
      end
    end

    context 'with too many args' do
      it 'shows an error message to stderr' do
        expect { KOHMM::CLI.run(%w[-o out_file]) }.to output(/too many/i).to_stderr
      end

      it 'exits with exit status > 0' do
        expect { KOHMM::CLI.run(%w[-o out_file]) }.to exit_script.unsuccessfully
      end
    end
  end
end
