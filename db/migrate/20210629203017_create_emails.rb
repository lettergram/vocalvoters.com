class CreateEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :emails do |t|
      t.string :email_address
      t.boolean :success, default: true
      t.references :sender, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.references :letter, null: false, foreign_key: true
      t.string :payment, null: false

      t.timestamps
    end
  end
end
