#lang pollen

◊div{◊string->symbol{copy}
      ◊string->number{169}}

◊(require pollen/template)
◊->html{◊div{copy 169}}
◊->html{◊div{◊string->symbol{copy} ◊string->number{169}}}