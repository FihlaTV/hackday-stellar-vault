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
  extend Memoist

  validates :hash_hex, presence: true, uniqueness: true
  validates :tx_hex, presence: true

  # serialized array of hex-encoded signatures
  serialize :signatures, Array

  memoize def tx
    raw = Stellar::Convert.from_hex(tx_hex)
    Stellar::Transaction.from_xdr raw
  end

  def operations
    tx.operations
  end

  def source_account(op)
    account = op.source_account
    account ||= tx.source_account

    Stellar::Convert.pk_to_address(account)
  end
end
