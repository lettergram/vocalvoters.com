class Letter < ApplicationRecord

  belongs_to :user
  belongs_to :organization
  before_save :downcase_fields

  private

    def downcase_fields
      self.category = category.downcase
      self.tags = tags.downcase 
    end
end
