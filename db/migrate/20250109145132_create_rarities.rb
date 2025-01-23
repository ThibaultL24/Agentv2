class CreateRarities < ActiveRecord::Migration[8.0]
  def change
    create_table :rarities do |t|
      t.string :name
      t.string :color

      t.timestamps
    end
  end
end
