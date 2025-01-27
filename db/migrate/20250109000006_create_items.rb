class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.references :type, null: false, foreign_key: true
      t.references :rarity, null: false, foreign_key: true
      t.string :name, null: false
      t.float :efficiency
      t.integer :nfts
      t.integer :supply
      t.float :floor_price

      t.timestamps
    end

    add_index :items, :name
  end
end
