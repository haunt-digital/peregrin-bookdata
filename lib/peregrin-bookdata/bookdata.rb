module PeregrinBookdata
  # https://github.com/joseph/Monocle/wiki/Book-data-object
  class Bookdata
    attr_accessor :peregrin_book, :bookdata_js
    DEFAULT_COVER_COMPONENT_TITLE = 'peregrin-bookdata-generated-cover.xhtml'

    def self.generate(peregrin_book, opts)
      bookdata = self.new(peregrin_book, opts)
      bookdata.bookdata_js
    end


    def initialize(peregrin_book, opts)
      @opts = opts
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


    def get_components_function(cover = true)
      function = ""
      function << "  getComponents: function () {\n"
      function << "    return [\n"

      last = @peregrin_book.components.size - 1

      if @opts[:cover]
        function << "      '#{DEFAULT_COVER_COMPONENT_TITLE}',\n"
      end

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


    def get_component_function(cover = true)
      function = ""
      function << "  getComponent: function (componentId) {\n"
      function << "    return {\n"

      if @opts[:cover]
        function << generate_cover_component
      end

      last_component = @peregrin_book.components.size - 1

      @peregrin_book.components.each_with_index do |component, component_i|
        function << "      '#{component.src}':\n"

        last_line = component.contents.lines.count - 1

        component.contents.lines.each_with_index do |line, line_i|
          component_content = ''

          component_content << "        '#{line.chomp}'"
          component_content << " +\n" if line_i < last_line

          function << component_content
        end

        function << "," if component_i < last_component
        function << "\n\n"
      end

      function << "    }[componentId];\n"
      function << "  },\n"
    end


    def generate_cover_component
      cover_image = @peregrin_book.cover.src

      cover_component_string = "      '#{DEFAULT_COVER_COMPONENT_TITLE}':\n"
      cover_component_string << "        '<?xml version=\"1.0\" encoding=\"utf-8\"?>' +\n"
      cover_component_string << "        '<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"' +\n"
      cover_component_string << "        '  \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">' +\n"
      cover_component_string << "        '<html xmlns=\"http://www.w3.org/1999/xhtml\">' +\n"
      cover_component_string << "        '<meta content=\"text/html; charset=UTF-8\" />' +\n"
      cover_component_string << "        '</head>' +\n"
      cover_component_string << "        '<body>' +\n"
      cover_component_string << "        '<div><img src=\"#{cover_image}\" style=\"width: 100%; height: 100%;\" /></div></body></html>',\n\n"
      cover_component_string
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

    # Monocle is smart enough that this isn't necessary.
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
