class CreatePlayerCycles < ActiveRecord::Migration[8.0]
  def change
    create_table :player_cycles do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :playerCycleType
      t.string :cycleName
      t.integer :nbBadge
      t.string :minimumBadgeRarity
      t.datetime :startDate
      t.datetime :endDate
      t.integer :nbDateRepeat

      t.timestamps
    end
  end
end
