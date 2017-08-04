#lang pollen/mode racket/base
(require pollen/tag)
 
(define link (default-tag-function 'a))
 
(define (home-link)
  (link #:href "index.html" "Click to go home"))
 
(define (home-link-pollen-style)
  ◊link[#:href "index.html"]{Click to go home})
 
