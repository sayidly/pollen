#lang pollen

◊dept{Dep’t of Blunt Instruments}

◊title{Making a dual typed / untyped Racket library}

◊bigimage["close.jpg"]

◊;{
If you have a function or variable that you only need for the current source file, it’s fine to define it locally. If I ended up needing to use this `sugar` definition in other files, I could move it to my “pollen.rkt”.
}
◊(define sugar ◊gitlink["mbutterick/sugar"]{sugar})

◊extlink["http://www.pacegallery.com/artists/80/chuck-close"]{Chuck Close} is a terrific painter. Primarily a portraitist, he's probably best known for his technique of dividing photos into grids and painting them, one cell at a time. As you can see, even though the overall image is easy to discern, the brushwork and colors in each cell follow a separate logic.

What I like most about Close's grid paintings is that he never resolves their inherent tensions --- between macro and micro, order and disorder, surface and depth, depiction and abstraction. Instead, he keeps these massive works --- they're 8--10 feet tall --- carefully balanced in between. When I stand in front of one of these paintings, I feel like I'm in two places at once. Nice trick.

It's also the kind of trick that Racket is good at. Recently I was wondering how to upgrade my ◊|sugar| utility library for Racket so that it would work with Typed Racket, but without changing how it works in regular Racket.

◊;{
`folded` in action: we put the text of the subhead on the first line, and then the rest of the content starting on the second line. The `folded` tag function knows how to convert this input into the correct result.
}
◊folded{What is Typed Racket?
◊extlink["http://docs.racket-lang.org/ts-guide/"]{Typed Racket} is a dialect of Racket that adds ◊deflink["http://stackoverflow.com/a/1517670/1486915"]{static typing} to the otherwise untyped Racket language. You can explicitly add types to variables and functions using ◊extlink["http://docs.racket-lang.org/ts-guide/more.html#%28part._.Type_.Annotation_and_.Binding_.Forms%29"]{type annotations.} But Typed Racket also has a crafty ◊extlink["http://docs.racket-lang.org/ts-guide/more.html#%28part._.Type_.Inference%29"]{type-inference} system that deduces most of the others. Cleverly, Typed Racket doesn't need a separate compiler. Once it completes its typechecking, you're left with untyped Racket code, which is then compiled as usual.}

◊folded{Why would you use a typed language generally, and Typed Racket in particular?
Typed languages can be faster, because the compiler can eliminate certain checks that would otherwise have to be done when the program runs. This is the main reason I originally investigated Typed Racket. For instance, if you say ◊code{foo = foo + bar} in Python, your intention is to update the value of ◊code{foo} to be the sum of ◊code{bar} and the current value of ◊code{foo}. But even if you don't care about types, Python still does: before it tries to add these two, it has to check that they both hold numeric values (if they don't, you'll get a ◊code{TypeError}). Whereas in a typed program, one could declare them both to be ◊code{Number}s. The program can rely on that promise (and skip checking them for number-ness later).

Note that this is another way of saying that ◊em{every} programming language ◊extlink["https://existentialtype.wordpress.com/2011/03/19/dynamic-languages-are-static-languages/"]{is a statically typed language.} The question is who does the typing (either you, or the program interpreter) and when (either before the program is running, or during). What we call an "untyped" language is better thought of as an expensively typed language. For many tasks, the convenience of not specifying types outweighs this cost. This is why untyped languages are popular for many jobs. But in some cases, you need the extra performance.

The other benefit of a typed language is ◊em{safety}. Type checking is a way of making and verifying claims about the data and functions in your program in a disciplined manner. In that sense, Typed Racket has a lot in common with Racket's ◊extlink["http://docs.racket-lang.org/reference/contracts.html"]{contract system.} But because Typed Racket is verifying the types before the program runs, it can catch subtler errors. In practice, it takes more effort to get a program running in Typed Racket, but once it does, you can be confident that its internal logic is sound. Your effort is repaid later when you spend less time chasing down bugs.
}

◊subhead{The need for speed}

The unavoidable wrinkle in a mixed typed / untyped system is the interaction between typed and untyped code. Most Racket libraries are written with untyped code, and Typed Racket --- now shortening this to TR --- has to use these libraries. TR's job is to insure that your functions and data are what they say they are. So you can't just toss untyped code into the mix --- "don't worry TR, this will work." TR likes you, but it doesn't trust you.

