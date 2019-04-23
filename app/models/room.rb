class Room < ApplicationRecord
  has_one :game
  has_many :room_messages, dependent: :destroy,
                           inverse_of: :room
end
