class GameBoard < ActiveRecord::Base
    has_and_belongs_to_many :categories
    belongs_to :game
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
             WHERE api_category_id IN
                (SELECT api_category_id FROM clues
                WHERE value = " + value_filter.to_s + ")
             ORDER BY Random()
             LIMIT " + @@num_categories.to_s)
        self.save()
    end
end
