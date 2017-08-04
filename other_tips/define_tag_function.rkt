#lang pollen
◊(require pollen/tag)
◊(define-tag-function (heading attrs elems)
  (define level (cadr (assq 'level attrs)))
  `(,(string->symbol (format "h~a" level)) ,@elems))
 
◊heading[#:level 1]{Major league}
◊heading[#:level 2]{Minor league}
◊heading[#:level 6]{Trivial league}