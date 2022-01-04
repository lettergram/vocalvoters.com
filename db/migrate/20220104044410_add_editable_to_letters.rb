class AddEditableToLetters < ActiveRecord::Migration[6.1]
  def change
    add_column :letters, :editable, :boolean, default: true
  end
end
