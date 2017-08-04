#lang pollen

◊; quasiquote unqueote unquote-splicing
◊(quasiquote (0 1 2))
◊(quasiquote (0 (unquote (+ 1 2)) 4))
◊(quasiquote (0 (unquote-splicing (list 1 2)) 4))
◊(quasiquote (0 (unquote-splicing 1)))

◊; quasiquote = ` unquote = , unquote-splicing = ,@
◊`(0 1 2)
◊`(0 ,(+ 1 2) 4)
◊`(0 ,@(list 1 2) 4)
◊`(0 ,@(list 1))

◊; other examples
◊`(1 `,(+ 1 ,(+ 2 3)) 4)
◊`(1 ```,,@,,@(list (+ 1 2)) 4)

◊`(,1 2 3)