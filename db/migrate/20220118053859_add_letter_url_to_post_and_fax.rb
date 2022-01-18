class AddLetterUrlToPostAndFax < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :letter_url, :text, default: nil
    add_column :faxes, :letter_url, :text, default: nil
    add_column :emails, :letter_url, :text, default: nil
  end
end
