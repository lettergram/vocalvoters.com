class AddTargetLevelAndTargetStateToLetters < ActiveRecord::Migration[6.1]
  def change
    add_column :letters, :target_level, :string, default: "all"
    add_column :letters, :target_state, :string, default: "all"
  end
end
