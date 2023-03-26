class AddGenerationOptionToOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :organizations, :generation_option, :boolean, default: true
  end
end
