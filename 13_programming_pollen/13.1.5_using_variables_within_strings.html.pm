#lang pollen

◊(->html '(div "A raw integer indicates a character code: " 42))

◊(->html `(div "Use format to make it a string: " ,(format "~a" 42)))
