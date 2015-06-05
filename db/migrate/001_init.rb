class Init < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :hash_hex
      t.text :tx_hex
    end
  end
end
