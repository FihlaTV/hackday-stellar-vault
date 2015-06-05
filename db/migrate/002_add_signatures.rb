class AddSignatures < ActiveRecord::Migration
  def change
    change_table :transactions do |t|
      t.text :signatures
    end
  end
end
