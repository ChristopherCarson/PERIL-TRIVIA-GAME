class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, uniqueness: true, presence: true

  has_many :players
  has_many :room_messages,
           dependent: :destroy

  def avatar_url
    avatar_id = Digest::MD5::hexdigest(email).downcase
    "https://api.adorable.io/avatars/40/#{avatar_id}.png"
  end
end
