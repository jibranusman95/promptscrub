# frozen_string_literal: true

RSpec.describe PromptScrub::Detectors::SSN do
  subject(:detector) { described_class.new }

  it 'has type SSN' do
    expect(detector.type).to eq('SSN')
  end

  describe '#scan' do
    it 'detects a valid SSN' do
      expect(detector.scan('SSN: 123-45-6789')).to eq(['123-45-6789'])
    end

    it 'detects SSN embedded in text' do
      expect(detector.scan('patient ssn is 234-56-7890 on file')).to eq(['234-56-7890'])
    end

    it 'rejects all-zero area code' do
      expect(detector.scan('000-45-6789')).to be_empty
    end

    it 'rejects area code 666' do
      expect(detector.scan('666-45-6789')).to be_empty
    end

    it 'rejects 9xx area code' do
      expect(detector.scan('900-45-6789')).to be_empty
    end

    it 'rejects 00 group number' do
      expect(detector.scan('123-00-6789')).to be_empty
    end

    it 'rejects 0000 serial number' do
      expect(detector.scan('123-45-0000')).to be_empty
    end

    it 'returns empty for text with no SSN' do
      expect(detector.scan('call me at 555-1234')).to be_empty
    end
  end
end
