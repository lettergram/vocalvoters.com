class AddReturnAddressIdtoPost < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :return_address_id, :int
  end
end
