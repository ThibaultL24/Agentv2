class CreateItemTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :item_crafting do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :unitToCraft
      t.integer :flexCraft
      t.integer :sponsorMarkCraft
      t.integer :nbLowerBadgeToCraft

      t.timestamps
    end

    create_table :item_recharge do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :maxEnergyRecharge
      t.integer :timeToCHarge
      t.integer :flexCharge
      t.integer :sponsorMarkCharge
      t.float :unitChargeCost
      t.float :maxChargeCost

      t.timestamps
    end

    create_table :item_farming do |t|
      t.references :item, null: false, foreign_key: true
      t.float :efficiency
      t.float :ratio
      t.integer :inGameTime

      t.timestamps
    end
  end
end
