class CreateNfts < ActiveRecord::Migration[8.0]
  def change
    create_table :nfts do |t|
      t.integer :issueId
      t.integer :itemId
      t.string :owner
      t.float :purchasePrice

      t.timestamps
    end
  end
end
