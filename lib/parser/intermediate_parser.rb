require 'treetop'
require 'parser/intermediate'
require 'gloss/expression'

module Gloss

  def Gloss.parse_intermediate(expr)
    parser = IntermediateParser.new
    syntax_tree = parser.parse(expr,:root => :arbitrary)
    fail "failed parsing '#{expr}', #{parser.failure_reason}" if syntax_tree.nil?
    syntax_tree.create
  end

end
