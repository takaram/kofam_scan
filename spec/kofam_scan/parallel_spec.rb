RSpec.describe KofamScan::Parallel do
  describe '#parallel_command' do
    context 'when full path is fed' do
      it 'returns the path' do
        path = "/usr/local/bin/parallel"
        obj = described_class.new(full_path: path, command: "some_cmd")
        expect(obj.parallel_command).to eq path
      end
    end

    context 'when full path is not fed' do
      it 'returns "parallel"' do
        obj = described_class.new(command: "some_cmd")
        expect(obj.parallel_command).to eq "parallel"
      end
    end
  end

  describe '#build_command' do
    subject(:built_command) {
      described_class.new(cpu: 2, command: cmd).build_command
    }

    let(:cmd) { "some_command {}" }

    it "includes -j n" do
      expect(built_command).to satisfy { |array|
        array.each_cons(2).any? { |a| a == %w[-j 2] }
      }
    end

    it 'includes the command' do
      expect(built_command).to include(*cmd.split)
    end

    it 'starts with parallel_command' do
      expect(built_command.first).to eq "parallel"
    end

    it 'raises error when command is not set' do
      expect { described_class.new.build_command }.to raise_error KofamScan::Error
    end
  end

  describe '#exec' do
    it "runs parallel and returns an array of stdout/stderr string" do
      parallel = described_class.new(command: "echo {} {}", inputs: "a\nb")
      out, err = parallel.exec

      expect(out).to eq "a a\nb b\n"
      expect(err).to eq ""
    end
  end
end
