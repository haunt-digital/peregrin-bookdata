# peregrin-bookdata

A wrapper for [peregrin](https://github.com/joseph/peregrin) which generates a [javascript object](https://github.com/joseph/Monocle/wiki/Book-data-object) from an .epub, suitable for use with [Monocle](https://github.com/joseph/Monocle).

## Usage

    $ ruby bin/peregrin-bookdata book.epub -o book.js

It is expected that all static assets from your .epub are provided by your webserver in the same structure as the original epub, at the same level as Monocle.

peregrin-bookdata is rough, and supplied completely 'as is'
