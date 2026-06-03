# frozen_string_literal: true

module PromptScrub
  module Detectors
    class CreditCard < Detector
      PATTERN = /\b(?:\d[ -]?){13,18}\d\b/

      def initialize
        super('CARD', PATTERN)
      end

      def scan(text)
        super.select { |n| luhn_valid?(n.gsub(/[ -]/, '')) }
      end

      private

      def luhn_valid?(number)
        return false unless number.match?(/\A\d{13,19}\z/)

        digits = number.chars.map(&:to_i)
        sum = digits.reverse.each_with_index.sum do |digit, i|
          if i.odd?
            doubled = digit * 2
            doubled > 9 ? doubled - 9 : doubled
          else
            digit
          end
        end
        (sum % 10).zero?
      end
    end
  end
end
