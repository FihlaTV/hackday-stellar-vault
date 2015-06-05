require 'sinatra/base'
require 'active_support/all'
require 'better_errors'

class App < Sinatra::Base
  configure :development do
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
  end

  # UI Routes
  get "/" do
    redirect "/client"
  end

  get "/client" do
    haml :index, layout: :application
  end

  get "/client/:hash" do
    params['hash']
  end


  # API Routes

  # post '/transactions'

end
