class Clue < ApplicationRecord
    belongs_to :category
    validates_presence_of :category
    
    validates :position, :presence => true
    validates :question, :presence => true
    validates :answer, :presence => true
    validates :value, :presence => true
    validates :api_clue_id, :presence => true, :uniqueness => true
end
