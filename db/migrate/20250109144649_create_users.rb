class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.boolean :isPremium
      t.integer :level
      t.float :experience
      t.string :assetType
      t.string :asset
      t.integer :slotUnlockedId
      t.string :maxRarity
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :email, unique: true # Ajout de l'index unique sur email
    add_index :users, :reset_password_token, unique: true
  end
end
