

desc "Setup the dev environment"
task :install do
  exec "bundle install"
end

desc "Start the dev server"
task :dev do
  system "bundle exec rake db:migrate"
  exit 1 unless $?.success?
  exec "bundle exec rerun 'rackup'"
end

desc "Start the pry console"
task :pry do
  exec "bundle exec pry -r ./app.rb"
end

desc "loads the app's environment into memory"
task :environment do
  require './app.rb'
end

namespace :db do
  desc "Migrate the database"
  task :migrate => :environment do
    ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end

desc "Outputs the hex for a test tx"
task :tx => :environment do
  from = Stellar::KeyPair.from_seed("s3AnFq5uyGoHqTsSzV3Dpk2RM1tQmg9b9GEMgVGKzGc9Tu4Z1pT")
  to = Stellar::KeyPair.random

  tx = Stellar::Transaction.create_account({
    account:          from,
    destination:      to,
    sequence:         12884901892,
    starting_balance: 200 * Stellar::ONE,
  })

  raw = tx.to_xdr
  hex = Stellar::Convert.to_hex raw

  puts "Signer"
  puts "\tseed: #{from.seed}"
  puts "\taddy: #{from.address}"

  puts "TX Hex:"
  puts
  puts hex
end


namespace :ledger do
  desc "Runs the scc recipe to setup our test scenario, saving the generated sql to disk"
  task :sql => :environment do
    exec "bundle exec scc -r ./setup/recipe.rb --wait"
  end

  desc "load the ledger sql"
  task :load => :environment do
    exec "psql #{ENV["STELLAR_CORE_DATABASE_URL"]} < ./setup/core.sql"
  end
end
