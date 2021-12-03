class AddRetirementToRecipients < ActiveRecord::Migration[6.1]
  def change
    add_column :recipients, :retired, :boolean, :default => false
  end
end
