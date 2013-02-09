$:.unshift(File.dirname(__FILE__) + '/../../lib/')
require 'gloss/expression'
include Gloss


Given /^the following list of expression types: (.*)$/ do |list|
  @expressions = list.split(', ')
end

When /^sorting the parameters of a commutative expression$/ do
  @expressions.sort!{|a,b| Expression.compare_type_order(a,b) }
end

Then /^the parameters should be sorted accordingly: (.+)$/ do |list|
  expected = list.split(', ')
  @expressions.should == expected
end
