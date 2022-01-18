class AddDerivedFromToLetters < ActiveRecord::Migration[6.1]
  def change
    add_column :letters, :derived_from, :integer, default: nil
  end
end
