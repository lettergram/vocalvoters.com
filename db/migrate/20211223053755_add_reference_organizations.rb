class AddReferenceOrganizations < ActiveRecord::Migration[6.1]
  def change
    add_reference :letters, :organization, foreign_key: true
  end
end
