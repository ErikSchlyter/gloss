@expression
Feature: Gaussian elimination
  In order to reduce equations
  As an optimization function
  I want a sytem of linear equations converted into reduced row echelon form

  Scenario: A simple matrix
    Given the matrix
      |a|b|c|d|
      |1|2|3|0|
      |4|5|6|0|
      |7|8|9|0|
    When reduced to canonical
    Then it should equal
      |a| b|  c| d|
      |1| 0| -1| 0|
      |0| 1|  2| 0|

  Scenario: A matrix containing gaps in the columns
    Given the matrix
      |a|b|c|d|e|
      |1|0|0|0|0|
      |0|0|1|0|0|
      |0|0|0|1|0|
    When reduced to canonical
    Then it should equal
      |a|b|c|d|e|
      |1|0|0|0|0|
      |0|0|1|0|0|
      |0|0|0|1|0|

  Scenario: A matrix containing gaps in the columns (rearranged)
    Given the matrix
      |a|b|c|d|e|
      |0|0|0|1|0|
      |0|0|1|0|0|
      |1|0|0|0|0|
    When reduced to canonical
    Then it should equal
      |a|b|c|d|e|
      |1|0|0|0|0|
      |0|0|1|0|0|
      |0|0|0|1|0|

  Scenario: The example from Wikipedia's article on Gaussian Elimination
    Given the matrix
      | a | b | c | d |
      | 2 | 1 |-1 | 8 |
      |-3 |-1 | 2 |-11|
      |-2 | 1 | 2 |-3 |
    When reduced to canonical
    Then it should equal
      | a | b | c | d |
      | 1 | 0 | 0 | 2 |
      | 0 | 1 | 0 | 3 |
      | 0 | 0 | 1 |-1 |
