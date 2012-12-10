require 'gloss/expression'

module Gloss
  describe 'Expression' do
    describe '#wrapped_in_load_statement' do
      before(:each) do
        @input = Add.new(Constant.new(2), Constant.new(3))
      end

      context 'given the expression is not cachable' do
        it 'should return the original expression' do
          wrapped = @input.wrapped_in_load_statement

          wrapped.should == @input
        end
      end

      context 'given the expression is cachable' do
        it 'should return a Load statement' do
          Mul.new(@input, @input) # make sure input is used >= 2 times
          wrapped = @input.wrapped_in_load_statement

          wrapped.should be_a Load
        end

        it 'should add the expression to the list given as parameter' do
          Mul.new(@input, @input) # make sure input is used >= 2 times

          list_of_wrapped_expressions = []
          wrapped = @input.wrapped_in_load_statement(list_of_wrapped_expressions)

          list_of_wrapped_expressions[0].should == @input
        end

        it 'should base variable_index on the index in the list given as parameter' do
          Mul.new(@input, @input) # make sure input is used >= 2 times

          list_of_wrapped_expressions = []
          wrapped = @input.wrapped_in_load_statement(list_of_wrapped_expressions)

          list_of_wrapped_expressions.index(@input).should == wrapped.variable_index
        end
      end

    end
  end

  describe 'Statement' do
    describe '#cache_parameters!' do
      before(:each) do
        cachable1 = Add.new(Constant.new(2), Constant.new(3))
        cachable2 = Mul.new(cachable1, cachable1)
        @input = Add.new(cachable2, cachable2)
        @input.to_s.should == '(((2+3)*(2+3))+((2+3)*(2+3)))'
      end

      it 'should wrap all cachable parameters within load-statements' do
        @input.cache_parameters!
        @input.to_s.should == '(L[1]+L[1])'
      end

      it 'should return a list of the expressions that were wrapped' do
        wrapped = @input.cache_parameters!
        wrapped[0].to_s.should == '(2+3)'
        wrapped[1].to_s.should == '(L[0]*L[0])'
      end
    end
  end
end
