class CreateSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :slots do |t|
      t.references :currency, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.integer :unlockCurrencyNumber
      t.float :unlockPrice
      t.boolean :unlocked
      t.float :totalCost

      t.timestamps
    end
  end
end
