class AddPromotedLetterToLetters < ActiveRecord::Migration[7.0]
  def change
    add_column :letters, :promoted, :boolean, default: false, null: false
  end
end
