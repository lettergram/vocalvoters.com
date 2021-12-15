class AddSignatureToSenders < ActiveRecord::Migration[6.1]
  def change
    add_column :senders, :signature, :text
  end
end
