@expression
Feature: Expression parameter normalization
  In order to compare and reduce expressions correctly
  As an reduction function
  I want the parameters of a commutative expression to be sorted according to a normalized form.

  Scenario: Comparing different expression types
    Given the following list of expression types: add, constant, div, load, max, min, mul, sub
    When sorting the parameters of a commutative expression
    Then the parameters should be sorted accordingly: max, min, load, mul, div, add, sub, constant
