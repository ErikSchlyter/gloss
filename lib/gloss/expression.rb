module Gloss

  class Statement
    attr_accessor :parameters

    def initialize(parameters=[])
      @parameters = parameters
    end

    def can_be_cached?
      false
    end

    def count_cachable_expressions(ref_count={})
      if ref_count.include?(self) then
        ref_count[self] += 1
      else
        ref_count[self] = 1 if can_be_cached?
        @parameters.each{|param| param.count_cachable_expressions(ref_count) }
      end
      ref_count
    end

    def wrap_recurring_expressions_in_load(ref_count, var_map, wrapped, free_variable_indices)
      if ref_count[self].nil? then
        @parameters.map! {|param| param. wrap_recurring_expressions_in_load(ref_count, var_map, wrapped, free_variable_indices) }
        return self
      end

      if var_map.include?(self) then # the expression is already mapped to a variable index
        ref_count[self] -= 1
        if ref_count[self] == 0 then # it is the last time expressions is used
          # reuse the variable and flush from var_map
          free_variable_indices << var_map[self]
          Load.new(var_map.delete(self))
        end
      else # it is the first time the expression is used
        # wrap child nodes as well
        @parameters.map! {|param| param. wrap_recurring_expressions_in_load(ref_count, var_map, wrapped, free_variable_indices) }

        # allocate index of free variable
        var = free_variable_indices.pop
        var = var_map.size if var.nil?
        var_map[self] = var
        wrapped << self
      end
      Load.new(var_map[self])
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
    end

    def can_be_cached?
      true
    end

    def <=>(anOther)
      diff = Expression.compare_type_order(type, anOther.type)
      return diff unless diff == 0
      diff = @parameters.size <=> anOther.parameters.size
      return diff unless diff == 0
      @parameters.each_with_index{|param, index|
        diff = param <=> anOther.parameters[index]
        return diff unless diff == 0
      }
      0
    end

    def self.compare_type_order(type_1, type_2)
      order = ['load', 'mul', 'div', 'add', 'sub', 'constant']
      order.index(type_1) <=> order.index(type_2)
    end

    def reduce
      @parameters.map! {|p| p.reduce}
    end
  end

  class Constant < Expression
    attr_reader :value

    def initialize(value)
      super([])
      @value = value.to_i;
    end

    def can_be_cached?
      false
    end

    def to_s
      @value.to_s
    end

    def <=>(anOther)
      diff = Expression.compare_type_order(type, anOther.type)
      return diff unless diff == 0
      value <=> anOther.value
    end

    def reduce
      self
    end
  end

  class Max < Expression

  end

  class Min < Expression

  end

  class ArithmeticExpression < Expression
    def initialize(left_expr, right_expr)
      super([left_expr, right_expr])
    end

    def left
      @parameters[0]
    end

    def right
      @parameters[1]
    end

    def both_parameters_are_constants?
      left.is_a? Constant and right.is_a? Constant
    end

    def to_s
      '(' << parameters_to_s << ')'
    end
    def reduce
      super
      @parameters.sort! if commutative?
      self
    end

    def commutative?
      false
    end
  end

  class Add < ArithmeticExpression
    def parameter_sep
      '+'
    end

    def commutative?
      true
    end

    def reduce
      super
      if right.is_a? Constant and right.value == 0 then
        return left
      elsif right.is_a? Constant and right.value < 0 then
        return Sub.new(left, Constant.new(0 - right.value))
      elsif both_parameters_are_constants? then
        return Constant.new(left.value + right.value)
      elsif left.is_a? Add and left.right.is_a? Constant and right.is_a? Constant then
        return Add.new(left.left, Constant.new(left.right.value + right.value)).reduce
      elsif left.is_a? Sub and left.right.is_a? Constant and right.is_a? Constant then
        return Sub.new(left.left, Constant.new(left.right.value - right.value)).reduce
      end
      self
    end
  end

  class Sub < ArithmeticExpression
    def parameter_sep
      '-'
    end

    def reduce
      super
      if (right.is_a? Constant and right.value == 0) then
        return left
      elsif right.is_a? Constant and right.value < 0 then
        return Add.new(left, Constant.new(0 - right.value))
      elsif (left.is_a? Constant and left.value == 0) then
        return right
      elsif both_parameters_are_constants? then
        return Constant.new(left.value - right.value)
      elsif left.is_a? Add and left.right.is_a? Constant and right.is_a? Constant then
        return Add.new(left.left, Constant.new(left.right.value - right.value)).reduce
      elsif left.is_a? Sub and left.right.is_a? Constant and right.is_a? Constant then
        return Sub.new(left.left, Constant.new(left.right.value + right.value)).reduce
      end
      self
    end
  end

  class Mul < ArithmeticExpression
    def parameter_sep
      '*'
    end

    def commutative?
      true
    end

    def reduce
      super
      if right.is_a? Constant and right.value == 0 then
        return right
      elsif right.is_a? Constant and right.value == 1 then
        return left
      elsif both_parameters_are_constants? then
        return Constant.new(left.value * right.value)
      elsif right.is_a? Div then
        return Div.new(Mul.new(left, right.left), right.right).reduce
      end
      self
    end
  end

  class Div < ArithmeticExpression
    def parameter_sep
      '/'
    end

    def reduce
      super
      if right.is_a? Constant and right.value == 1 then
        return left
      elsif both_parameters_are_constants? then
        left_value = left.value
        gcd = left.value.gcd(right.value)
        if gcd > 1
          return Div.new(Constant.new(left.value / gcd),
                         Constant.new(right.value / gcd)).reduce
        end
      elsif left.is_a? Div then
        return Div.new(left.left, Mul.new(left.right, right)).reduce
      elsif right.is_a? Div then
        return Div.new(Mul.new(left, right.right), right.left).reduce
      end
      self
    end
  end

  class Load < Expression
    attr_reader :variable_index

    def initialize(variable_index)
      @variable_index = variable_index
    end

    def can_be_cached?
      false
    end

    def to_s
      "L[#{@variable_index}]"
    end

    def <=>(anOther)
      diff = Expression.compare_type_order(type, anOther.type)
      return diff unless diff == 0
      variable_index <=> anOther.variable_index
    end

    def reduce
      self
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

      ref_count = {}
      var_map = {}
      free_variable_indices = []

      # find the expressions that should be cached
      @invocations.each{|invoke| invoke.count_cachable_expressions(ref_count) }
      ref_count.delete_if{|expr, count| count <= 1 } # sort out every expression only used once


      @invocations.each{|invoke|
        wrapped = []
        invoke.wrap_recurring_expressions_in_load(ref_count, var_map, wrapped, free_variable_indices)

        wrapped.each{|expr|
          output << Store.new(expr, var_map[expr])
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
