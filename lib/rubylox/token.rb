module Rubylox
  class TokenType
    def initialize(type)
      @type = type
    end

    attr_reader :type

    def ==(other)
      @type == other
    end

    def ===(other)
      @type == other
    end
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

class Symbol
  def ==(other)
    if other.class == Rubylox::TokenType
      other == self
    else
      super(other)
    end
  end
end
