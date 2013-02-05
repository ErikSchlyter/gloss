Feature: Normalization
  In order to compare and reduce expressions correctly
  As an optimization function
  I want to each expression to be expressed as short as possible

  Scenario: Comparing different expression types
    Given the following list of expressions: add, constant, div, load, max, min, mul, sub
    When sorting them according to parameter order
    Then the order should be: max, min, load, mul, div, add, sub, constant

  Scenario Outline: Reducing expressions
    Given the <expression> to reduce
    When invoking reduce
    Then it should return an equal expression that is <reduced>
Examples:
      | expression     | reduced         | comment |
      | '(1+2)'        | '3'             | 'reducing +' |
      | '((1+2)+3)'    | '6'             | 'reducing +' |
      | '(2-1)'        | '1'             | 'reducing -' |
      | '((3-2)-1)'    | '0'             | 'reducing -' |
      | '(3-5)'        | '-2'            | 'reducing -' |

      | '(2*1)'        | '2'             | 'reducing *' |
      | '((4*3)*2)'    | '24'            | 'reducing *' |

      | '<(3)'         | '3'             | 'reducing min' |
      | '<(3,4,5)'     | '3'             | 'reducing min' |
      | '<(<(3,4),1)'  | '1'             | 'reducing min' |

      | '>(3)'         | '3'             | 'reducing max' |
      | '>(3,4)'       | '4'             | 'reducing max' |
      | '>(>(3,4),1)'  | '4'             | 'reducing max' |

      | '-3'           | '-3'            | 'reducing negation' |
      | '-(3-5)'       | '2'             | 'reducing negation' |
      | '-a'           | '-a'            | 'reducing negation' |
      | '---a'         | '-a'            | 'reducing negation' |
      | '----a'        | 'a'             | 'reducing negation' |

      | '(1+x)'        | '(x+1)'         | 'sorting' |
      | '(x+1)'        | '(x+1)'         | 'sorting' |
      | '(1+(a+b))'    | '((a+b)+1)'     | 'sorting' |

      | '(2*x)'        | '(x*2)'         | 'sorting' |
      | '(x*2)'        | '(x*2)'         | 'sorting' |
      | '(a*b)'        | '(a*b)'         | 'sorting' |
      | '(b*a)'        | '(a*b)'         | 'sorting' |
      | '(2*(b*a))'    | '((a*b)*2)'     | 'sorting' |

      | '<(b,a)'       | '<(a,b)'        | 'sorting' |
      | '<(<(c,3,b),a)'| '<(a,b,c,3)'    | 'sorting' |

      | '(x+0)'        | 'x'             | 'reducing' |
      | '(0+x)'        | 'x'             | 'reducing' |

      | '(x-0)'        | 'x'             | 'reducing' |
      | '(0-x)'        | '-x'            | 'reducing' |

      | '(x*0)'        | '0'             | 'reducing' |
      | '(0*x)'        | '0'             | 'reducing' |
      | '(x*1)'        | 'x'             | 'reducing' |
      | '(1*x)'        | 'x'             | 'reducing' |
      | '(x*-1)'       | '-x'            | 'reducing' |
      | '(x*-5)'       | '-(x*5)'        | 'bubble negation' |
      | '(x*(0-y))'    | '-(x*y)'        | 'bubble negation' |
      | '(0-(x*(0-y)))'| '(x*y)'         | 'bubble negation' |

      | '(1/3)'        | '(1/3)'         | 'reducing' |
      | '(2/6)'        | '(1/3)'         | 'reducing' |
      | '(3/1)'        | '3'             | 'reducing' |
      | '(x/-1)'       | '-x'            | 'reducing' |
      | '(x/-5)'       | '-(x/5)'        | 'bubble negation' |
      | '(x/(0-y))'    | '-(x/y)'        | 'bubble negation' |
      | '(0-(x/(0-y)))'| '(x/y)'         | 'bubble negation' |

      | '(((1+2)+x)+3)'| '(x+6)'         | 'reducing' |
      | '(1+(2+(x+3)))'| '(x+6)'         | 'reducing' |
      | '((x-3)-1)'    | '(x-4)'         | 'reducing' |
      | '((x-1)+3)'    | '(x+2)'         | 'reducing' |
      | '((x+3)-1)'    | '(x+2)'         | 'reducing' |
      | '((x+1)-3)'    | '(x-2)'         | 'reducing' |

      | '(a*(b/c))'    | '((a*b)/c)'     | 'avoid loss in precision' |
      | '((a/b)/c)'    | '(a/(b*c))'     | 'avoid loss in precision' |
      | '(a/(b/c))'    | '((a*c)/b)'     | 'avoid loss in precision' |
      | '(9/(3/7))'    | '21'            | 'avoid loss in precision' |
      | '((a/b)*(c/d))'| '((a*c)/(b*d))' | 'avoid loss in precision' |

