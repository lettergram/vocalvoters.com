class Post < ApplicationRecord
  belongs_to :sender
  belongs_to :recipient
  belongs_to :letter
end
