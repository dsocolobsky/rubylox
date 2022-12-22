module Rubylox
  class Token
    def initialize(type, lexeme, literal, line)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end
    attr_reader :type, :lexeme, :literal, :line

    def to_s
      "#{@type} #{@lexeme} #{@literal}"
    end
  end

  class Scanner
    KEYWORDS = {
      'and' => :AND, 'class' => :CLASS, 'else' => :ELSE, 'false' => :FALSE,
      'for' => :FOR, 'fun' => :FUN, 'if' => :IF, 'nil' => :NIL, 'or' => :OR,
      'print' => :PRINT, 'return' => :RETURN, 'super' => :SUPER, 'this' => :THIS,
      'true' => :TRUE, 'var' => :VAR, 'while' => :WHILE
    }.freeze

    def initialize(source)
      @source = source
      @tokens = []
      @start = 0
      @current = 0
      @line = 1
    end

    attr_reader :tokens, :source, :start, :current, :line

    def scan_tokens
      until at_end?
        @start = @current
        scan_token
      end

      # @tokens << Token.new(:EOF, '', nil, @line)
      @tokens
    end

    def scan_token
      c = advance
      # pattern match c according to each token
      case c
        # skip whiteline characters
      when "\r", "\t", ' '
        # do nothing
      when "\n"
        @line += 1
      when '('
        add_token(:LEFT_PAREN)
      when ')'
        add_token(:RIGHT_PAREN)
      when '{'
        add_token(:LEFT_BRACE)
      when '}'
        add_token(:RIGHT_BRACE)
      when ','
        add_token(:COMMA)
      when '.'
        add_token(:DOT)
      when '-'
        add_token(:MINUS)
      when '+'
        add_token(:PLUS)
      when ';'
        add_token(:SEMICOLON)
      when '*'
        add_token(:STAR)
      when '!'
        add_token(match('=') ? :BANG_EQUAL : :BANG)
      when '='
        add_token(match('=') ? :EQUAL_EQUAL : :EQUAL)
      when '<'
        add_token(match('=') ? :LESS_EQUAL : :LESS)
      when '>'
        add_token(match('=') ? :GREATER_EQUAL : :GREATER)
      when '/'
        if match('/') # it's a comment
          advance while peek != "\n" && !at_end? # advance til the end of line
        else
          add_token(:SLASH)
        end
      when '"'
        scan_string
      else
        if digit?(c)
          scan_number
        elsif alphabetical?(c)
          scan_identifier
        else
          puts "Unexpected character #{c}"
        end
      end
    end

    def scan_string
      while peek != '"' && !at_end?
        @line += 1 if peek == "\n"
        advance
      end

      if at_end?
        puts 'Unterminated string'
        return
      end

      advance # consume the ending "

      value = @source[@start + 1...@current - 1] # trim the surrounding "
      add_token(:STRING, value)
    end

    def scan_number
      advance while digit?(peek)

      if peek == '.' && digit?(peek_next)
        advance

        advance while digit?(peek)
      end

      value = @source[@start...@current].to_f
      add_token(:NUMBER, value)
    end

    def scan_identifier
      advance while alphanumeric?(peek)

      text = @source[@start...@current]
      type = KEYWORDS[text] || :IDENTIFIER
      add_token(type)
    end

    def advance
      @current += 1
      @source[@current - 1]
    end

    def peek
      return "\0" if at_end?

      @source[@current]
    end

    def peek_next
      return "\0" if @current + 1 >= @source.length

      @source[@current + 1]
    end

    def add_token(type, literal = nil)
      text = @source[@start...@current]
      @tokens << Token.new(type, text, literal, @line)
    end

    def match(expected)
      return false if at_end?
      return false if @source[@current] != expected

      @current += 1
      true
    end

    def digit?(c)
      c >= '0' && c <= '9'
    end

    def alphabetical?(c)
      (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
    end

    def alphanumeric?(c)
      alphabetical?(c) || digit?(c)
    end

    def at_end?
      @current >= @source.length
    end
  end
end
