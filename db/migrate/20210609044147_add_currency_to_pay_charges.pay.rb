# This migration comes from pay (originally 20210406215234)
class AddCurrencyToPayCharges < ActiveRecord::Migration[4.2]
  def change
    add_column :pay_charges, :currency, :string
  end
end
