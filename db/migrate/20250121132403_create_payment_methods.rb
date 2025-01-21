class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.string :name
      t.string :provider # 'stripe', 'metamask', 'coinbase', 'binance'
      t.boolean :is_active, default: true
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :payment_methods, :provider, unique: true
  end
end
