# frozen_string_literal: true

module PromptScrub
  class Configuration
    attr_accessor :scrub_request, :scrub_response
    attr_reader   :detectors

    def initialize
      @scrub_request  = true
      @scrub_response = true
      @detectors      = default_detectors
    end

    def add_detector(type_or_detector, pattern = nil)
      detector = if type_or_detector.is_a?(Detector)
                   type_or_detector
                 else
                   Detector.new(type_or_detector, pattern)
                 end
      @detectors << detector
      self
    end

    def disable_detector(type)
      @detectors.reject! { |d| d.type.casecmp(type.to_s).zero? }
      self
    end

    private

    def default_detectors
      [
        Detectors::Email.new,
        Detectors::SSN.new,
        Detectors::CreditCard.new,
        Detectors::Phone.new
      ]
    end
  end
end
