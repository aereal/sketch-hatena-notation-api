module HatenaNotationApi
  module Formatter
  end
end

require_relative './list_util'

require 'escape_utils'

class HatenaNotationApi::Formatter::Html
  HEADING = 'Heading'
  LINE = 'Line'
  UNORDERED_LIST = 'UnorderedList'
  UNORDERED_LIST_ITEM = 'UnorderedListItem'
  INLINE_TEXT = 'InlineText'
  INLINE_HTTP = 'InlineHttp'

  def format(ast)
    case ast
    when Array
      blocks = ast.map {|block| format_block(block).to_html }
      blocks.join("\n")
    else
      raise "Unknown root type: #{ast.class}"
    end
  end

  protected def format_block(block)
    case block['Name']
    when HEADING
      tag = Repr::HTML.new(:"h#{block['Level']}")
      block['Content'].each do |inline|
        tag << format_inline(inline)
      end
      tag
    when LINE
      tag = Repr::HTML.new(:p)
      block['Inlines'].each do |inline|
        tag << format_inline(inline)
      end
      tag
    when UNORDERED_LIST
      tag = Repr::HTML.new(:ul)
      block['Items'].each do |item|
        tag << format_block(item)
      end
      tag
    when UNORDERED_LIST_ITEM
      tag = Repr::HTML.new(:li)
      block['Inlines'].each do |inline|
        tag << format_inline(inline)
      end
      tag
    else
      raise "Unknown node: #{block['Name']}"
    end
  end

  protected def format_inline(inline)
    case inline['Name']
    when INLINE_TEXT
      Repr::Text.new(inline['Literal'])
    when INLINE_HTTP
      tag = Repr::HTML.new(:a)
      tag[:href] = inline['Url']
      tag << Repr::Text.new(inline['Url'])
      tag
    else
      raise "Unknown node: #{inline['Name']}"
    end
  end

  module Repr
    class HTML
      def initialize(tag_name)
        @tag_name = tag_name
        @children = []
        @attributes = {}
      end

      def <<(child)
        @children << child
        self
      end

      def []=(attr_name, attr_value)
        @attributes[attr_name] = attr_value
        self
      end

      def html?
        true
      end

      def as_escaped_text
        Text.new(EscapeUtils.escape_html(@repr))
      end

      def to_html
        content = @children.map(&:to_html).reduce(:+)
        attrs = @attributes.map {|(name, value)| '%s="%s"' % [EscapeUtils.escape_html(name.to_s), EscapeUtils.escape_html(value)] }
        attr_str = attrs.empty? ? '' : ' ' + attrs.join(' ')
        "<#{@tag_name}#{attr_str}>#{content}</#{@tag_name}>"
      end
    end

    class Text
      def initialize(repr)
        @repr = EscapeUtils.escape_html(repr)
      end

      def html?
        false
      end

      def plain_text?
        true
      end

      def to_html
        @repr
      end
    end
  end
end
