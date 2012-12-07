module Gloss

  class Statement
    attr_accessor :parameters
    attr_accessor :used_by

    def initialize(parameters=[])
      @parameters = parameters
      @used_by = []
    end

    def should_be_cached?
      false
    end

    def cache_parameters!(wrapped=[])
      @parameters.map! {|param| param.wrapped_in_load_statement(wrapped) }
      wrapped
    end

    def to_s
      type << '(' << parameters_to_s << ')'
    end

    def type
      self.class.name.downcase.sub(/gloss::/,'')
    end

    def parameters_to_s
      @parameters.collect{|p| p.to_s}.join(parameter_sep)
    end

    def parameter_sep
      ', '
    end
  end

  class Expression < Statement

    def initialize(parameters=[])
      super(parameters)
      @parameters.each{|p| p.used_by << self }
    end

    def should_be_cached?
      used_by.size > 1
    end

    def wrapped_in_load_statement(wrapped=[])
      return Load.new(self) if wrapped.include? self

      cache_parameters!(wrapped)

      if should_be_cached? then
        wrapped << self
        return Load.new(self)
      else
        return self
      end
    end
  end

  class Constant < Expression
    def initialize(value)
      super([])
      @value = value;
    end

    def should_be_cached?
      false
    end

    def to_s
      @value.to_s
    end
  end

  class Max < Expression

  end

  class Min < Expression

  end

  class ArithmeticExpression < Expression
    def initialize(left, right)
      super([left, right])
    end

    def to_s
      '(' << parameters_to_s << ')'
    end
  end

  class Add < ArithmeticExpression
    def parameter_sep
      '+'
    end
  end

  class Sub < ArithmeticExpression
    def parameter_sep
      '-'
    end
  end

  class Mul < ArithmeticExpression
    def parameter_sep
      '*'
    end
  end

  class Div < ArithmeticExpression
    def parameter_sep
      '/'
    end
  end

  class Load < Expression
    def initialize(expression)
      @parameters = [expression]
    end

    def to_s
      "L[#{parameters_to_s}]"
    end
  end

  class Store < Statement
    def initialize(expression)
      @parameters = [expression]
    end
    def to_s
      "S[#{parameters_to_s}]"
    end
  end

  class Invoke < Statement
    attr_reader :name
    def initialize(name, parameters)
      super(parameters)
      @name = name
      @used_by = []
      @parameters.each{|p| p.used_by << self }
    end

    def to_s
      "#{@name}(#{parameters_to_s})"
    end
  end

  class Method
    attr_reader :name

    def initialize(name, parameters, invocations)
      @name = name
      @parameters = parameters
      @invocations = invocations
    end

    def compile
      output = []
      stored_expressions = Set.new

      @invocations.each{|invoke|
        cached_expressions = invoke.cache_parameters!

        cached_expressions.each{|expr|
          unless stored_expressions.include?(expr) then
            output << Store.new(expr)
          end
        }
        output << invoke
        stored_expressions.merge(cached_expressions)
      }
      output
    end

    def to_s
      "#{@name}(#{@parameters.join(', ')}){ #{compile.join('; ')} }"
    end
  end
end
