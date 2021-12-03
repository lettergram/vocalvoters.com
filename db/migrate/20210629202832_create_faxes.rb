class CreateFaxes < ActiveRecord::Migration[6.1]
  def change
    create_table :faxes do |t|
      t.integer :number_fax
      t.string :payment, null: false
      t.boolean :success, default: true
      t.references :sender, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.references :letter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
