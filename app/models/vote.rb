class Vote < ActiveRecord::Base
  belongs_to :voter, class_name: "User"
  belongs_to :votable, class_name: "Micropost"
  validates :votable_id, presence: true
  validates :voter_id, presence: true
end
