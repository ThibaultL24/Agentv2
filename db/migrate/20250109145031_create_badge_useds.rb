class CreateBadgeUseds < ActiveRecord::Migration[8.0]
  def change
    create_table :badge_useds do |t|
      t.references :match, null: false, foreign_key: true
      t.integer :nftId, index: true

      t.timestamps
    end

    # Ajout de la clé étrangère avec nfts
    add_foreign_key :badge_useds, :nfts, column: :nftId
  end
end
