$:.unshift(File.dirname(__FILE__) + '/../../lib/')
require 'gloss/expression'
include Gloss

Given /^the following list of expressions: (.*)$/ do |list|
  @expressions = list.split(', ')
end

When /^sorting them according to parameter order$/ do
  @expressions.sort!{|a,b| Expression.compare_type_order(a,b) }
end

Then /^the order should be: (.+)$/ do |list|
  expected = list.split(', ')
  @expressions.should == expected
end


Given /^the '(.*)' to reduce$/ do |expression|
  @expression = Gloss::parse_intermediate(expression)
end

When /^invoking reduce$/ do
  @expression = @expression.reduce
end

Then /^it should return an equal expression that is '(.+)'$/ do |expected|
  @expression.should == Gloss::parse_intermediate(expected)
end


