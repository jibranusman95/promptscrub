# frozen_string_literal: true

require 'faraday'
require_relative 'promptscrub/version'
require_relative 'promptscrub/configuration'
require_relative 'promptscrub/vault'
require_relative 'promptscrub/detector'
require_relative 'promptscrub/detectors/email'
require_relative 'promptscrub/detectors/ssn'
require_relative 'promptscrub/detectors/credit_card'
require_relative 'promptscrub/detectors/phone'
require_relative 'promptscrub/redactor'
require_relative 'promptscrub/rehydrator'
require_relative 'promptscrub/middleware'
require_relative 'promptscrub/stream_rehydrator'

module PromptScrub
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset!
      @configuration = nil
    end
  end
end
