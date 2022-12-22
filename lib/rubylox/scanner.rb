module Rubylox
  class Scanner
    KEYWORDS = {
      'and' => :and, 'class' => :class, 'else' => :else, 'false' => :false,
      'for' => :for, 'fun' => :fun, 'if' => :if, 'nil' => :nil, 'or' => :or,
      'print' => :print, 'return' => :return, 'super' => :super, 'this' => :this,
      'true' => :true, 'var' => :var, 'while' => :while
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

      @tokens << Token.new(:eof, '', nil, @line)
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
        add_token(:left_paren)
      when ')'
        add_token(:right_paren)
      when '{'
        add_token(:left_brace)
      when '}'
        add_token(:right_brace)
      when ','
        add_token(:comma)
      when '.'
        add_token(:dot)
      when '-'
        add_token(:minus)
      when '+'
        add_token(:plus)
      when ';'
        add_token(:semicolon)
      when '*'
        add_token(:star)
      when '!'
        add_token(match('=') ? :bang_equal : :bang)
      when '='
        add_token(match('=') ? :equal_equal : :equal)
      when '<'
        add_token(match('=') ? :less_equal : :less)
      when '>'
        add_token(match('=') ? :greater_equal : :greater)
      when '/'
        if match('/') # it's a comment
          advance while peek != "\n" && !at_end? # advance til the end of line
        else
          add_token(:slash)
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
      add_token(:string, value)
    end

    def scan_number
      advance while digit?(peek)

      if peek == '.' && digit?(peek_next)
        advance

        advance while digit?(peek)
      end

      value = @source[@start...@current].to_f
      add_token(:number, value)
    end

    def scan_identifier
      advance while alphanumeric?(peek)

      text = @source[@start...@current]
      if text.nil?
        raise 'text is nil'
      end

      type = KEYWORDS[text] || :identifier
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
      c.instance_of?(::String) && c >= '0' && c <= '9'
    end

    def alphabetical?(c)
      c.instance_of?(::String) &&
        ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')
    end

    def alphanumeric?(c)
      alphabetical?(c) || digit?(c)
    end

    def at_end?
      @current >= @source.length
    end
  end
end
