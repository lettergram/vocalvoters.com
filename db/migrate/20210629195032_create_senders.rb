class CreateSenders < ActiveRecord::Migration[6.1]
  def change
    create_table :senders do |t|
      t.string :name
      t.integer :zipcode
      t.string :county
      t.string :district
      t.string :state
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
