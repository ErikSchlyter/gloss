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
    include Comparable

    def initialize(parameters=[])
      super(parameters)
      @parameters.each{|p| p.used_by << self }
    end

    def should_be_cached?
      used_by.size > 1
    end

    def wrapped_in_load_statement(wrapped=[])
      return Load.new(wrapped.index(self)) if wrapped.include? self

      cache_parameters!(wrapped)

      if should_be_cached? then
        wrapped << self
        return Load.new(wrapped.index(self))
      else
        return self
      end
    end

    def <=>(anOther)
      diff = type <=> anOther.type
      return diff unless diff == 0
      diff = @parameters.size <=> anOther.parameters.size
      return diff unless diff == 0
      @parameters.each_with_index{|param, index|
        diff = param <=> anOther.parameters[index]
        return diff unless diff == 0
      }
      0
    end
  end

  class Constant < Expression
    attr_reader :value

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

    def <=>(anOther)
      diff = type <=> anOther.type
      return diff unless diff == 0
      value <=> anOther.value
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
    attr_reader :variable_index

    def initialize(variable_index)
      @variable_index = variable_index
    end

    def to_s
      "L[#{@variable_index}]"
    end

    def <=>(anOther)
      diff = type <=> anOther.type
      return diff unless diff == 0
      variable_index <=> anOther.variable_index
    end
  end

  class Store < Statement
    attr_reader :variable_index

    def initialize(expression, variable_index)
      @parameters = [expression]
      @variable_index = variable_index
    end

    def to_s
      "S[#{@variable_index}](#{parameters_to_s})"
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
      stored_expressions = []

      @invocations.each{|invoke|
        cached_expressions = invoke.cache_parameters!

        cached_expressions.each{|expr|
          unless stored_expressions.include?(expr) then
            stored_expressions << expr
            output << Store.new(expr, stored_expressions.index(expr))
          end
        }
        output << invoke
      }
      output
    end

    def to_s
      "#{@name}(#{@parameters.join(', ')}){ #{compile.join('; ')} }"
    end
  end
end
