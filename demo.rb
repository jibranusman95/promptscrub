# frozen_string_literal: true

$LOAD_PATH.unshift File.join(__dir__, 'lib')
require 'promptscrub'

vault      = PromptScrub::Vault.new
detectors  = PromptScrub.configuration.detectors
redactor   = PromptScrub::Redactor.new(vault, detectors)
rehydrator = PromptScrub::Rehydrator.new(vault)

original = "Hi, my name is John Smith. My SSN is 234-56-7890, " \
           "email is john.smith@hospital.com, " \
           "and my card 4532015112830366 was charged twice."

redacted  = redactor.scrub(original)
restored  = rehydrator.rehydrate(redacted)

puts
puts "  ORIGINAL   #{original}"
puts
puts "  → LLM API  #{redacted}"
puts
puts "  ← RESPONSE #{restored}"
puts
