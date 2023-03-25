class AddLogoLinkToOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :logo_link, :string
  end
end
