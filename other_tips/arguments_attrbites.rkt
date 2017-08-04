#lang pollen
◊title['((class "red")(id "first"))]{The Beginning of the End}

◊; Other options
◊title[#:class "red" #:id "first"]{The Beginning of the End}

◊; Use string arguments
◊title[#:class (number->string (* 6 7)) #:id "first"]{The Beginning of the ENd}

◊; Use Variable
◊(define name "Brennan")
◊title[#:class "red" #:id ◊name]{The Beginning of the End}