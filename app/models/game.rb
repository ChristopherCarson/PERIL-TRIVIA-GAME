class Game < ApplicationRecord
    has_many :game_boards
    has_many :players
    belongs_to :room

    @@num_random_question_choices = 7

    #StartGame
    def startGame(num_players)
        self.game_phase = "Start"
        num_players.times {self.game.players << Player.new(score: 0)}
        self.moveGameToNextPhase()
        self.save()
    end
    
    #CheckGameState
    def checkGameState()
        current_board = self.game_boards.find(self.current_game_board)
        if current_board.getRemainingCluesCount == 0
            self.moveGameToNextPhase()
        end
    end
    
    #Controls which phase the game is in. 
    def moveGameToNextPhase()
        case self.game_phase.downcase
        when "start"
            self.game_phase = "Single"
            self.current_game_board = self.createGameBoard("single")
        when "single"
            self.game_phase = "Double"
            self.current_game_board = self.createGameBoard("double")
        when "double"
            self.game_phase = "Final"
            #TODO: Final
        when "final"
            self.game_phase = "End"
            #TODO: End
        end
        self.save()
    end
    
    #Selects a clue from the current board from the clue_id
    def selectClueFromBoard(clue_id)
        current_board = self.game_boards.find(self.current_game_board)
        clue = current_board.clues.find(clue_id)
        removeClueFromCurrentBoard(clue_id)
        return clue
    end
    
    #Generates a number of possible answers
    def createMultipleChoiceFromClue(clue_id)
        current_board = self.game_boards.find(self.current_game_board)
        clue = current_board.clues.find(clue_id)
        
        answers = []
        Clue.find_by_sql("SELECT answer FROM clues ORDER BY Random() + " + @@num_random_question_choices).each do |clues|
            answers << clues.answer
        end
        answers << clue.answer
        return answers.shuffle
    end
    
    #Submits an answer. 
    def submitAnswer(answer, player_id, clue_id)
        current_board = self.game_boards.find(self.current_game_board)
        clue = current_board.clues.find(clue_id)
        
        if answer.downcase == clue.answer.downcase
            addScoreToPlayer(player_id, clue.value)
        else
            addScoreToPlayer(player_id, -clue.value)
        end
    end
    
    def getCurrentBoardState()
        current_board = self.game_boards.find(self.current_game_board)
        return {"categories" => current_board.categories, "clues" => current_board.getRemainingClues}
    end
    
    def addScoreToPlayer(player_id, score)
        player = self.players.find(player_id)
        player.score += score
    end
    
    #Removes a clue from the current board.
    def removeClueFromCurrentBoard(clue_id)
        current_board = self.game_boards[0]
        current_board.removeClue(current_board.clues.find(clue_id))
    end
    
    #Creates a game board.
    def createGameBoard(boardtype)
        _gameboard = GameBoard.new(game_type: boardtype)
        self.game_boards << _gameboard
        
        _gameboard.getCategories()
        self.save()
<<<<<<< HEAD
=======

>>>>>>> refs/remotes/origin/master
        return _gameboard.id
    end
    
    #########TO DO: OFFLOAD THIS CODE TO SOMEWHERE ELSE######
    @@API_URL = "http://jservice.io/api/"
    @@clue_sets = 100 
    
    def populateGameDBwithTestQuestions
        #Single
        for i in 1..20
            test_cat = Category.new(name: "TEST " + i.to_s, api_category_id: rand(100000000))
            test_cat.save()
            for j in 1..5
                test_clue = Clue.new(category_id: test_cat.id, api_clue_id: rand(100000000), position: j, value: j * 100, question: "TEST " + j.to_s, answer: "TEST " + j.to_s)
                test_clue.save()
            end
        end
        
        #Double
        for i in 1..20
            test_cat = Category.new(name: "TEST " + i.to_s, api_category_id: rand(100000000))
            test_cat.save()
            for j in 1..5
                test_clue =  Clue.new(category_id: test_cat.id, api_clue_id: rand(100000000), position: j, value: j * 200, question: "TEST " + j.to_s, answer: "TEST " + j.to_s)
                test_clue.save()
            end
        end
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
    def addCategoriesToDB(cat)
        for i in 0..cat.count - 1
            Category.new(
                name: cat[i]["title"],
                api_category_id: cat[i]["id"]
            ).save()
        end
    end
    
    #Adds Clues to the database from objects retrieved from API
    def addCluesToDB(clues)
        for i in 0..clues.count - 1
            if(clues[i]["value"] > 500)
                clue_pos = ((clues[i]["value"] / 2) / 100) % 6 - 1
            elseif(clues[i]["value"] <= 500)
                clue_pos = (clues[i]["value"] / 100) %6 - 1
            end
            
            Clue.new(
                category_id: Category.find_by_sql("Select * From Categories WHERE api_category_id = " + clues[i]["category"]["id"].to_s)[0].id,
                api_category_id: Category.find_by_sql("Select * From Categories WHERE api_category_id = " + clues[i]["category"]["id"].to_s)[0].api_category_id,
                position: clue_pos,
                value: clues[i]["value"],
                question: clues[i]["question"],
                answer: clues[i]["answer"],
                api_clue_id: clues[i]["id"]
            ).save()
        end
    end
    
    #Retrieves categories from API
    def retrieveCategories
        _responses = []
        for i in 0..@@clue_sets - 1 do
            puts "Num calls remaining: " + (@@clue_sets - i).to_s 
            puts "REST CALL TO " + @@API_URL + "categories?count=100&offset=" + (i * 100).to_s
            _URL = @@API_URL + "categories?count=100&offset=" + (i * 100).to_s
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
            puts "Num calls remaining: " + (categories.count - i).to_s  
            puts "REST CALL TO " + @@API_URL + "clues?category=" + categories[i]["id"].to_s
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
