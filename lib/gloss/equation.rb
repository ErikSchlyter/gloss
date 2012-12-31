module Gloss


  class SystemOfLinearEquations

    attr_reader :identifiers, :equations
    def initialize
      @identifiers = {}
      @equations = []
    end

    def add_equation(hash_with_factors)
      eq = LinearEquation.new
      @equations << eq

      hash_with_factors.each{|label, factor|
        @identifiers[label] = Identifier.new(label) unless @identifiers.include?(label)
        eq.add_term!(Rational(factor.to_s), @identifiers[label])
      }
      eq
    end

    def reduce_to_canonical!(identifier_order=@identifiers.values)
      reduce_to_row_echelon!(0,0,identifier_order)

      (@equations.size-1).downto(0) {|src_index|
        (src_index-1).downto(0){|target_index|
          id = most_significant_term(identifier_order, @equations[src_index])
          @equations[target_index].reduce_term!(id, @equations[src_index])
        }
      }
    end
    def most_significant_term(identifier_order, equation)
      identifier_order.each{|id| return id if equation.terms[id] != nil and equation.terms[id] != 0 }
    end

    def reduce_to_row_echelon!(eq_index=0, id_index=0, identifier_order=@identifiers.values)
      pivot_eq_index = determine_index_of_pivot_equation(eq_index, identifier_order[id_index])
      swap_equations!(eq_index, pivot_eq_index)

      if @equations[eq_index].terms[identifier_order[id_index]] == nil then
        if id_index < identifier_order.size - 1 then
          return reduce_to_row_echelon!(eq_index, id_index+1, identifier_order)
        end
        return @equations
      end

      @equations[eq_index].normalize!(identifier_order[id_index])
      reduce_equations_below_index!(eq_index, identifier_order[id_index])

      if eq_index < @equations.size - 1 and id_index < identifier_order.size - 1 then
        return reduce_to_row_echelon!(eq_index+1, id_index+1)
      end
      @equations
    end

    def determine_index_of_pivot_equation(eq_index, id)
      sub_index = @equations[eq_index..-1].index{|equation| equation.terms[id] != nil}
      eq_index + (sub_index || 0)
    end

    def swap_equations!(index_a, index_b)
      @equations[index_a], @equations[index_b] = @equations[index_b], @equations[index_a]
    end

    def reduce_equations_below_index!(eq_index, identifier)
      @equations[(eq_index+1)..-1].each{|eq| eq.reduce_term!(identifier, @equations[eq_index])}

      pop_empty_equations_at_tail!
    end

    def pop_empty_equations_at_tail!
      @equations.pop while @equations.size > 0 and @equations.last.terms.size == 0
    end

    def to_s
      @equations.to_s
    end

    def to_hash_array
      @equations.collect{|eq| eq.to_hash}
    end

  end

  class LinearEquation
    include Comparable

    attr_reader :terms # map between Identifier -> factor

    def initialize
      @terms = Hash.new
    end

    def add_term!(factor, identifier)
      return if factor == 0

      @terms[identifier] = factor
    end

    def normalize!(identifier)
      divisor = @terms[identifier]
      @terms.each{|id, factor| @terms[id] = Rational(factor,divisor)}
    end

    def reduce_term!(identifier, otherEquation)
      div = Rational(@terms[identifier] || 0, otherEquation.terms[identifier] )

      otherEquation.terms.each{|id, factor|
        @terms[id] = (@terms[id] || 0) - factor * div
        @terms.delete(id) if @terms[id] == 0
      }
    end

    def <=>(anOther)
      terms.keys <=> anOther.terms.keys
    end

    def to_s
      @terms.map{|id, factor| "#{id.to_s}*#{factor.to_s}"}.join(' + ') << ' = 0'
    end

    def to_hash
      hash = Hash.new
      @terms.collect{|id,factor| hash[id.to_s] = factor }
      hash
    end
  end

  class Identifier
    include Comparable

    attr_reader :label

    def initialize(label)
      fail unless label.is_a? String

      @label = label
    end

    def <=>(anOther)
      @label <=> anOther.label
    end

    def to_s
      @label.to_s
    end
  end
end

