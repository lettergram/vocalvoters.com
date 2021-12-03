class AddContactFormToRecipients < ActiveRecord::Migration[6.1]
  def change
    add_column :recipients, :contact_form, :string
  end
end
