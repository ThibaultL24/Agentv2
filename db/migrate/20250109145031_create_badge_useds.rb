class CreateBadgeUseds < ActiveRecord::Migration[8.0]
  def change
    create_table :badge_useds do |t|
      t.references :match, null: false, foreign_key: true
      t.integer :nftId

      t.timestamps
    end
  end
end
