# peregrin-bookdata

A wrapper for [peregrin](https://github.com/joseph/peregrin) which generates a [javascript object](https://github.com/joseph/Monocle/wiki/Book-data-object) from an .epub, suitable for use with [Monocle](https://github.com/joseph/Monocle).

## Usage

    $ ruby bin/peregrin-bookdata book.epub

<pre>
  Usage:
         peregrin-bookdata book.epub [options] <filename>

  where [options] are:
           --output, -o <s>:   destination for js file and unzipped assets
                               (default: output)
         --filename, -f <s>:   name of bookdata js file (default: bookdata.js)
    --cover, --no-cover, -c:   include cover image as a page (default: true)
                 --help, -h:   Show this message
</pre>

It is expected that all static assets from your .epub are provided by your webserver in the same structure as the original epub, at the same level as Monocle.

peregrin-bookdata is rough, and supplied completely 'as is'
