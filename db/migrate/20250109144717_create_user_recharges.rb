class CreateUserRecharges < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recharges do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :discountTime
      t.integer :discountNumber

      t.timestamps
    end
  end
end
