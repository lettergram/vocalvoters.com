class Email < ApplicationRecord
  belongs_to :sender
  belongs_to :recipient
  belongs_to :letter
  belongs_to :payment
end
