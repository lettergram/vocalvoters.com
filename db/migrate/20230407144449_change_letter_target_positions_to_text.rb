class ChangeLetterTargetPositionsToText < ActiveRecord::Migration[7.0]
  def change
    change_table :letters do |t|
      t.change :target_positions, :text
    end
  end
end

class Feature < ActiveRecord::Base
  serialize :dependent, Array 
end
