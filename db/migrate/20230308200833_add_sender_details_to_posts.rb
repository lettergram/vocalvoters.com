class AddSenderDetailsToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :sender_name, :string
    add_column :posts, :sender_line_1, :string
    add_column :posts, :sender_line_2, :string
    add_column :posts, :sender_city, :string
    add_column :posts, :sender_state, :string
    add_column :posts, :sender_zipcode, :string
  end
end
