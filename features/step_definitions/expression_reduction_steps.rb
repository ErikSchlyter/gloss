$:.unshift(File.dirname(__FILE__) + '/../../lib/')
require 'gloss/expression'
include Gloss

Given /^the '(.*)' to reduce$/ do |expression|
  @expression = Gloss::parse_intermediate(expression)
end

When /^converting it to reduced form$/ do
  @expression = @expression.reduce
end

Then /^it should match the mathematically equal but minimized expression '(.+)'$/ do |expected|
  @expression.should == Gloss::parse_intermediate(expected)
end


