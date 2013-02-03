require 'treetop'
require 'parser/intermediate'
require 'parser/gloss_language'
require 'gloss/expression'

module Gloss

  def Gloss.parse_intermediate(expr)
    parser = IntermediateParser.new
    syntax_tree = parser.parse(expr,:root => :arbitrary)
    fail "failed parsing '#{expr}', #{parser.failure_reason}" if syntax_tree.nil?
    syntax_tree.create
  end

  def Gloss.parse_linear_equation(expr)
    parser = GlossParser.new
    syntax_tree = parser.parse(expr,:root => :equality)
    fail "failed parsing '#{expr}', #{parser.failure_reason}" if syntax_tree.nil?
    syntax_tree.create
  end
end
