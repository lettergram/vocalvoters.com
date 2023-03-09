class AddSenderEmailToLetters < ActiveRecord::Migration[7.0]
  def change
    add_column :letters, :email, :string
  end
end
