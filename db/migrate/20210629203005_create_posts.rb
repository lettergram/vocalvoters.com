class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_city
      t.string :address_state
      t.string :address_zipcode
      t.string :payment, null: false
      t.boolean :priority, default: false
      t.boolean :success, default: true
      t.references :sender, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.references :letter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
