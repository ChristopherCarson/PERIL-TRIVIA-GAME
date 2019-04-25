class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.belongs_to :game, index: true
      t.belongs_to :user, index: true
      t.integer :score
      
      t.timestamps
    end
  end
end
