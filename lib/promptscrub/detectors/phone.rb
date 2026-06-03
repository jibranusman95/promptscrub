# frozen_string_literal: true

module PromptScrub
  module Detectors
    class Phone < Detector
      PATTERN = /(?<!\d)(?:\+1[-.\s]?)?\(?[2-9]\d{2}\)?[-.\s]?\d{3}[-.\s]?\d{4}(?!\d)/

      def initialize
        super('PHONE', PATTERN)
      end
    end
  end
end
