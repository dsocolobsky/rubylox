module Rubylox
  class LoxInstance
    def initialize(kclass)
      @klass = kclass
      @fields = {} # Hashmap<String, Object>
    end

    attr_reader :klass, :fields

    def get(name)
      if @fields.key?(name.lexeme)
        @fields[name.lexeme]
      else
        method = @klass.find_method(name.lexeme)
        return method.bind(self) if method

        raise "Undefined property or method '#{name.lexeme}' for <instance of #{@klass}>"
      end
    end

    def set(name, value)
      @fields[name.lexeme] = value
    end

    def to_s
      "<instance of #{@klass}>"
    end
  end
end
