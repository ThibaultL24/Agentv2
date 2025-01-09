class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :rarity
      t.string :type
      t.string :name
      t.float :efficiency
      t.integer :nfts
      t.integer :supply
      t.float :floorPrice

      t.timestamps
    end
  end
end
