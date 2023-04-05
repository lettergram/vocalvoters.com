class AddTargetPositionsToLetters < ActiveRecord::Migration[7.0]
  def change
    add_column :letters, :target_positions, :string, array: true, default: [], null: false
  end
end
