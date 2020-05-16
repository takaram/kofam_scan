# frozen_string_literal: true

module KofamScan
  # Base class for output formatter classes.
  # Each formatters shall respond to `#format' with two arguments.
  # The first argument is a `KofamScan::Result' instance, and the second
  # is an IO object or any instance responding `#<<' to get the output.
  class OutputFormatter
    extend Autoload

    autoload :HitDetailFormatter
    autoload :HitDetailTsvFormatter
    autoload :OneLineTabularFormatter
    autoload :SimpleTabularFormatter

    attr_accessor :report_unannotated
  end
end
