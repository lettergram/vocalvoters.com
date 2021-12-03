class ChangeNumberToBigintOnRecipients < ActiveRecord::Migration[6.1]
  def change
    change_column :recipients, :number_fax, :bigint
    change_column :recipients, :number_phone, :bigint
  end
end
