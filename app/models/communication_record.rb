
class CommunicationRecord < ApplicationRecord
  self.abstract_class = true
  
  belongs_to :sender
  belongs_to :recipient
  belongs_to :letter

  @approval_status_options = [ 'pending', 'approved', 'declined' ]
  
  validates_inclusion_of :approval_status,
                         :in =>  @approval_status_options
  
end
