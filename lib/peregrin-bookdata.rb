require 'trollop'
require 'peregrin'
require 'pathname'

module PeregrinBookdata
  Dir[File.dirname(__FILE__) + '/peregrin-bookdata/*.rb'].each do |lib|
    require lib
  end


  class Main
    def self.run(args)
      $opts = Trollop::options do
        banner PeregrinBookdata::Main.usage
        opt :output, "destination for js file"
      end

      file = args.shift

      unless file
        Trollop::die "need to supply a filename"
      end

      unless File.exist?(file)
        Trollop::die "#{file} is not a file"
      end

      PeregrinBookdata::Bookdata.generate PeregrinBookdata::Parser.open(file)
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
