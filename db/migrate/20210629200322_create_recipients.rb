class CreateRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :recipients do |t|
      t.string :name
      t.string :position
      t.string :level
      t.string :district
      t.string :state
      t.integer :number_fax
      t.integer :number_phone
      t.string :email_address
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_city
      t.string :address_state
      t.string :address_zipcode

      t.timestamps
    end
  end
end
