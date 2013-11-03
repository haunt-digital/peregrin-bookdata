module PeregrinBookdata
  class Parser
    def self.open(file)
      epub = Peregrin::Epub.read(file)
      epub.to_book
    end
  end
end
