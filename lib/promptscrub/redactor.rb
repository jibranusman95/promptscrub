# frozen_string_literal: true

module PromptScrub
  class Redactor
    def initialize(vault, detectors)
      @vault     = vault
      @detectors = detectors
    end

    def scrub(text)
      return text if text.nil? || text.empty?

      result = text.dup
      @detectors.each do |detector|
        detector.scan(result).each do |match|
          token  = @vault.tokenize(detector.type, match)
          result = result.gsub(match, token)
        end
      end
      result
    end
  end
end
