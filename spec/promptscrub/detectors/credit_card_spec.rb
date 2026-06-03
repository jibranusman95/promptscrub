# frozen_string_literal: true

RSpec.describe PromptScrub::Detectors::CreditCard do
  subject(:detector) { described_class.new }

  let(:valid_visa)       { '4532015112830366' }
  let(:valid_mastercard) { '5425233430109903' }
  let(:invalid_luhn)     { '4532015112830367' }

  it 'has type CARD' do
    expect(detector.type).to eq('CARD')
  end

  describe '#scan' do
    it 'detects a valid Visa card number' do
      expect(detector.scan("card: #{valid_visa}")).to eq([valid_visa])
    end

    it 'detects a valid Mastercard number' do
      expect(detector.scan("charged to #{valid_mastercard}")).to eq([valid_mastercard])
    end

    it 'detects a card number with dashes' do
      formatted = '4532-0151-1283-0366'
      result = detector.scan("card #{formatted}")
      expect(result).to eq([formatted])
    end

    it 'detects a card number with spaces' do
      formatted = '4532 0151 1283 0366'
      result = detector.scan("card #{formatted}")
      expect(result).to eq([formatted])
    end

    it 'rejects numbers that fail the Luhn check' do
      expect(detector.scan(invalid_luhn)).to be_empty
    end

    it 'returns empty for text with no card numbers' do
      expect(detector.scan('order #12345 placed')).to be_empty
    end
  end
end
