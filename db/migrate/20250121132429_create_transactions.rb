class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :payment_method, null: false, foreign_key: true
      t.decimal :amount, precision: 18, scale: 8 # Pour supporter les cryptos
      t.string :currency
      t.string :status # pending, completed, failed, refunded
      t.string :external_id # ID de la transaction chez le provider
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :transactions, :external_id
    add_index :transactions, :status
  end
end
