# frozen_string_literal: false

autoload :Shellwords, 'shellwords'

module KofamScan
  class HMMSearch
    class << self
      attr_accessor :command_path
    end

    def initialize(hmmfile, seqdb, options = {})
      @hmmfile = hmmfile
      @seqdb   = seqdb
      @options = options

      @command_array = nil
    end

    def build_command
      return @command_array if @command_array

      @command_array = [command_name]

      @options.each do |key, val|
        @command_array << build_option(key, val) if val
      end

      @command_array.push(@hmmfile, @seqdb)
    end

    alias to_a build_command

    def to_s
      Shellwords.join(build_command)
    end

    private

    def command_name
      self.class.command_path || "hmmsearch"
    end

    def build_option(key, val)
      prefix, connector = key.length == 1 ? ["-", ""] : ["--", "="]

      option = "#{prefix}#{key}"
      option << "#{connector}#{val}" unless val == true
      option
    end
  end
end
