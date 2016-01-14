class User < ActiveRecord::Base

  before_create :confirmation_token
  acts_as_voter  
  acts_as_messageable


  has_attached_file :avatar, :default_url => "default_avatar_:style.png",
  :styles => { :medium => "170x170#", :thumb => "50x50#", :message_avatar => "100x100#", :list_avatar => "63x63#" }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  has_many :microposts, dependent: :destroy
  ######## 7.04.2015 #############
  has_many :comments, dependent: :destroy
  ###### 4.03.2015 ##########
  has_many :locations, dependent: :destroy
  ###########################
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
   
  has_many :votes, foreign_key: "voter_id",
                                   class_name:  "Vote",
                                   dependent:   :destroy
  has_many :voters, through: :votes, source: :voter




  before_save { self.email = email.downcase }
  before_save { self.name = name.downcase }
  before_create :create_remember_token
  VALID_NAME_REGEX = /\A([\w]+\_?[\w]+)*\z/i
  validates :name,  presence: true, format: { with: VALID_NAME_REGEX }, uniqueness: { case_sensitive: false }, length: { in: 3..18 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }  
  has_secure_password
  validates :password, presence: true, :on => :create, length: { minimum: 6 }
  validates :about, length: { maximum: 600 }
  VALID_REALNAME_REGEX = /\A(([A-Z\d]?[a-z\d]+\-?[A-Z\d]?[a-z\d]+)*|([А-Я\d]?[а-я\d]+\-?[А-Я\d]?[а-я\d]+)*)\z/
  VALID_CITY_REGEX = /\A(([A-Z\d]?[a-z\d]+\-?[A-Z\d]?[a-z\d]+)*|([А-Я\d]?[а-я\d]+\-?[А-Я\d]?[а-я\d]+)*)\z/
  VALID_LINK_REGEX = /\A(([a-z\d]+\-?[a-z\d]+\.)*[a-z]+|([а-я\d]+\-?[а-я\d]+\.)*[а-я]+)\z/i
  validates :realname, allow_blank: true, format: { with: VALID_REALNAME_REGEX }, length: { maximum: 20 }
  validates :surname, allow_blank: true, format: { with: VALID_REALNAME_REGEX }, length: { maximum: 20 }
  validates :weblink, allow_blank: true, format: { with: VALID_LINK_REGEX }, length: { maximum: 50 }
  validates :city, allow_blank: true, format: { with: VALID_CITY_REGEX }, length: { maximum: 30 } 

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.search(query)
    where("name like ? or realname like ? or surname like ?", "#{query}%","#{query}%","#{query}%") 
  end

  def feed
    Micropost.from_users_followed_by(self)
  end
  
  
  def mailboxer_email(object)
    #name
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end    
  
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy!
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
    def confirmation_token
      if self.confirm_token.blank?
      	self.confirm_token = SecureRandom.urlsafe_base64.to_s
      end
    end
end
