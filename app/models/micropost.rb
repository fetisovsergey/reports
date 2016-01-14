class Micropost < ActiveRecord::Base
  belongs_to :user

  has_many :comments, dependent: :destroy

  acts_as_votable
  has_many :votes, foreign_key: "votable_id", dependent: :destroy
  has_many :votables, through: :votes, source: :votable 
  default_scope -> { order('created_at DESC') }

  
  has_attached_file :photo, :styles => { :medium => "400x400>", :thumb => "100x100#", :full => "1200x1200>", :maps => "175x175#" }, :default_url => ""
  validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/


  validates :content, presence: true, length: { maximum: 400 }, if: :attach?
  validates :content, presence: false, unless: :attach?
  validates :user_id, presence: true
  # Returns microposts from the users being followed by the given user.

  ###########_Координаты_микропоста_26.02.15_#################
  validates :longtitude, presence: true, allow_blank: true
  validates :latitude, presence: true, allow_blank: true
  
  geocoded_by :address, :skip_index => true
  
  reverse_geocoded_by :latitude, :longtitude
  after_validation :reverse_geocode
  ############################################################

  ########## Проверка на вложение к посту) Дает возможность создания постов без текста ####################
  def attach?
    self.photo.url == ""
  end
  ######################################################################################

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end


  def voting?(user)
    votes.find_by(voter_id: user.id)
  end

#  def upvote!(micropost)
#    votes.create!(votable_id: micropost.id, voter_id: user.id)
#  end
  
#  def downvote!(micropost)
#    votes.destroy!(votable_id: micropost.id,voter_id: user.id)
#  end

end
