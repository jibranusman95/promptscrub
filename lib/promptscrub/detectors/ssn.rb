# frozen_string_literal: true

module PromptScrub
  module Detectors
    class SSN < Detector
      PATTERN = /\b(?!000|666|9\d{2})\d{3}-(?!00)\d{2}-(?!0000)\d{4}\b/

      def initialize
        super('SSN', PATTERN)
      end
    end
  end
end
