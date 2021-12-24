class CreateOrganizations < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.text :description
      t.boolean :approvals_required, default: true

      t.timestamps
    end
  end
end
