require 'sinatra/base'
require 'active_support/all'
require 'better_errors'
require 'stellar-base'

require_relative "./db"

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

  post '/transactions' do
    hex = params['hex']
    raw = Stellar::Convert.from_hex(hex)
    tx = Stellar::Transaction.from_xdr raw

    txm = Transaction.create!({
      hash_hex: Stellar::Convert.to_hex(tx.hash),
      tx_hex: hex,
    })

    redirect "/client/#{txm.hash_hex}"
  end

end
