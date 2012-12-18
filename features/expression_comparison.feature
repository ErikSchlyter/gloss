Feature: Expression comparison
  In order to compare and distinguish expressions
  As a optimization function
  I want to sort and detect duplicate expressions

  Scenario: When comparing two constants
    Given a constant '3' identified as 'a'
    And a constant '3' identified as 'b'
    When comparing 'a' <=> 'b'
    Then it should yield 0

    Given a constant '3' identified as 'a'
    And a constant '7' identified as 'b'
    When comparing 'a' <=> 'b'
    Then it should yield -1
    When comparing 'b' <=> 'a'
    Then it should yield 1

  Scenario: When an addition is compared with another addition
    Given an expression '(3+2)' identified as 'a'
    And an expression '(3+2)' identified as 'b'
    When comparing 'a' <=> 'b'
    Then it should yield 0

  Scenario: When an expression is compared with a different kind of expression (class name comparison)
    Given an expression '(3*2)' identified as 'a'
    And an expression '(3+2)' identified as 'b'
    When comparing 'a' <=> 'b'
    Then it should yield 1

    When comparing 'b' <=> 'a'
    Then it should yield -1
