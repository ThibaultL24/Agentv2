class CreateItemCraftings < ActiveRecord::Migration[8.0]
  def change
    create_table :item_craftings do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :unit_to_craft
      t.integer :flex_craft
      t.integer :sponsor_mark_craft
      t.integer :nb_lower_badge_to_craft

      t.timestamps
    end
  end
end
