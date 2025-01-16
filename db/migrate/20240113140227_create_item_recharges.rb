class CreateItemRecharges < ActiveRecord::Migration[8.0]
  def change
    create_table :item_recharges do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :max_energy_recharge
      t.integer :time_to_charge
      t.integer :flex_charge
      t.integer :sponsor_mark_charge
      t.float :unit_charge_cost
      t.float :max_charge_cost

      t.timestamps
    end
  end
end
