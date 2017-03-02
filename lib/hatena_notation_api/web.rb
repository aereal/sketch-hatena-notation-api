require 'sinatra/base'
require 'sinatra/respond_with'
require 'json'

require_relative './formatter/html'

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
      hatena_notation = request.body.read.gsub(/\r\n/, "\n") + "\n"

      go_text_hatena = File.expand_path('./go-text-hatena')
      ast = JSON.parse(
        IO.popen([go_text_hatena], 'r+') {|io|
          io.write(hatena_notation)
          io.close_write
          io.read
        }
      )

      respond_to do |format|
        format.on('application/json') do
          JSON.generate(ast)
        end
        format.on('text/html') do
          formatter = HatenaNotationApi::Formatter::Html.new
          formatter.format(ast)
        end
      end
    end
  end
end
