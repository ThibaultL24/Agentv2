class CreateNfts < ActiveRecord::Migration[8.0]
  def change
    create_table :nfts do |t|
      t.integer :issueId
      t.integer :itemId, index: true
      t.string :owner
      t.float :purchasePrice

      t.timestamps
    end

    add_foreign_key :nfts, :items, column: :itemId
  end
end
