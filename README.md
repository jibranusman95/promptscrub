# promptscrub

[![Gem Version](https://badge.fury.io/rb/promptscrub.svg)](https://rubygems.org/gems/promptscrub)
[![CI](https://github.com/jibranusman95/promptscrub/actions/workflows/ci.yml/badge.svg)](https://github.com/jibranusman95/promptscrub/actions/workflows/ci.yml)

**Strip PII from LLM prompts. Rehydrate it in responses. Your users see real data. Your LLM provider never does.**

Drop-in Faraday middleware for OpenAI, Anthropic, Gemini — and any LLM library built on Faraday (RubyLLM, langchainrb, llm.rb).

```
Your App                   PromptScrub                LLM API
   │                           │                          │
   │  "SSN is 123-45-6789"     │                          │
   │──────────────────────────►│  redact                  │
   │                           │  "SSN is <SSN_001>"      │
   │                           │─────────────────────────►│
   │                           │                          │ generate
   │                           │◄─────────────────────────│
   │                           │  "Your SSN <SSN_001>..."  │
   │                           │  rehydrate               │
   │  "Your SSN 123-45-6789..."│                          │
   │◄──────────────────────────│                          │
```

No infra to deploy. No gateway to operate. Just middleware.

## Installation

```ruby
gem "promptscrub"
```

## Quick start

```ruby
require "faraday"
require "promptscrub"

conn = Faraday.new("https://api.openai.com") do |f|
  f.use PromptScrub::Middleware
  f.request :json
  f.response :json
  f.adapter Faraday.default_adapter
end

# PII is stripped before the request leaves your app.
# Tokens are rehydrated in the response. Transparent to your code.
response = conn.post("/v1/chat/completions", {
  model: "gpt-4o",
  messages: [{ role: "user", content: "Summarize claim for SSN 234-56-7890, card 4532015112830366" }]
})
```

### With RubyLLM

```ruby
RubyLLM.configure do |c|
  c.faraday do |f|
    f.use PromptScrub::Middleware
  end
end
```

## Built-in detectors

| Type    | Detects                            | Token example   |
|---------|------------------------------------|-----------------|
| EMAIL   | `john.doe+tag@sub-domain.co.uk`    | `<EMAIL_001>`   |
| SSN     | `123-45-6789` (invalid ranges excluded) | `<SSN_001>` |
| CARD    | 13–19 digit numbers (Luhn-validated) | `<CARD_001>`  |
| PHONE   | US numbers in all common formats   | `<PHONE_001>`   |

Same value always maps to the same token within a request — so `alice@corp.com` appearing twice becomes `<EMAIL_001>` twice.

## Configuration

```ruby
PromptScrub.configure do |config|
  # Add a custom detector
  config.add_detector(:zip, /\b\d{5}(-\d{4})?\b/)

  # Opt out of a built-in
  config.disable_detector(:phone)

  # Redact only outbound (skip rehydration)
  config.scrub_response = false
end
```

## Streaming (SSE)

For streaming responses where your app processes chunks directly, use `StreamRehydrator` to wrap your callback:

```ruby
vault      = PromptScrub::Vault.new
redactor   = PromptScrub::Redactor.new(vault, PromptScrub.configuration.detectors)
rehydrator = PromptScrub::StreamRehydrator.new(vault) do |clean_chunk|
  print clean_chunk  # user sees real values
end

# Before streaming request:
redacted_prompt = redactor.scrub(user_prompt)

# For each SSE chunk received:
rehydrator.call(raw_chunk)

# After stream ends:
rehydrator.flush
```

`StreamRehydrator` buffers partial tokens at chunk boundaries (e.g. `<EMAIL_` split across two chunks) and flushes them correctly when the token completes.

## How it works

1. **Redact** — on every outgoing request, `Redactor` scans the body string with all registered detectors and replaces matches with `<TYPE_NNN>` tokens. Each unique value gets a stable token stored in a per-request `Vault`.
2. **Send** — the redacted body hits the LLM API. The model never sees real PII.
3. **Rehydrate** — on the response, `Rehydrator` scans for token patterns and substitutes original values from the vault. Your application code receives the real data.

The vault is in-memory and scoped to a single request — no persistence, no shared state between requests.

## Security notes

- Tokens are **not encrypted**. The vault lives in your process memory for the duration of a request.
- Detection is regex-based. It will catch well-formed PII; obfuscated or unusual formats may slip through.
- For high-assurance use cases (HIPAA, PCI-DSS), add custom detectors for your specific data patterns and review false-negative rates in your domain.
- promptscrub is client-side middleware. It does not replace network-level controls or data governance policies.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/jibranusman95/promptscrub).

## License

MIT — see [LICENSE](LICENSE).
