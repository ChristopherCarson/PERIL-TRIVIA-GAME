class FinishedClue < ApplicationRecord
    belongs_to :clue
    belongs_to :game_board
end
