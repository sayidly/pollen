#lang pollen

◊(require pollen/tag)

◊(define-tag-function (em attributes elements)
  `(extra ,attributes (big ,@elements)))

I want to attend ◊em[#:key "value"]{RacketCon}.
