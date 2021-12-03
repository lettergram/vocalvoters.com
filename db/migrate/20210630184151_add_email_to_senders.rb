class AddEmailToSenders < ActiveRecord::Migration[6.1]
  def change
    add_column :senders, :email, :string
  end
end
