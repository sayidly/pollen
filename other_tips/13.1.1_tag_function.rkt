#lang pollen

◊(define author-name "Brennan Huff")
◊author-name

◊(define (get-author-name) "Dale Doback")
◊get-author-name[]

◊(define (em . parts) `(big ,@parts))
I want to attend ◊em{RacketCon ◊strong{this} year}.

◊(format "String with variable: ~a" variable-name)

◊(->html '(div "A raw integer indicates a character code: " 42))

◊(->html `(div "Use format to make it a string: " ,(format "~a" 42)))