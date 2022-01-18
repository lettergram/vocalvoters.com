class AddApprovalStatusToPostsFaxesAndEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :approval_status, :string, default: "pending"
    add_column :faxes, :approval_status, :string, default: "pending"
    add_column :emails, :approval_status, :string, default: "pending"    
  end
end
