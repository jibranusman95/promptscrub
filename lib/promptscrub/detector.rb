# frozen_string_literal: true

module PromptScrub
  class Detector
    attr_reader :type, :pattern

    def initialize(type, pattern)
      @type    = type.to_s.upcase
      @pattern = pattern
    end

    def scan(text)
      text.scan(pattern).map { |m| m.is_a?(Array) ? m.first : m }.uniq
    end
  end
end
