$:.unshift(File.dirname(__FILE__) + '/../../lib/')
require 'gloss/equation'
include Gloss

Given /^the matrix$/ do |table|
  @linear_system = SystemOfLinearEquations.new
  table.hashes.each{|eq| @linear_system.add_equation(eq)}
end

When /^reduced to canonical$/ do
  @linear_system.reduce_to_canonical!
end

Then /^it should equal$/ do |table|
  expected = table.hashes.collect{|eq|
    eq.inject({}) { |h, (k, v)| h[k] = v.to_r; h }
  }
  expected.each{|eq| eq.delete_if{|id,factor| factor == 0} }

  @linear_system.to_hash_array.should == expected
end


