class CreateRarities < ActiveRecord::Migration[8.0]
  def change
    create_table :rarities do |t|
      t.string :name, null: false
      t.string :color, null: false  # Hex color code for UI display (e.g. #FFD700 for gold)

      t.timestamps
    end

    add_index :rarities, :name, unique: true
  end
end
