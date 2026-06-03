# frozen_string_literal: true

RSpec.describe PromptScrub::Vault do
  subject(:vault) { described_class.new }

  describe '#tokenize' do
    it 'creates a token in the format <TYPE_NNN>' do
      token = vault.tokenize('EMAIL', 'john@example.com')
      expect(token).to eq('<EMAIL_001>')
    end

    it 'returns the same token for the same value' do
      first  = vault.tokenize('EMAIL', 'john@example.com')
      second = vault.tokenize('EMAIL', 'john@example.com')
      expect(first).to eq(second)
    end

    it 'increments the counter for different values of the same type' do
      first  = vault.tokenize('EMAIL', 'a@example.com')
      second = vault.tokenize('EMAIL', 'b@example.com')
      expect(first).to eq('<EMAIL_001>')
      expect(second).to eq('<EMAIL_002>')
    end

    it 'maintains independent counters per type' do
      vault.tokenize('EMAIL', 'a@example.com')
      vault.tokenize('EMAIL', 'b@example.com')
      ssn_token = vault.tokenize('SSN', '123-45-6789')
      expect(ssn_token).to eq('<SSN_001>')
    end

    it 'normalizes type to uppercase' do
      token = vault.tokenize('email', 'x@example.com')
      expect(token).to eq('<EMAIL_001>')
    end

    it 'handles up to 999 tokens per type' do
      999.times { |i| vault.tokenize('EMAIL', "user#{i}@example.com") }
      token = vault.tokenize('EMAIL', 'last@example.com')
      expect(token).to match(/<EMAIL_\d+>/)
    end
  end

  describe '#rehydrate' do
    it 'returns the original value for a known token' do
      vault.tokenize('EMAIL', 'john@example.com')
      expect(vault.rehydrate('<EMAIL_001>')).to eq('john@example.com')
    end

    it 'returns nil for an unknown token' do
      expect(vault.rehydrate('<EMAIL_999>')).to be_nil
    end
  end

  describe '#empty?' do
    it 'is true when no tokens have been stored' do
      expect(vault).to be_empty
    end

    it 'is false after tokenizing a value' do
      vault.tokenize('EMAIL', 'x@example.com')
      expect(vault).not_to be_empty
    end
  end

  describe '#size' do
    it 'returns the number of unique tokens' do
      vault.tokenize('EMAIL', 'a@example.com')
      vault.tokenize('EMAIL', 'b@example.com')
      vault.tokenize('SSN', '123-45-6789')
      expect(vault.size).to eq(3)
    end

    it 'does not double-count the same value' do
      vault.tokenize('EMAIL', 'a@example.com')
      vault.tokenize('EMAIL', 'a@example.com')
      expect(vault.size).to eq(1)
    end
  end

  describe 'thread safety' do
    it 'tokenizes concurrently without data corruption' do
      threads = 20.times.map do |i|
        Thread.new { vault.tokenize('EMAIL', "user#{i}@example.com") }
      end
      threads.each(&:join)
      expect(vault.size).to eq(20)
    end
  end
end
