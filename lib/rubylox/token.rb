module Rubylox
  class TokenType
    def initialize(type)
      @type = type
    end

    attr_reader :type
  end

  class Token
    def initialize(type, lexeme, literal, line)
      @type = TokenType.new(type)
      @lexeme = lexeme
      @literal = literal
      @line = line
    end
    attr_reader :lexeme, :literal, :line

    def type
      @type.type
    end

    def to_s
      "#{@type} #{@lexeme} #{@literal}"
    end
  end
end