Instead, TR offers a function called ◊docs['typed/racket]{require/typed}. Like the standard ◊docs['racket]{require} function that imports a library into a program, ◊docs['typed/racket]{require/typed} lets you specify the types that TR should apply to the untyped code.

This works well enough, but it has a cost: in this case, TR has to perform its typechecking when the program runs, and it does so by converting these types into Racket contracts. The added cost of a contract isn't a big deal if you use the imported function occasionally.

But if you use the function a lot, the contract can be expensive. My ◊|sugar| library is a collection of little utility and helper functions that get called frequently during a program. When I use them with ◊docs['typed/racket]{require/typed}, in many cases the contract that gets wrapped around the function takes longer than the function itself.

What's the solution? One option would be to convert ◊|sugar| to be a native TR library. That's fine, but this conversion can impose limitations on the library that aren't necessary or desirable for untyped use. For instance, sometimes you need to narrow the interface of an untyped function to make it typable.

Another option would be to create a new version of ◊|sugar| that's typed, and make it available alongside untyped ◊|sugar|. But this means maintaining two sets of code in parallel. Bad for all the usual reasons.

Instead, I wanted to make ◊|sugar| available as both a natively typed and untyped library, while only maintaining one codebase.

◊subhead{Bilingual code}

Typed code naturally has more information in it than untyped code (namely, the type annotations). So my intuition was to convert ◊|sugar| to TR and then generate an untyped version from this code by ignoring the type annotations.

TR makes this easy by offering its ◊code{no-check} dialects. You can write code under ◊code{#lang typed/racket} and then, if you want the typing to be ignored, change that line to ◊code{#lang typed/racket/no-check}, and the program will behave like untyped code.

◊highlight['racket]{
    #lang typed/racket
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))

    (gt 5.0 4.0) ; typecheck error: Floats are not Integers
}

◊highlight['racket]{
    #lang typed/racket/no-check
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))

    (gt 5.0 4.0) ; works because Integer type is ignored
}

This is cool, right? Untyped languages are usually built on top of typed languages, not the other way around. (For instance, the reference implementation of Python, an untyped language, is written in C, a typed language.) By making types an option rather than a requirement, Typed Racket creates new possibilities for how you can use types (what is sometimes called ◊deflink["https://blog.cppcabrera.com/posts/the-importance-of-gradual-types.html"]{gradual typing.})

Compiling a chunk of source code at two locations isn't hard. Racket already has an ◊docs['racket]{include} function that lets you pull in source code from another file. Our first intuition might be to set up three files, like so:

◊filebox-highlight["gt.rkt" 'racket]{
    (provide gt)
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))
}

◊filebox-highlight["typed-gt.rkt" 'racket]{
    #lang typed/racket
    (include "gt.rkt")
}

◊filebox-highlight["untyped-gt.rkt" 'racket]{
    #lang typed/racket/no-check
    (include "gt.rkt")
}

This works, but it's not very ergonomic: ◊code{"gt.rkt"} has no ◊code{#lang} line, so we can't run it directly in DrRacket, which makes editing and testing the file more difficult.

To get around this, I wrote a new function called ◊code{include-without-lang-line} that behaves the same way as ◊docs['racket]{include}, but strips out the ◊code{#lang} line it finds in the included file. That allows us to consolidate the files:

◊filebox-highlight["typed-gt.rkt" 'racket]{
    #lang typed/racket
    (provide gt)
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))
}

◊filebox-highlight["untyped-gt.rkt" 'racket]{
    #lang typed/racket/no-check
    (require sugar/unstable/include)
    (include-without-lang-line "typed-gt.rkt")
}

Suppose we also want the option to add untyped code to the untyped parts of the library. So rather than using ◊code{#lang typed/racket/no-check} directly, we can move this code into a submodule.

◊filebox-highlight["typed-gt.rkt" 'racket]{
    #lang typed/racket
    (provide gt)
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))
}

