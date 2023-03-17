# frozen_string_literal: true

# Converts a string to a camel case string
class ClassNameFromString
  def initialize(string)
    @string = string
  end

  def to_s
    @string.split('_').collect(&:capitalize).join
  end
end
