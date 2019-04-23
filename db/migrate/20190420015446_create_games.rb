class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
        t.belongs_to :room, index: true
        t.string :game_phase
        t.integer :current_game_board 
        
        t.timestamps
    end
    
    create_table :game_boards do |t|
        t.belongs_to :game, index: true
        t.string :game_type
        t.integer :multiplier
        t.integer :cleared_clues_ids
        
        t.timestamps
    end
      
    create_table :categories do |t|
        t.text :name
        t.text :type
        t.integer :api_category_id
        
        t.timestamps
    end
      
    create_table :categories_game_boards do |t|
        t.belongs_to :game_board, index: true
        t.belongs_to :category, index: true
        
        t.timestamps
    end
      
    create_table :clues do |t|
      t.belongs_to :category, index: true
      t.integer :value
      t.integer :position
      t.text :question
      t.text :answer
      t.integer :api_clue_id
      t.integer :api_category_id

      t.timestamps
    end
  end
end
