# frozen_string_literal: true

module PromptScrub
  module Detectors
    class Email < Detector
      PATTERN = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/

      def initialize
        super('EMAIL', PATTERN)
      end
    end
  end
end
