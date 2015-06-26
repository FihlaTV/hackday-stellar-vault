require 'dotenv'
Dotenv.load

# TODO: remove this when we are encyrpting keys before saving them to the DB
if ENV["ALLOW_INSECURE_KEYS"] != "true"
  puts "ALLOW_INSECURE_KEYS environment variable must be set to 'true'"
  puts "This server does not yet have the ability to encrypt stored keys, and " +
       "you are acknowledging that breakage by setting ALLOW_INSECURE_KEYS"

  exit 1
end

require 'sinatra/base'
require 'active_support/all'
require 'better_errors'
require 'stellar-base'
require 'memoist'
require 'awesome_print'
require 'rack-flash'

AwesomePrint.defaults = {plain: true}

require_relative "./db"
require_relative "./core"

class App < Sinatra::Base
  configure do
    set :method_override, true
    enable :sessions
    use Rack::Flash
  end

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

  get "/client/keys/new" do
    haml :new_key, layout: :application
  end

  get "/client/transactions/new" do
    haml :new, layout: :application
  end

  get "/client/transactions/:hash" do
    tx = Transaction.where(hash_hex:params[:hash]).first
    raise "couldn't find tx" if tx.blank?

    submit_result =
      if params[:result].present?
        rhex = Stellar::Convert.from_hex(params[:result])
        Stellar::TransactionResult.from_xdr rhex
      end

    haml :show, layout: :application, locals:{
      tx: tx,
      submit_result: submit_result,
    }

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

    redirect "/client/transactions/#{txm.hash_hex}"
  end

  patch '/transactions/:hash' do
    txm = Transaction.where(hash_hex:params[:hash]).first
    raise "couldn't find tx" if txm.blank?

    if params[:seed].present?
      txm.add_signature!(params[:seed])
    end

    # TODO: add any provided verifications

    if txm.done?
      result = txm.submit!

      if result.present?
        # we errored
        redirect "/client/transactions/#{txm.hash_hex}?result=#{result}"
      end

      txm.wait_for_consensus
    end

    redirect "/client/transactions/#{txm.hash_hex}"
  end

  post '/transactions/:hash/submit' do
    txm = Transaction.where(hash_hex:params[:hash]).first
    raise "couldn't find tx" if txm.blank?

    result = txm.submit!

    if result.present?
      # we errored
      redirect "/client/transactions/#{txm.hash_hex}?result=#{result}"
    end

    txm.wait_for_consensus

    redirect "/client/transactions/#{txm.hash_hex}"
  end

  post '/keys' do
    @key = Key.new(seed: params[:seed])
    # @key.validator = TODO

    if @key.save
      flash[:success] = "Key added!"
      redirect "/client"
    else
      flash.now[:danger] = @key.errors.full_messages.join("<br>\n")
      haml :new_key, layout: :application
    end
  end


  # helpers
  helpers do
    def truncate(input, max=30)
      return input if input.length <= max

      input[0...max] + "..."
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
end
