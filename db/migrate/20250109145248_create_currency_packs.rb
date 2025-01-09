class CreateCurrencyPacks < ActiveRecord::Migration[8.0]
  def change
    create_table :currency_packs do |t|
      t.references :currency, null: false, foreign_key: true
      t.integer :currencyNumber
      t.float :price
      t.float :unitPrice

      t.timestamps
    end
  end
end
