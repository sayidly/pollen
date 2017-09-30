#lang pollen

◊; Pollen mode

◊; A tag alone:
◊get-author-name[]

◊; A tag with elements:
Adding ◊em{emphasis to words}.

◊; A tag with attributes and elements:
◊div['((attr1 "val1")(attr2 "val2"))]{My nice div.}

◊; A tag with attributes and elemtns (alternate syntax):
◊div[#:attr1 "val1" #:attr2 "val2"]{My nice div.}


◊; Racket mode

◊; A tag alone:
◊(get-author-name)

◊; A tag with elements:
Adding ◊(em "emphasis to words").

◊; A tag with attributes and elements:
◊(div '((attr1 "val1")(attr2 "val2")) "My nice div.")


◊; Define a tag

◊; A tag holding a value
◊(define author-name "Brennan Huff")

◊; A tag function returning a value
◊(define (get-author-name) "Dale Doback")

◊; Refer to the value held by a tag name
◊author-name
◊|author-name|

◊; Invoke the function
◊get-author-name[]

◊; Refers to the function as a value
◊get-author-name
