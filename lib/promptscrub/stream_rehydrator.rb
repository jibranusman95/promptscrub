# frozen_string_literal: true

module PromptScrub
  class StreamRehydrator
    PARTIAL_TOKEN = /<[A-Z_\d]*\z/

    def initialize(vault, &callback)
      @vault    = vault
      @callback = callback
      @buffer   = ''
    end

    def call(chunk)
      combined = @buffer + chunk
      @buffer  = ''

      if (match = combined.match(PARTIAL_TOKEN))
        @buffer  = match[0]
        combined = combined[0, match.begin(0)]
      end

      @callback.call(rehydrate(combined)) unless combined.empty?
    end

    def flush
      result  = rehydrate(@buffer)
      @buffer = ''
      @callback.call(result) unless result.empty?
    end

    private

    def rehydrate(text)
      text.gsub(Rehydrator::TOKEN_PATTERN) do |token|
        @vault.rehydrate(token) || token
      end
    end
  end
end
