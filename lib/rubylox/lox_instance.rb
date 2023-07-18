module Rubylox
  class LoxInstance
    def initialize(kclass)
      @klass = kclass
    end

    def to_s
      "<instance of #{@klass}>"
    end
  end
end
