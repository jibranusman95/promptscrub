# frozen_string_literal: true

RSpec.describe PromptScrub::Detectors::Phone do
  subject(:detector) { described_class.new }

  it 'has type PHONE' do
    expect(detector.type).to eq('PHONE')
  end

  describe '#scan' do
    it 'detects a standard US phone number' do
      expect(detector.scan('call 415-555-0100')).to eq(['415-555-0100'])
    end

    it 'detects phone with parentheses' do
      expect(detector.scan('reach us at (415) 555-0100')).to eq(['(415) 555-0100'])
    end

    it 'detects phone with +1 country code' do
      expect(detector.scan('dial +1 415-555-0100 now')).to eq(['+1 415-555-0100'])
    end

    it 'detects phone with dots' do
      expect(detector.scan('fax: 415.555.0100')).to eq(['415.555.0100'])
    end

    it 'deduplicates repeated numbers' do
      text = '415-555-0100 and 415-555-0100'
      expect(detector.scan(text)).to eq(['415-555-0100'])
    end

    it 'returns empty for text with no phone numbers' do
      expect(detector.scan('zip code 94103')).to be_empty
    end
  end
end
