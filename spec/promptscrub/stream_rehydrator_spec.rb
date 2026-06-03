# frozen_string_literal: true

RSpec.describe PromptScrub::StreamRehydrator do
  subject(:stream) { described_class.new(vault) { |chunk| output << chunk } }

  let(:vault)  { PromptScrub::Vault.new }
  let(:output) { [] }

  before do
    vault.tokenize('EMAIL', 'john@example.com')
    vault.tokenize('PHONE', '415-555-0100')
  end

  describe '#call' do
    it 'rehydrates a complete token in a single chunk' do
      stream.call('Hello <EMAIL_001>!')
      expect(output).to eq(['Hello john@example.com!'])
    end

    it 'passes non-PII content through immediately' do
      stream.call('Hello world!')
      expect(output).to eq(['Hello world!'])
    end

    it 'buffers a partial token and rehydrates when the next chunk completes it' do
      stream.call('Hi <EMAIL_')
      expect(output).to eq(['Hi '])

      stream.call('001>!')
      expect(output.join).to eq('Hi john@example.com!')
    end

    it 'buffers a lone < at the end of a chunk' do
      stream.call('result: <')
      expect(output).to eq(['result: '])

      stream.call('EMAIL_001> done')
      expect(output.join).to eq('result: john@example.com done')
    end

    it 'handles a token split across three chunks' do
      stream.call('x <EMA')
      stream.call('IL_0')
      stream.call('01> y')
      expect(output.join).to eq('x john@example.com y')
    end

    it 'passes unknown tokens through unchanged' do
      stream.call('token: <EMAIL_999>')
      expect(output).to eq(['token: <EMAIL_999>'])
    end

    it 'rehydrates multiple tokens in one chunk' do
      stream.call('email <EMAIL_001> phone <PHONE_001>')
      expect(output.join).to include('john@example.com')
      expect(output.join).to include('415-555-0100')
    end

    it 'ignores an empty string chunk without error' do
      expect { stream.call('') }.not_to raise_error
      expect(output).to be_empty
    end

    it 'handles a chunk that is only a complete token' do
      stream.call('<EMAIL_001>')
      expect(output).to eq(['john@example.com'])
    end
  end

  describe '#flush' do
    it 'flushes buffered content after streaming ends' do
      stream.call('text <EMAIL_')
      stream.flush
      expect(output.join).to include('<EMAIL_')
    end

    it 'does nothing when buffer is empty' do
      expect { stream.flush }.not_to raise_error
      expect(output).to be_empty
    end
  end
end
