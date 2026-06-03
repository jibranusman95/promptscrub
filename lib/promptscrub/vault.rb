# frozen_string_literal: true

module PromptScrub
  class Vault
    def initialize
      @store    = {}
      @reverse  = {}
      @counters = Hash.new(0)
      @mutex    = Mutex.new
    end

    def tokenize(type, value)
      @mutex.synchronize do
        return @reverse[value] if @reverse.key?(value)

        @counters[type] += 1
        token = format('<%<type>s_%<num>03d>', type: type.upcase, num: @counters[type])
        @store[token]   = value
        @reverse[value] = token
        token
      end
    end

    def rehydrate(token)
      @mutex.synchronize { @store[token] }
    end

    def empty?
      @mutex.synchronize { @store.empty? }
    end

    def size
      @mutex.synchronize { @store.size }
    end
  end
end
