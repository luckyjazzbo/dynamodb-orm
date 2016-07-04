module Mes
  module InitializationVectorHelper
    LETTERS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'.chars.freeze

    def self.generate
      vector = ''
      16.times { vector << LETTERS.sample }
      vector
    end
  end
end
