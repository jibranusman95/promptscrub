# frozen_string_literal: true

RSpec.describe PromptScrub::Detector do
  describe '#type' do
    it 'normalizes type to uppercase' do
      detector = described_class.new('email', /foo/)
      expect(detector.type).to eq('EMAIL')
    end

    it 'preserves already-uppercase type' do
      detector = described_class.new('SSN', /foo/)
      expect(detector.type).to eq('SSN')
    end
  end

  describe '#scan' do
    context 'with a pattern without capture groups' do
      let(:detector) { described_class.new('WORD', /\b\w{5}\b/) }

      it 'returns matched strings' do
        expect(detector.scan('hello world')).to eq(%w[hello world])
      end

      it 'deduplicates matches' do
        expect(detector.scan('hello hello')).to eq(['hello'])
      end

      it 'returns empty array for no matches' do
        expect(detector.scan('hi')).to be_empty
      end
    end

    context 'with a pattern with capture groups' do
      # Detector#scan maps Array results from String#scan with capture groups
      # to the first capture — exercises the m.is_a?(Array) branch
      let(:detector) { described_class.new('PRICE', /\$(\d+\.\d{2})/) }

      it 'returns the captured group, not the full match' do
        expect(detector.scan('total: $12.99')).to eq(['12.99'])
      end

      it 'deduplicates captured values' do
        expect(detector.scan('$9.99 and $9.99')).to eq(['9.99'])
      end
    end
  end
end
