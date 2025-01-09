class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :openLootID
      t.boolean :isPremium
      t.integer :level
      t.float :experience
      t.string :assetType
      t.string :asset
      t.integer :slotUnlockedId
      t.string :maxRarity

      t.timestamps
    end
  end
end
