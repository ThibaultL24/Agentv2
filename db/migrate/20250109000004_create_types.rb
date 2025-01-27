class CreateTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :types do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :types, :name, unique: true
  end
end
