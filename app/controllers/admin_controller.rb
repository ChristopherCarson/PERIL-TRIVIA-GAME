class AdminController < ActionController::Base
  
  def index
      render params[:page]
  end
  
  def populate
    game = Game.new()
    game.populateGameDB()
    flash[:popnotice] = "Populating Game Database now..."
    redirect_to admin_index_path
  end
end