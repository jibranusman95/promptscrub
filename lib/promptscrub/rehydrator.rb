# frozen_string_literal: true

module PromptScrub
  class Rehydrator
    TOKEN_PATTERN = /<[A-Z]+_\d{3}>/

    def initialize(vault)
      @vault = vault
    end

    def rehydrate(text)
      return text if text.nil? || text.empty?
      return text if @vault.empty?

      text.gsub(TOKEN_PATTERN) do |token|
        @vault.rehydrate(token) || token
      end
    end
  end
end
