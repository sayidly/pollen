<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>◊(select 'h1 doc), by MB</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
  </head>
  <body>
    ◊(->html doc)
    The current page is called ◊|here|.
    ◊(define prev-page (previous here))
    ◊when/splice[prev-page]{
    The previous is <a href="◊|prev-page|">◊|prev-page|</a>.}
    ◊(define next-page (next here))
    ◊when/splice[next-page]{The next is <a href="◊|(next here)|">◊|(next here)|</a>.}
  </body>
</html>
