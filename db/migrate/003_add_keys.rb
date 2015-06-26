class AddKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string :address, null: false
      t.string :seed, null: false
      t.text   :validator

      t.index  :address
    end
  end
end
