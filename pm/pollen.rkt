#lang racket
(require txexpr)
(provide author em)
(define author "Trevor Goodchild")
(define (em . elements)
  (txexpr 'extra-big empty elements))
