class GameBoard < ActiveRecord::Base
    has_and_belongs_to_many :categories
    belongs_to :game
    has_many :finished_clues
    has_many :clues, :through => :categories
    
    
    @@num_categories = 6
    
    #Loads categories into gameboard
    def getCategories
        if self.game_type == "double"
            value_filter = 1000
        else
            value_filter = 100
        end
        
        self.categories << Category.find_by_sql(
            "SELECT * FROM categories
             WHERE id IN
                (SELECT category_id FROM clues
                WHERE value = " + value_filter.to_s + ")
             AND id IN 
                (SELECT category_id FROM clues
                 GROUP BY category_id
                 HAVING COUNT(category_id) = 5)
             ORDER BY Random()
             LIMIT " + @@num_categories.to_s)
        self.save()
    end

    def getRemainingClues
        self.clues.find_by_sql(
            "SELECT  clues.* FROM clues
             INNER JOIN categories ON clues.category_id = categories.id
             INNER JOIN categories_game_boards ON categories.id = categories_game_boards.category_id
             WHERE categories_game_boards.game_board_id = " + self.id.to_s + "
             AND clues.id NOT IN 
                (SELECT clue_id FROM finished_clues
                WHERE game_board_id = " + self.id.to_s + ")")
    end
    
    def getRemainingCluesByCategory(category_id)
        self.clues.find_by_sql(
            "SELECT  clues.* FROM clues
             INNER JOIN categories ON clues.category_id = categories.id
             INNER JOIN categories_game_boards ON categories.id = categories_game_boards.category_id
             WHERE categories_game_boards.game_board_id = " + self.id.to_s + "
             AND categories.id = " + category_id.to_s + "
             AND clues.id NOT IN 
                (SELECT clue_id FROM finished_clues
                WHERE game_board_id = " + self.id.to_s + ")")
    end
    
    def addFinishedClue(clue)
        self.finished_clues << FinishedClue.new(game_board_id: self.id, clue_id: clue.id)
    end
end
