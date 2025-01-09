class CreateCurrencies < ActiveRecord::Migration[8.0]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :gameName
      t.boolean :onChain
      t.float :price
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
