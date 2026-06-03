# frozen_string_literal: true

RSpec.describe PromptScrub::Rehydrator do
  subject(:rehydrator) { described_class.new(vault) }

  let(:vault) { PromptScrub::Vault.new }

  before do
    vault.tokenize('EMAIL', 'john@example.com')
    vault.tokenize('SSN', '234-56-7890')
  end

  describe '#rehydrate' do
    it 'replaces a token with its original value' do
      expect(rehydrator.rehydrate('Hi <EMAIL_001>!')).to eq('Hi john@example.com!')
    end

    it 'replaces multiple tokens in one string' do
      text   = 'email <EMAIL_001> ssn <SSN_001>'
      result = rehydrator.rehydrate(text)
      expect(result).to eq('email john@example.com ssn 234-56-7890')
    end

    it 'leaves unknown tokens in place' do
      expect(rehydrator.rehydrate('hello <EMAIL_999>')).to eq('hello <EMAIL_999>')
    end

    it 'returns nil unchanged' do
      expect(rehydrator.rehydrate(nil)).to be_nil
    end

    it 'returns empty string unchanged' do
      expect(rehydrator.rehydrate('')).to eq('')
    end

    it 'returns text unchanged when vault is empty' do
      empty_vault = PromptScrub::Vault.new
      rehydrator  = described_class.new(empty_vault)
      text        = 'no tokens here'
      expect(rehydrator.rehydrate(text)).to eq(text)
    end

    it 'handles text with no tokens' do
      expect(rehydrator.rehydrate('plain text, no tokens')).to eq('plain text, no tokens')
    end

    it 'rehydrates a token at the very start of a string' do
      expect(rehydrator.rehydrate('<EMAIL_001> said hello')).to eq('john@example.com said hello')
    end

    it 'rehydrates a token at the very end of a string' do
      expect(rehydrator.rehydrate('contact: <EMAIL_001>')).to eq('contact: john@example.com')
    end

    it 'rehydrates adjacent tokens with no separator' do
      result = rehydrator.rehydrate('<EMAIL_001><SSN_001>')
      expect(result).to eq('john@example.com234-56-7890')
    end
  end
end
