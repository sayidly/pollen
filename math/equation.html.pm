#lang pollen
◊(define ($ . xs)
  `(mathjax ,(apply string-append `("$" ,@xs "$"))))
◊(define ($$ . xs)
  `(mathjax ,(apply string-append `("$$" ,@xs "$$"))))

◊h1{I wonder if ◊${2^{\aleph_\alpha} = \aleph_{\alpha+1}}?}
