require 'active_record'

raise "No DATABASE_URL" if ENV["DATABASE_URL"].blank?
raise "No STELLAR_CORE_DATABASE_URL" if ENV["STELLAR_CORE_DATABASE_URL"].blank?


module Vault
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(ENV["DATABASE_URL"])
  end
end

module Core
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection(ENV["STELLAR_CORE_DATABASE_URL"])
  end
end



class Transaction < Vault::Base
  validates :hash_hex, presence: true
  validates :tx_hex, presence: true
end
