class AddOrganizationAdminAndOrganizationReferenceToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :org_admin, :boolean
    add_reference :users, :organization, foreign_key: true # allowing null, will default
  end
end
