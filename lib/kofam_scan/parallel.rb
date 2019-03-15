# frozen_string_literal: true

require 'open3'
autoload :Shellwords, 'shellwords'

module KofamScan
  class Parallel
    attr_accessor :cpu, :command, :inputs

    def initialize(cpu: 1, command: nil, inputs: nil, full_path: nil)
      @cpu = cpu
      @command = command
      @inputs = inputs
      @full_path = full_path
    end

    def build_command
      raise Error, "Command not set" unless command

      result = [parallel_command, "-j", cpu, "--quote"]
      command_arr = command.kind_of?(Array) ? command : Shellwords.split(command)
      result.concat(command_arr)
      result.map(&:to_s)
    end

    def exec
      Open3.popen3(*build_command) do |stdin, out, err, thread|
        stdin.puts @inputs if @inputs
        stdin.close
        @success = thread.value.success?

        [out.read, err.read]
      end
    end

    def parallel_command
      @full_path || "parallel"
    end

    def success?
      @success
    end
  end
end
