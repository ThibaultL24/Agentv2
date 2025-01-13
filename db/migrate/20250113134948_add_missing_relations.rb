class AddMissingRelations < ActiveRecord::Migration[8.0]
  def change
    # Ajout des relations pour items
    unless column_exists?(:items, :type_id)
      add_reference :items, :type, foreign_key: true, null: true
    end

    unless column_exists?(:items, :rarity_id)
      add_reference :items, :rarity, foreign_key: true, null: true
    end

    # Ajout des relations pour nfts
    unless foreign_key_exists?(:nfts, :items)
      add_foreign_key :nfts, :items, column: :itemId
    end

    unless index_exists?(:nfts, :itemId)
      add_index :nfts, :itemId
    end

    # Ajout des relations pour badge_useds
    unless foreign_key_exists?(:badge_useds, :nfts)
      add_foreign_key :badge_useds, :nfts, column: :nftId
    end

    unless index_exists?(:badge_useds, :nftId)
      add_index :badge_useds, :nftId
    end
  end
end
