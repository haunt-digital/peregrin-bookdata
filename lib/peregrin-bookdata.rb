require 'trollop'
require 'peregrin'
require 'pathname'

module PeregrinBookdata
  Dir[File.dirname(__FILE__) + '/peregrin-bookdata/*.rb'].each do |lib|
    require lib
  end


  class Main
    def self.run(args)
      opts = Trollop::options do
        banner PeregrinBookdata::Main.usage
        opt :output, "destination for js file", :type => :string
      end

      file = args.shift

      unless file
        Trollop::die "need to supply a filename"
      end

      unless File.exist?(file)
        Trollop::die "#{file} is not a file"
      end

      book = PeregrinBookdata::Parser.open(file)
      bookdata = PeregrinBookdata::Bookdata.generate(book)

      if opts[:output]
        File.open(opts[:output], 'w') { |file| file.write(bookdata) }
      else
        puts bookdata
      end
    end


    def self.usage
      <<-EOS
peregin-bookdata convets ebooks into monocle bookData javascript objects.

Usage:
       peregrin-bookdata [options] <filename>

where [options] are:
      EOS
    end
  end
end
