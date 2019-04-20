class Category < ApplicationRecord
    has_and_belongs_to_many :game_boards
    has_many :clues
    
    validates :name, :presence => true
    validates :api_category_id, :presence => true
end
