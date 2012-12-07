$:.unshift(File.dirname(__FILE__) + '/../../lib/')
require 'gloss/expression'
require 'parser/intermediate_parser'
include Gloss

Given /^an expression '(.*?)' identified as '(.*)'$/ do |expr, var|
  code = Gloss::parse_intermediate(expr)
  eval "$#{var}=code"
end

When /^generating the method (.*)/ do |m|
  @gen_code = Gloss::parse_intermediate(m).to_s
end

Then /^it should equal '(.*)'$/ do |code|
  @gen_code.should == code
end

