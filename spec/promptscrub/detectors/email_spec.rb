# frozen_string_literal: true

RSpec.describe PromptScrub::Detectors::Email do
  subject(:detector) { described_class.new }

  it 'has type EMAIL' do
    expect(detector.type).to eq('EMAIL')
  end

  describe '#scan' do
    it 'detects a simple email' do
      expect(detector.scan('contact john@example.com please')).to eq(['john@example.com'])
    end

    it 'detects email with dots, plus signs, and dashes' do
      email = 'john.doe+tag@sub-domain.example.co.uk'
      expect(detector.scan("send to #{email} now")).to eq([email])
    end

    it 'detects multiple emails in text' do
      text = 'cc alice@a.com and bob@b.org'
      expect(detector.scan(text)).to contain_exactly('alice@a.com', 'bob@b.org')
    end

    it 'deduplicates repeated emails' do
      text = 'from alice@a.com to alice@a.com'
      expect(detector.scan(text)).to eq(['alice@a.com'])
    end

    it 'returns empty array for text with no emails' do
      expect(detector.scan('hello world')).to be_empty
    end

    it 'does not match plain domain names' do
      expect(detector.scan('visit example.com for details')).to be_empty
    end
  end
end
