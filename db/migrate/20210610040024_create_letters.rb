class CreateLetters < ActiveRecord::Migration[6.1]
  def change
    create_table :letters do |t|
      t.string :category
      t.string :policy_or_law
      t.string :tags
      t.float :sentiment
      t.text :body
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
