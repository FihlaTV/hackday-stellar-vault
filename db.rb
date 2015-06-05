require 'active_record'

db_url = ENV["DB"]
db_url = "sqlite3:vault.db" if db_url.blank?

ActiveRecord::Base.establish_connection(db_url)


class Transaction < ActiveRecord::Base
  validates :hash_hex, presence: true
  validates :tx_hex, presence: true
end
