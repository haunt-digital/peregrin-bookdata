module PeregrinBookdata
  # https://github.com/joseph/Monocle/wiki/Book-data-object

  class Bookdata
    require 'ostruct'

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

      if @opts[:cover]
        generate_cover_component
      end

      if @opts[:double]
        restructure_for_double_page_layout
      end

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


    def restructure_for_double_page_layout
      components = @peregrin_book.components
      new_components = []

      components.each_slice(2) do |pair|
        new_components << combine_component_contents(pair)
      end


      @peregrin_book.components = new_components

      fix_for_cover_image_url
    end


    def fix_for_cover_image_url
      require 'pathname'
      path = Pathname.new(@peregrin_book.components.first.src)
      i = -1
      puts path.ascend {|v| i+=1 }

      str = ''
      i.times { str = '../' + str }

      cover_path = @peregrin_book.cover.src
      new_cover_path = str + cover_path
      @peregrin_book.components.first.contents.gsub!(cover_path, new_cover_path)
      puts @peregrin_book.components.first.contents
    end


    def combine_component_contents(pair)
      new_component = OpenStruct.new

      if pair.length > 1
        src = pair[1].src
      else
        src = pair.first.src
      end

      new_component.src = src

      new_contents = double_iframe_component_body(pair)

      new_component.contents = new_contents

      new_component
    end


    def double_iframe_component_body(pair)
      require 'cgi'

      resize_styles = <<-EOS
<style>
  img, video, object {
  max-height: 95% !important;
  height: auto !important;
}
body * {
  max-width: 100% !important;
}
</style>
      EOS

      resize_body_tag = <<-EOS
<body style="margin: 0px; padding: 0px; height: 100%; width: 100%; position: absolute; -webkit-column-width: 464px; -webkit-column-gap: 20px; -webkit-transform: translateX(0px);">
      EOS

      new_contents = <<-EOS
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<meta content="text/html; charset=UTF-8" />
<style>
  img, video, object {
  max-height: 95% !important;
  height: auto !important;
}
body * {
  max-width: 100% !important;
}
</style>
<body>
      EOS

      pair.each do |component|
        new_contents << "<iframe height=\"100%\" width=\"48%\" style=\"display:inline;\" scrolling=\"no\" frameborder=\"0\" srcdoc=\""
        resizable_contents = component.contents.gsub('</head>', "#{resize_styles}\n</head>")
        resizable_contents = resizable_contents.gsub('<body>', resize_body_tag)
        single_line_contents = resizable_contents.gsub('\n', '')
        new_contents << CGI.escape_html(single_line_contents)
        new_contents<< "\"></iframe>\n"
      end

      new_contents << '</body></html>'
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

      function << component_ingest

      function << "    }[componentId];\n"
      function << "  },\n"
    end


    def component_ingest
      function = ''

      components = @peregrin_book.components

      last_component = components.size - 1

      components.each_with_index do |component, component_i|
        last_line = component.contents.lines.count - 1

        function << "      '#{component.src}':\n"

        component.contents.lines.each_with_index do |line, line_i|
          component_content = "        '#{line.chomp}'"
          component_content << " +\n" if line_i < last_line
          function << component_content
        end

        function << "," if component_i < last_component
        function << "\n\n"
      end

      function
    end


    def generate_cover_component
      cover_image = @peregrin_book.cover.src

      cover = OpenStruct.new

      cover.src = DEFAULT_COVER_COMPONENT_TITLE
      cover.contents = <<-EOS
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<meta content="text/html; charset=UTF-8" />
</head><body>
<div><img src="#{cover_image}" style="width: 100%; height: 100%;" /></div>
</body></html>
      EOS

      @peregrin_book.components.unshift(cover)
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
  end
end
