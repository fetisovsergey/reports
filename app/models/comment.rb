class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :micropost
  
  default_scope -> { order('created_at ASC') }

  validates :content, presence: true, length: { in: 1..400 }
  validates :user_id, presence: true
  validates :micropost_id, presence: true 
end
