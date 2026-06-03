# frozen_string_literal: true

RSpec.describe PromptScrub::Redactor do
  subject(:redactor) { described_class.new(vault, detectors) }

  let(:vault)     { PromptScrub::Vault.new }
  let(:detectors) { PromptScrub.configuration.detectors }

  describe '#scrub' do
    it 'replaces an email with a token' do
      result = redactor.scrub('Contact john@example.com for help')
      expect(result).to eq('Contact <EMAIL_001> for help')
    end

    it 'replaces an SSN with a token' do
      result = redactor.scrub('SSN is 234-56-7890')
      expect(result).to eq('SSN is <SSN_001>')
    end

    it 'replaces multiple PII types' do
      result = redactor.scrub('email john@example.com SSN 234-56-7890')
      expect(result).to include('<EMAIL_001>', '<SSN_001>')
      expect(result).not_to include('john@example.com', '234-56-7890')
    end

    it 'uses the same token for repeated values' do
      result = redactor.scrub('from john@example.com to john@example.com')
      expect(result).to eq('from <EMAIL_001> to <EMAIL_001>')
    end

    it 'returns text unchanged when no PII is found' do
      text = 'hello world, no sensitive data here'
      expect(redactor.scrub(text)).to eq(text)
    end

    it 'returns nil unchanged' do
      expect(redactor.scrub(nil)).to be_nil
    end

    it 'returns empty string unchanged' do
      expect(redactor.scrub('')).to eq('')
    end

    it 'populates the vault with scrubbed values' do
      redactor.scrub('email: a@b.com')
      expect(vault.rehydrate('<EMAIL_001>')).to eq('a@b.com')
    end

    it 'scrubs a valid credit card number' do
      result = redactor.scrub('card: 4532015112830366')
      expect(result).to eq('card: <CARD_001>')
    end

    it 'scrubs a phone number' do
      result = redactor.scrub('call 415-555-0100 now')
      expect(result).to eq('call <PHONE_001> now')
    end
  end
end
