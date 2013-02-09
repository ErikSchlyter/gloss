@codegeneration
Feature: Memoization
  In order to avoid the same expressions to be executed multiple times
  As a generated method
  I want to cache the values of executed expressions into temporary variables

  Scenario: When no expression is used twice
    Given an expression '(2+3)' identified as 'a'
    And an expression '(5-7)' identified as 'b'
    When generating the method foo(){ bar($a, $b) }
    Then it should equal 'foo(){ bar((2+3), (5-7)) }'

  Scenario: When an expression is used twice
    Given an expression '(2+3)' identified as 'a'
    When generating the method foo(){ bar($a, $a) }
    Then it should equal 'foo(){ S[0]((2+3)); bar(L[0], L[0]) }'

  Scenario: When two expressions are used twice
    Given an expression '(2+3)' identified as 'a'
    And an expression '(5-7)' identified as 'b'
    When generating the method foo(){ bar( (($a+$b) * ($b+$a)) ) }
    Then it should equal 'foo(){ S[0]((2+3)); S[1]((5-7)); bar(((L[0]+L[1])*(L[1]+L[0]))) }'

  Scenario: When an expression is used twice in another expression that is used twice
    Given an expression '(2+3)' identified as 'a'
    And an expression '($a*$a)' identified as 'b'
    When generating the method foo(){ bar($b, $b); }
    Then it should equal 'foo(){ S[0]((2+3)); S[1]((L[0]*L[0])); bar(L[1], L[1]) }'
