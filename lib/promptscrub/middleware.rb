# frozen_string_literal: true

require 'json'

module PromptScrub
  class Middleware < Faraday::Middleware
    def initialize(app, config: PromptScrub.configuration)
      super(app)
      @config = config
    end

    def call(env)
      vault      = Vault.new
      redactor   = Redactor.new(vault, @config.detectors)
      rehydrator = Rehydrator.new(vault)

      env[:body] = scrub_body(env[:body], redactor) if @config.scrub_request

      @app.call(env).on_complete do |response_env|
        if @config.scrub_response && !vault.empty? && response_env[:body].is_a?(String)
          response_env[:body] = rehydrator.rehydrate(response_env[:body])
        end
      end
    end

    private

    def scrub_body(body, redactor)
      return body if body.nil?

      body_str = body.is_a?(String) ? body : JSON.generate(body)
      redactor.scrub(body_str)
    end
  end
end
