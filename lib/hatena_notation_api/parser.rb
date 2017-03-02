require 'json'

module HatenaNotationApi
  class Parser
    def initialize(command_path: )
      @command_path = command_path
    end

    def parse(input)
      out = IO.popen([@command_path], 'r+') {|io|
        io.write(input)
        io.close_write
        io.read
      }
      is_error = out.start_with?('! Error:')
      if is_error
        _, msg, line, column = *out.match(/Message:"(.+?)", Line:(\d+), Column:(\d+)/)
        line = Integer(line)
        column = Integer(column)
      else
        Result::Successful.new(JSON.parse(out))
      end
    end

    module Result
      class Successful
        attr_reader :ast

        def initialize(ast)
          @ast = ast
        end
      end

      class Failure
        attr_reader :line, :column
        attr_reader :message

        def initialize(input: , line: , column: , message: )
          @input = input
          @line = line
          @column = column
          @message = message
        end

        def error_marker
          '~' * self.column
        end

        def preview_failed_input
          start = [0, self.line - 3].max
          @input.each_line.to_a.slice(start..self.line).join("\n").strip
        end

        def formatted_message
          'Error: %s (line %d column %d)' % [self.message, self.line, self.column]
        end
      end
    end
  end
end
