require 'gloss/expression'

module Gloss
  describe 'Statement' do
    describe '#count_cachable_expressions' do
      it 'should return a hash that maps each cachable expression to its occurrrence count' do
        add = Add.new(Constant.new(2), Constant.new(3))
        mul = Mul.new(add, add)

        ref_count = mul.count_cachable_expressions

        ref_count.size.should == 2
        ref_count[add].should == 2
        ref_count[mul].should == 1
      end
    end
    describe '#wrap_recurring_expressions_in_load' do
      it 'should return a Load-statement if the expression should be cached' do
        add = Add.new(Constant.new(2), Constant.new(3))
        ref_count = { add => 1 }

        expr = add.wrap_recurring_expressions_in_load(ref_count, {}, [], [])

        expr.should be_an_instance_of Load
      end

      it 'should return itself if it cannot be cached' do
        add = Add.new(Constant.new(2), Constant.new(3))

        expr = add.wrap_recurring_expressions_in_load({}, {}, [], [])

        expr.should == add
      end


      describe 'the ref_count parameter' do
        it 'should reduce the count for each variable that is wrapped in Load-statement' do
          add = Add.new(Constant.new(2), Constant.new(3))
          ref_count = { add => 3 }
          var_map = { add => 1337 }

          add.wrap_recurring_expressions_in_load(ref_count, var_map, [], [])

          ref_count[add].should == 2
        end
      end

      describe 'the var_map parameter' do
        it 'should be assigned a mapping between each expression and its designated free variable index' do
          add = Add.new(Constant.new(2), Constant.new(3))
          mul = Mul.new(add, add)
          ref_count = { add => 7, mul => 9 }
          var_map = {}

          add.wrap_recurring_expressions_in_load(ref_count, var_map, [], [])
          mul.wrap_recurring_expressions_in_load(ref_count, var_map, [], [])

          var_map[add].should == 0
          var_map[mul].should == 1
        end

        it 'should unmap each expression that is wrapped in Load-statement for the last time' do
          add = Add.new(Constant.new(2), Constant.new(3))
          ref_count = { add => 1 }
          var_map = { add => 42 }

          add.wrap_recurring_expressions_in_load(ref_count, var_map, [], [])

          var_map[add].should == nil
        end
      end

      describe 'the wrapped parameter' do
        it 'should contain a list of all expressions that were wrapped in Load-statement for the first time' do
          add = Add.new(Constant.new(2), Constant.new(3))
          ref_count = { add => 1 }
          var_map = {}
          wrapped = []

          add.wrap_recurring_expressions_in_load(ref_count, var_map, wrapped, [])

          wrapped.should include(add)
        end
      end
      describe 'the free_variable_indices parameter' do
        it 'should contain a list of the variable indices that were unmapped' do
          add = Add.new(Constant.new(2), Constant.new(3))
          ref_count = { add => 1 }
          var_map = { add => 42 }
          free_variable_indices = []

          add.wrap_recurring_expressions_in_load(ref_count, var_map, [], free_variable_indices)

          free_variable_indices.should include(42)
        end
      end
    end
  end
end
