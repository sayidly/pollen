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
    The previous is <a href="◊|(previous here)|">◊|(previous here)|</a>.
    The next is <a href="◊|(next here)|">◊|(next here)|</a>.
  </body>
</html>
