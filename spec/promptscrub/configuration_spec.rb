# frozen_string_literal: true

RSpec.describe PromptScrub::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'enables request scrubbing' do
      expect(config.scrub_request).to be true
    end

    it 'enables response scrubbing' do
      expect(config.scrub_response).to be true
    end

    it 'loads four built-in detectors' do
      types = config.detectors.map(&:type)
      expect(types).to contain_exactly('EMAIL', 'SSN', 'CARD', 'PHONE')
    end
  end

  describe '#add_detector' do
    it 'registers a custom detector from type + pattern' do
      config.add_detector(:zip, /\b\d{5}(-\d{4})?\b/)
      types = config.detectors.map(&:type)
      expect(types).to include('ZIP')
    end

    it 'registers a Detector instance directly' do
      detector = PromptScrub::Detector.new('CUSTOM', /secret/)
      config.add_detector(detector)
      expect(config.detectors).to include(detector)
    end

    it 'is chainable' do
      result = config.add_detector(:zip, /\b\d{5}\b/)
      expect(result).to eq(config)
    end
  end

  describe '#disable_detector' do
    it 'removes a built-in detector by type' do
      config.disable_detector(:phone)
      types = config.detectors.map(&:type)
      expect(types).not_to include('PHONE')
    end

    it 'is case-insensitive' do
      config.disable_detector('EMAIL')
      types = config.detectors.map(&:type)
      expect(types).not_to include('EMAIL')
    end

    it 'is chainable' do
      result = config.disable_detector(:ssn)
      expect(result).to eq(config)
    end
  end

  describe 'PromptScrub.configure' do
    it 'yields the configuration object' do
      PromptScrub.configure do |c|
        c.scrub_request = false
      end
      expect(PromptScrub.configuration.scrub_request).to be false
    end

    it 'resets after PromptScrub.reset!' do
      PromptScrub.configure { |c| c.scrub_request = false }
      PromptScrub.reset!
      expect(PromptScrub.configuration.scrub_request).to be true
    end
  end
end