◊filebox-highlight["untyped-gt.rkt" 'racket]{
    #lang racket
    (provide gt)
    (module typed-code typed/racket/no-check
      (require sugar/unstable/include)
      (include-without-lang-line "typed-gt.rkt"))
    (require 'typed-code)
}

This way, we can ◊code{(require "typed-gt.rkt")} from TR code and get the typed version of the ◊code{gt} function, or ◊code{(require "untyped-gt.rkt")} from untyped Racket code and get the less strict untyped version. But the body of the function only exists in one place.

◊subhead{Bilingual testing}

Testing in Racket is usually handled with the ◊code{rackunit} library. For most test cases in ◊|sugar|, the behavior of the typed and untyped code should be identical. Thus, I didn't want to maintain two largely identical test files. I wanted to write a list of tests and run them in both typed and untyped mode.

Moreover, unlike the library itself, which is set up for the convenience of others, the tests could be set up for the convenience of me. So my goal was to make everything happen within one file. That meant my ◊code{include-without-lang-line} gimmick wouldn't be useful here.

This time, submodules were the solution. Suppose we have a simple ◊code{rackunit} check.

◊highlight['racket]{
    (check-true (gt 42 41))
}

It's clear how we can run this test in typed and untyped contexts using two test files:

◊filebox-highlight["untyped-test.rkt" 'racket]{
    #lang racket
    (require rackunit "untyped-gt.rkt")
    (check-true (gt 42 41))
}

◊filebox-highlight["typed-test.rkt" 'racket]{
    #lang typed/racket
    (require typed/rackunit "typed-gt.rkt")
    (check-true (gt 42 41))
}

Then we can combine them into a single file with submodules:

◊filebox-highlight["bilingual-test.rkt" 'racket]{
    #lang racket

    (module untyped-test racket
      (require rackunit "untyped-gt.rkt")
      (check-true (gt 42 41)))
    (require 'untyped-test)

    (module typed-test typed/racket
      (require typed/rackunit "typed-gt.rkt")
      (check-true (gt 42 41))
    (require 'typed-test)
}

The final maneuver is to make a macro that will take our list of tests and put them into this two-submodule form. Here's a simple way to do it:

◊filebox-highlight["bilingual-test.rkt" 'racket]{
    #lang racket
    (require (for-syntax racket/syntax))

    (define-syntax (eval-as-typed-and-untyped stx)
      (syntax-case stx ()
        [(_ exprs ...)
         (with-syntax ([untyped-sym (generate-temporary)]
                       [typed-sym (generate-temporary)])
           #'(begin
               (module untyped-sym racket
                 (require rackunit "untyped-gt.rkt")
                 exprs ...)
               (require 'untyped-sym)
               (module typed-sym typed/racket
                 (require typed/rackunit "typed-gt.rkt")
                 exprs ...)
               (require 'typed-sym)))]))

    (eval-as-typed-and-untyped
      (check-true (gt 42 41))) ; works
}

We need ◊docs['racket/syntax]{generate-temporary} in case we want to invoke the macro multiple times within the file --- it insures that each submodule has a distinct, nonconflicting name.

◊subhead{Making macros}

Aside from the potentially slower performance, one significant shortcoming of ◊docs['typed/racket]{require/typed} is that it can't be used with macros. But that's not a problem here. If we make a macro version of ◊code{gt}, everything still works:

◊filebox-highlight["typed-gt.rkt" 'racket]{
    #lang typed/racket
    (provide gt gt-macro)
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))
    (define-syntax-rule (gt-macro x y)
      (> x y))
}

◊filebox-highlight["untyped-gt.rkt" 'racket]{
    #lang racket
    (provide gt gt-macro)
    (module typed-code typed/racket/no-check
      (require sugar/unstable/include)
      (include-without-lang-line "typed-gt.rkt"))
    (require 'typed-code)
}

◊filebox-highlight["bilingual-test.rkt" 'racket]{
    #lang racket

    (define-syntax (eval-as-typed-and-untyped stx)
      ... ) ; definition same as above

    (eval-as-typed-and-untyped
      (check-true (gt 42 41)) ; still works
      (check-true (gt-macro 42 41))) ; also works
}

◊subhead{Adding contracts on the untyped side}

Using this technique, nothing stops us from adding contracts to the untyped library that correspond to the typed version of the function:

◊filebox-highlight["typed-gt.rkt" 'racket]{
    #lang typed/racket
    (provide gt)
    (: gt : Integer Integer -> Boolean)
    (define (gt x y)
      (> x y))
}

◊filebox-highlight["untyped-gt.rkt" 'racket]{
    #lang racket
    (provide (contract-out [gt (integer? integer? . -> . boolean?)]))
    (module typed-code typed/racket/no-check
      (require sugar/unstable/include)
      (include-without-lang-line "typed-gt.rkt"))
    (require 'typed-code)
}

◊filebox-highlight["untyped-test.rkt" 'racket]{
    #lang racket
    (require rackunit "untyped-gt.rkt")
    (check-true (gt 42 41)) ; works
    (check-exn exn:fail:contract? (λ _ (gt 42.5 41))) ; fails
}

From here, it's a short step to a ◊em{triple}-mode library: we can make a ◊code{'safe} submodule in ◊code{"untyped-gt.rkt"} that provides the function with a contract, and otherwise provide it without. Details are left as an exercise to the reader. (Hints are available in the ◊|sugar| source.)

◊code{— Matthew Butterick | 6 May 2015}

◊subhead{Pollen source files for this article}

◊show-source-link{pollen.rkt}
◊show-source-link{dual-typed-untyped-library.html.pm}
◊show-source-link{template.html}
◊show-source-link{styles.css.pp}
