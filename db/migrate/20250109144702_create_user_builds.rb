class CreateUserBuilds < ActiveRecord::Migration[8.0]
  def change
    create_table :user_builds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :buildName
      t.float :bonusMultiplier
      t.float :perksMultiplier

      t.timestamps
    end
  end
end
