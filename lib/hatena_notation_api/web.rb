require 'sinatra/base'
require 'sinatra/respond_with'
require 'json'

require_relative './formatter/html'
require_relative './parser'

module HatenaNotationApi
  class Web < ::Sinatra::Base
    enable :logging
    set :views, './views'

    register Sinatra::RespondWith

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    get '/' do
      erb :index
    end

    post '/render', provides: ['json', 'html'] do
      request.body.rewind
      input = request.body.read + "\n"

      parser = HatenaNotationApi::Parser.new(
        command_path: File.expand_path(ENV['TEXT_HATENA_COMMAND']),
      )
      result = parser.parse(input)

      respond_to do |format|
        format.on('application/json') do
          case result
          when HatenaNotationApi::Parser::Result::Successful
            JSON.generate(result.ast)
          when HatenaNotationApi::Parser::Result::Failure
            status 400
            '{}'
          end
        end
        format.on('text/html') do
          case result
          when HatenaNotationApi::Parser::Result::Successful
            formatter = HatenaNotationApi::Formatter::Html.new
            formatter.format(result.ast)
          when HatenaNotationApi::Parser::Result::Failure
            status 400
            erb :error, locals: { result: result }
          end
        end
      end
    end
  end
end
