# frozen_string_literal: true

require 'json'

RSpec.describe PromptScrub::Middleware do
  def build_connection(scrub_request: true, scrub_response: true, &stub_block)
    PromptScrub.configure do |c|
      c.scrub_request  = scrub_request
      c.scrub_response = scrub_response
    end

    Faraday.new do |f|
      f.use PromptScrub::Middleware
      f.adapter :test, &stub_block
    end
  end

  describe 'request redaction' do
    it 'redacts PII in the request body before it reaches the adapter' do
      received_body = nil

      conn = build_connection do |stub|
        stub.post('/chat') do |env|
          received_body = env.body
          [200, {}, '{"result":"ok"}']
        end
      end

      conn.post('/chat', JSON.generate({ messages: [{ content: 'email john@example.com' }] }))

      expect(received_body).to include('<EMAIL_001>')
      expect(received_body).not_to include('john@example.com')
    end

    it 'skips redaction when scrub_request is false' do
      received_body = nil

      conn = build_connection(scrub_request: false) do |stub|
        stub.post('/chat') do |env|
          received_body = env.body
          [200, {}, '{"result":"ok"}']
        end
      end

      conn.post('/chat', JSON.generate({ messages: [{ content: 'email john@example.com' }] }))

      expect(received_body).to include('john@example.com')
    end
  end

  describe 'response rehydration' do
    it 'rehydrates tokens in the response body' do
      conn = build_connection do |stub|
        stub.post('/chat') do
          [200, {}, '{"choices":[{"message":{"content":"Hello <EMAIL_001>!"}}]}']
        end
      end

      response = conn.post('/chat', JSON.generate({ messages: [{ content: 'email john@example.com' }] }))

      expect(response.body).to include('john@example.com')
      expect(response.body).not_to include('<EMAIL_001>')
    end

    it 'skips rehydration when scrub_response is false' do
      conn = build_connection(scrub_response: false) do |stub|
        stub.post('/chat') do
          [200, {}, '{"choices":[{"message":{"content":"Hello <EMAIL_001>!"}}]}']
        end
      end

      response = conn.post('/chat', JSON.generate({ messages: [{ content: 'email john@example.com' }] }))

      expect(response.body).to include('<EMAIL_001>')
    end

    it 'does not modify response when vault is empty (no PII in request)' do
      original_body = '{"choices":[{"message":{"content":"Hello world!"}}]}'

      conn = build_connection do |stub|
        stub.post('/chat') { [200, {}, original_body] }
      end

      response = conn.post('/chat', JSON.generate({ messages: [{ content: 'no pii here' }] }))
      expect(response.body).to eq(original_body)
    end
  end

  describe 'edge cases' do
    it 'handles a nil body (e.g. GET request) without raising' do
      conn = build_connection do |stub|
        stub.get('/health') { [200, {}, '{"ok":true}'] }
      end

      expect { conn.get('/health') }.not_to raise_error
    end

    it 'serializes a Hash body to JSON before redacting' do
      received_body = nil

      conn = build_connection do |stub|
        stub.post('/chat') do |env|
          received_body = env.body
          [200, {}, '{}']
        end
      end

      conn.post('/chat', { content: 'email john@example.com' })

      expect(received_body).to include('<EMAIL_001>')
    end
  end

  describe 'round-trip' do
    it 'redacts on request and rehydrates on response transparently' do
      conn = build_connection do |stub|
        stub.post('/chat') do |env|
          # Echo the redacted body back in the response
          [200, {}, "{\"echo\":#{env.body.inspect}}"]
        end
      end

      response = conn.post('/chat', JSON.generate({ content: 'call me at 415-555-0100' }))

      expect(response.body).to include('415-555-0100')
      expect(response.body).not_to include('<PHONE_001>')
    end

    it 'handles multiple PII types in round-trip' do
      conn = build_connection do |stub|
        stub.post('/chat') do |env|
          [200, {}, env.body]
        end
      end

      body     = JSON.generate({ content: 'email john@example.com SSN 234-56-7890' })
      response = conn.post('/chat', body)

      expect(response.body).to include('john@example.com')
      expect(response.body).to include('234-56-7890')
    end
  end
end
