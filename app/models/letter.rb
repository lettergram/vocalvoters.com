class Letter < ApplicationRecord

  belongs_to :user
  belongs_to :organization
  has_many :post
  has_many :fax
  has_many :email
  before_save :downcase_fields

  def sentiment_in_text
    
    if self.sentiment > 0.5
      return 'strongly support'
    elsif self.sentiment > 0
      return 'support'
    elsif self.sentiment == 0
      return 'am indifferent to'
    elsif self.sentiment < -0.5
      return 'strongly oppose'
    elsif self.sentiment < 0
      return 'oppose'
    end

  end
  
  private

    def downcase_fields
      self.category = category.downcase
      self.tags = tags.downcase 
    end
end
