require 'sinatra/base'

class App < Sinatra::Base
  configure { set :server, :puma }

  get "/" do
    "hello world"
  end
end
