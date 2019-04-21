class Game < ApplicationRecord
    has_many :game_boards
    
    @@API_URL = "http://jservice.io/api/"
    @@clue_sets = 50 
    
    #Creates a game board.
    def createGameBoard(boardtype)
        _gameboard = GameBoard.new(game_type: boardtype)
        self.game_boards << _gameboard
        
        _gameboard.getCategories()
        self.save()
        return _gameboard
    end
    
    #Performs initial population of game database from API.
    #Only run on initial setup.
    #May need to run multiple times to get diverse set.
    def populateGameDB
        _categories = retrieveCategories()
        addCategoriesToDB(_categories)
        
        _clues = retrieveClues(_categories)
        addCluesToDB(_clues)
    end
    
    #Adds categories to the database from objects retrieved from API
    def addCategoriesToDB(categories)
        for i in 0..categories.count - 1
            Category.new(
                name: categories[i]["title"],
                api_category_id: categories[i]["id"]
            ).save()
        end
    end
    
    #Adds Clues to the database from objects retrieved from API
    def addCluesToDB(clues)
        for i in 0..clues.count - 1
            Clue.new(
                category_id: Category.find_by_sql("Select * From Categories WHERE api_category_id = " + clues[i]["category"]["id"].to_s)[0].id,
                api_category_id: Category.find_by_sql("Select * From Categories WHERE api_category_id = " + clues[i]["category"]["id"].to_s)[0].api_category_id,
                value: clues[i]["value"],
                question: clues[i]["question"],
                answer: clues[i]["answer"],
                api_clue_id: clues[i]["id"]
            ).save()
        end
    end
    
    #Retrieves categories from API
    def retrieveCategories
        #10000 to pull from a wide range of the API's category list.
        
        _responses = []
        for i in 0..@@clue_sets - 1 do
            _Offset = rand(15000)
            _URL = @@API_URL + "categories?count=100&offset=" + (_Offset + (i * 100)).to_s
            _responses << JSON.parse(RestClient.get(_URL)).select do |hash|
                hash["clues_count"] == 5
            end
        end
        return _responses.reduce(:+)
    end

    #Retrieves clues from API using category ids.
    def retrieveClues(categories)
        _responses = []
        for i in 0..categories.count - 1
            _URL = @@API_URL + "clues?category=" + categories[i]["id"].to_s
            _responses << JSON.parse(RestClient.get(_URL))
        end
        return _responses.reduce(:+)
    end
    
    #Pulls a random clue from API.
    def getRandomClue
        _URL = @@API_URL + "random?count=1"
        _response = RestClient.get(_URL)
        return JSON.parse(_response)
    end
end
