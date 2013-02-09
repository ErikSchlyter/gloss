@expression
Feature: Expression reduction
  In order to minimize expressions and avoid loss of precision due to integer division
  As a developer
  I want the generated expressions to use as few operations as possible

  Scenario Outline: Reducing ambigious expressions
    Given the <expression> to reduce
    When converting it to reduced form
    Then it should match the mathematically equal but minimized expression <reduced>

    Examples:
      | expression     | reduced         |
      | '(x+0)'        | 'x'             |
      | '(0+x)'        | 'x'             |
      | '(x-0)'        | 'x'             |
      | '(0-x)'        | '-x'            |
      | '(x*0)'        | '0'             |
      | '(0*x)'        | '0'             |
      | '(x*1)'        | 'x'             |
      | '(1*x)'        | 'x'             |
      | '(-1*x)'       | '-x'            |
      | '(x*-1)'       | '-x'            |
      | '(x/-1)'       | '-x'            |
      | '-x'           | '-x'            |
      | '---x'         | '-x'            |
      | '----x'        | 'x'             |

  Scenario Outline: Evaluating constant expressions
    Given the <expression> to reduce
    When converting it to reduced form
    Then it should match the mathematically equal but minimized expression <reduced>

    Examples:
      | expression     | reduced         |
      | '(1+2)'        | '3'             |
      | '((1+2)+3)'    | '6'             |
      | '(2-1)'        | '1'             |
      | '((3-2)-1)'    | '0'             |
      | '(3-5)'        | '-2'            |

      | '(2*1)'        | '2'             |
      | '((4*3)*2)'    | '24'            |

      | '<(3)'         | '3'             |
      | '<(3,4,5)'     | '3'             |
      | '<(<(3,4),1)'  | '1'             |

      | '>(3)'         | '3'             |
      | '>(3,4)'       | '4'             |
      | '>(>(3,4),1)'  | '4'             |

      | '-3'           | '-3'            |
      | '-(3-5)'       | '2'             |

      | '(1/3)'        | '(1/3)'         |
      | '(2/6)'        | '(1/3)'         |
      | '(3/1)'        | '3'             |
      | '(9/(3/7))'    | '21'            |

      | '(((1+2)+x)+3)'| '(x+6)'         |
      | '(1+(2+(x+3)))'| '(x+6)'         |
      | '((x-3)-1)'    | '(x-4)'         |
      | '((x-1)+3)'    | '(x+2)'         |
      | '((x+3)-1)'    | '(x+2)'         |
      | '((x+1)-3)'    | '(x-2)'         |

  Scenario Outline: Sorting parameters for commutative expressions
    Given the <expression> to reduce
    When converting it to reduced form
    Then it should match the mathematically equal but minimized expression <reduced>

    Examples:
      | expression         | reduced         |
      | '(1+x)'            | '(x+1)'         |
      | '(x+1)'            | '(x+1)'         |
      | '(1+(x+y))'        | '((x+y)+1)'     |

      | '(2*x)'            | '(x*2)'         |
      | '(x*2)'            | '(x*2)'         |

      | '(x*y)'            | '(x*y)'         |
      | '(y*x)'            | '(x*y)'         |

      | '(2*(y*x))'        | '((x*y)*2)'     |

      | '<(y,x)'           | '<(x,y)'        |
      | '<(<(z,3,y),x)'    | '<(x,y,z,3)'    |

  Scenario Outline: Pulling negations upwards
    Given the <expression> to reduce
    When converting it to reduced form
    Then it should match the mathematically equal but minimized expression <reduced>

    Examples:
      | expression     | reduced         |
      | '(x*-5)'       | '-(x*5)'        |
      | '(x*(0-y))'    | '-(x*y)'        |
      | '(0-(x*(0-y)))'| '(x*y)'         |
      | '(x/-5)'       | '-(x/5)'        |
      | '(x/(0-y))'    | '-(x/y)'        |
      | '(0-(x/(0-y)))'| '(x/y)'         |

  Scenario Outline: Avoiding loss in precision
    Given the <expression> to reduce
    When converting it to reduced form
    Then it should match the mathematically equal but minimized expression <reduced>

    Examples:
      | expression     | reduced         |
      | '(a*(b/c))'    | '((a*b)/c)'     |
      | '((a/b)/c)'    | '(a/(b*c))'     |
      | '(a/(b/c))'    | '((a*c)/b)'     |
      | '((a/b)*(c/d))'| '((a*c)/(b*d))' |

