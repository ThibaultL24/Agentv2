class CreateItemFarmings < ActiveRecord::Migration[8.0]
  def change
    create_table :item_farmings do |t|
      t.references :item, null: false, foreign_key: true
      t.float :efficiency
      t.float :ratio
      t.integer :in_game_time

      t.timestamps
    end
  end
end
