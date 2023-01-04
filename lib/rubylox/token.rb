# frozen_string_literal: true
module Rubylox

  TOKEN_TYPES = %i[
    and class else false for fun if nil or print return super this true
    var while eof error identifier string number left_paren right_paren
    left_brace right_brace comma dot minus plus semicolon slash star bang
    bang_equal equal equal_equal greater greater_equal less less_equal
  ].freeze

  class TokenType
    def initialize(type)
      raise "Unknown token type #{type}" unless TOKEN_TYPES.include?(type)

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
