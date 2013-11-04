module PeregrinBookdata
  # https://github.com/joseph/Monocle/wiki/Book-data-object
  class Bookdata
    attr_accessor :peregrin_book, :bookdata_js


    def self.generate(peregrin_book)
      bookdata = self.new(peregrin_book)
      bookdata.bookdata_js
    end


    def initialize(peregrin_book)
      @peregrin_book = peregrin_book
      @bookdata_js = ''

      assemble_javascript
    end


    private


    def assemble_javascript
      @bookdata_js << "var bookData = {\n"
      @bookdata_js << get_components_function
      @bookdata_js << get_contents_function
      @bookdata_js << get_component_function
      @bookdata_js << get_metadata_function
      @bookdata_js << "}\n"
    end


    def get_components_function
      function = ""
      function << "  getComponents: function () {\n"
      function << "    return [\n"

      last = @peregrin_book.components.size - 1

      @peregrin_book.components.each_with_index do |component, i|
        function << "      '#{component.src}'"
        function << "," if i < last
        function << "\n"
      end

      function << "    ];\n"
      function << "  },\n"
    end


    def get_contents_function
      function = ""
      function << "  getContents: function () {\n"
      function << "    return [\n"

      last = @peregrin_book.chapters.size - 1

      @peregrin_book.chapters.each_with_index do |chapter, i|
        function << "      {\n"
        function << "        title: '#{chapter.title}',\n"
        function << "        src: '#{chapter.src}'\n"
        function << "      }"
        function << "," if i < last
        function << "\n"
      end

      function << "    ];\n"
      function << "  },\n"
    end


    def get_component_function
      function = ""
      function << "  getComponent: function (componentId) {\n"
      function << "    return {\n"

      last_component = @peregrin_book.components.size - 1

      @peregrin_book.components.each_with_index do |component, component_i|

        function << "      '#{component.src}':\n"

        last_line = component.contents.lines.count - 1

        component.contents.lines.each_with_index do |line, line_i|
          component_content = ''
          normalized_line = replace_image_asset_urls(line.chomp, component.src)

          component_content << "        '#{normalized_line}'"
          component_content << " +\n" if line_i < last_line

          function << component_content
        end

        function << "," if component_i < last_component
        function << "\n\n"
      end

      function << "    }[componentId];\n"
      function << "  },\n"
    end


    def get_metadata_function
      function = ""
      function << "  getMetaData: function (key) {\n"
      function << "    return {\n"

      last = @peregrin_book.properties.size - 1

      @peregrin_book.properties.each_with_index do |property, i|
        function << "      #{property.key}: '#{property.value}'"
        function << "," if i < last
        function << "\n"
      end

      function << "    }[key];\n"
      function << "  }\n"
    end


    def replace_image_asset_urls(line, source_path)
      match = /src="([^"]+)/.match(line)

      if match
        match.captures.each do |capture|
          asset_path = ::Pathname.new(capture)
          source_path = ::Pathname.new(source_path)
          real_asset_path = source_path.dirname + asset_path

          line.gsub!(/#{Regexp.escape(capture)}/, real_asset_path.to_s)
        end
      end

      line
    end
  end
end
