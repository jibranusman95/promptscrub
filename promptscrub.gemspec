# frozen_string_literal: true

require_relative "lib/promptscrub/version"

Gem::Specification.new do |spec|
  spec.name    = "promptscrub"
  spec.version = PromptScrub::VERSION
  spec.authors = ["Jibran Usman"]
  spec.email   = ["jibran.usman@hotmail.com"]

  spec.summary = "Bidirectional PII redaction for LLM calls — strip sensitive data from prompts, rehydrate in responses."
  spec.description = <<~DESC
    Drop-in Faraday middleware that detects and tokenizes PII (emails, SSNs, credit cards,
    phone numbers, custom patterns) in outgoing LLM requests, then rehydrates tokens back
    in responses. Works with OpenAI, Anthropic, Gemini, RubyLLM, langchainrb, and any
    Faraday-based HTTP client. Includes StreamRehydrator for SSE streaming use cases.
  DESC
  spec.homepage = "https://github.com/jibranusman95/promptscrub"
  spec.license  = "MIT"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files         = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 1.0"
end
