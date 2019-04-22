class CreateFinishedClues < ActiveRecord::Migration[5.2]
  def change
    create_table :finished_clues do |t|
      t.belongs_to :game_board, index: true
      t.belongs_to :clue, index: true
      t.timestamps
    end
  end
end
