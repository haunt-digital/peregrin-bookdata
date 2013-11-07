require 'trollop'
require 'peregrin'
require 'pathname'

module PeregrinBookdata
  Dir[File.dirname(__FILE__) + '/peregrin-bookdata/*.rb'].each do |lib|
    require lib
  end


  class Main
    def self.run(args)
      runner = self.new(args)
      runner.run
    end


    def initialize(args)
      @raw_args = args
    end


    def run
      parse_options
      convert
      output_file
      unpack_assets
    end


    def parse_options
      @opts = Trollop::options do
        banner <<-EOS
peregin-bookdata convets ebooks into monocle bookData javascript objects.

Usage:
       peregrin-bookdata [options] <filename>

where [options] are:
        EOS

        opt :output, "destination for js file and unzipped assets", :default => 'output'
        opt :filename, "name of bookdata js file", :default => 'bookdata.js'
        opt :cover, "include cover image as a page", :default => false
        opt :double, "attempt a double page layout", :default => false
      end

      @epub_file = @raw_args.shift

      Trollop::die "need to supply a filename" unless @epub_file
      Trollop::die "#{file} is not a file" unless File.exist?(@epub_file)
    end


    def convert
      book = PeregrinBookdata::Parser.open(@epub_file)
      @bookdata = PeregrinBookdata::Bookdata.generate(book, @opts)
    end


    def output_file
      filepath = @opts[:output] + '/' + @opts[:filename]

      File.open(filepath, 'w') do |file|
        file.write(@bookdata)
      end
    end


    def unpack_assets
      `cp #{@epub_file} #{@opts[:output]}/#{@epub_file.gsub('.epub', '.zip')}`

      Dir.chdir @opts[:output]

      `unzip #{@epub_file.gsub('.epub', '.zip')}`
      `rm #{@epub_file.gsub('.epub', '.zip')}`
    end
  end
end
