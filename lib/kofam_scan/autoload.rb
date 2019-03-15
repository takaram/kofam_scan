# frozen_string_literal: true

module KofamScan
  module Autoload
    def autoload(const_name, path = nil)
      unless path
        dirs = name.split("::").push(const_name.to_s)
        dirs.map!(&method(:snake_case))
        path = dirs.join("/")
      end

      super(const_name, path)
    end

    private

    def snake_case(word)
      word = word.gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.downcase!
      word
    end
  end
end
