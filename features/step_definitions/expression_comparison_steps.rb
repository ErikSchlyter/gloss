$:.unshift(File.dirname(__FILE__) + '/../../lib/')
require 'gloss/expression'
include Gloss

Given /^a constant '(\d+)' identified as '(.+)'$/ do |expr, var|
  code = Gloss::parse_intermediate(expr)
  eval "$#{var}=code"
end

When /^comparing '(.+)' <=> '(.+)'$/ do |a, b|
  eval "@cmp = $#{a} <=> $#{b}"
end

Then /^it should yield (.+)$/ do |value|
  @cmp.should == value.to_i
end

