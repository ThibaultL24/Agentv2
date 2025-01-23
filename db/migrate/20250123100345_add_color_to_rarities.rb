class AddColorToRarities < ActiveRecord::Migration[8.0]
  def change
    add_column :rarities, :color, :string
  end
end
