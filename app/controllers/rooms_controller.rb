class RoomsController < ApplicationController
  require 'levenshtein'
  # Loads:
  # @rooms = all rooms
  # @room = current room when applicable
  before_action :load_entities
  $usersReady = []
  $games = []
  $gameStarted = []
  $answer = ''
  $winnings = 0
  $playerForMoney = 0
  $answering = false
                   

  def index
    @rooms = Room.all
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new permitted_parameters

    if @room.save
      flash[:success] = "Room #{@room.name} was created successfully"
      redirect_to rooms_path
    else
      render :new
    end
    
    $games[@room.id] = Game.new()
    $games[@room.id].createGameBoard("single")
    $gameStarted[@room.id] = [false, 1, 0, true]#second number is who's turn it is (numerically), third is the ID of the player guessing
                                          #fourth is if it is time to choose category
  end

  def show
    if $games[@room.id].present?
      @room_message = RoomMessage.new room: @room
      if @room.present?
        @room_messages = @room.room_messages.includes(:user)
      else
        redirect_to rooms_path
      end
    else
      @room.destroy()
      redirect_to rooms_path
    end
  end

  def destroy
    Room.destroy(@room.id)
    redirect_to rooms_path
  end
  
  def buzzerModal
    cat = params[:cat]
    clue = params[:clue]
    @room = Room.find(params[:room])
    clueText = $games[@room.id].game_boards[0].categories[cat.to_i].clues[clue.to_i].question + " - " + $games[@room.id].game_boards[0].categories[cat.to_i].clues[clue.to_i].answer
    titleText = $games[@room.id].game_boards[0].categories[cat.to_i].name.upcase + " - " + $games[@room.id].game_boards[0].categories[cat.to_i].clues[clue.to_i].value.to_s
    if current_user.id == $usersReady[@room.id][ $gameStarted[@room.id][1]-1 ][0] && $gameStarted[@room.id][3] == true # Checks to see if the player who's turn it is chose the clue
      $games[@room.id].removeClueFromCurrentBoard($games[@room.id].game_boards[0].categories[cat.to_i].clues[clue.to_i].id)
      RoomChannel.broadcast_to @room,  buzzerModal: clue.to_s+cat.to_s, clue: clueText, title: titleText, id: current_user.id
      $gameStarted[@room.id][3] = false
      $answer = $games[@room.id].game_boards[0].categories[cat.to_i].clues[clue.to_i].answer
      $winnings = $games[@room.id].game_boards[0].categories[cat.to_i].clues[clue.to_i].value
    end
  end
  
  def buzzer
    @room = Room.find(params[:room])
    RoomChannel.broadcast_to @room,  buzzer: true, user: current_user
    $gameStarted[@room.id][2] = current_user.id #Sets the current user ID to the ID that is guessing
    if $gameStarted[@room.id][2] == $usersReady[@room.id][0][0]
       $playerForMoney = 0
    elsif $gameStarted[@room.id][2] == $usersReady[@room.id][1][0]
       $playerForMoney = 1
    elsif $gameStarted[@room.id][2] == $usersReady[@room.id][2][0]
       $playerForMoney = 2
    end
    $answering = true
    answerCountDown(10)
  end
  
  def answerCountDown(i)
    Thread.new do
      Rails.application.executor.wrap do
        while i > -1  do
          RoomChannel.broadcast_to @room,  timer: i, user: current_user
          sleep 1
          i -=1
        end
        RoomChannel.broadcast_to @room,  closeAnswerModal: true, user: current_user
        winnings1 = 0
        winnings2 = 0
        winnings3 = 0
        if ( $usersReady[@room.id][0] != nil )
          winnings1 = $usersReady[@room.id][0][3]
        end
        if ( $usersReady[@room.id][1] != nil )
          winnings2 = $usersReady[@room.id][1][3]
        end
        if ( $usersReady[@room.id][2] != nil )
          winnings3 = $usersReady[@room.id][2][3]
        end
        if $answering == true
          RoomChannel.broadcast_to @room,  noAnswer: true, player: $playerForMoney + 1
          $answering = false
          $gameStarted[@room.id][1] = $gameStarted[@room.id][1] + 1
          if $gameStarted[@room.id][1] > $usersReady[@room.id].length
            $gameStarted[@room.id][1] = 1
          end
          if $gameStarted[@room.id][1] == $playerForMoney + 1 #turn passes, but not to who just missed answering
            $gameStarted[@room.id][1] = $gameStarted[@room.id][1] + 1
          end
          $usersReady[@room.id][ $playerForMoney ][3] = $usersReady[@room.id][ $playerForMoney ][3] - $winnings
          answerCountDown(3)
        else
          RoomChannel.broadcast_to @room,  nextPlayer: true, player: $gameStarted[@room.id][1], winnings1: winnings1, winnings2: winnings2, winnings3: winnings3
          $gameStarted[@room.id][3] = true
        end
      end
    end
  end
  
  
  def playerReady
    @room = Room.find(params[:room])
    if $usersReady[@room.id] == nil
      $usersReady[@room.id] = []
    end
    if !$usersReady[@room.id].include?([current_user.id, current_user.username, current_user.avatar_url, 0])
      $usersReady[@room.id].push([current_user.id, current_user.username, current_user.avatar_url, 0])
    end
    RoomChannel.broadcast_to @room,  command: "READY", usersReady: $usersReady[@room.id]
  end
  
  def startGame
    @room = Room.find(params[:room])
    $gameStarted[@room.id][0] = true
    RoomChannel.broadcast_to @room,  start: true, player: $gameStarted[@room.id][1]
  end
  
  def answer
    @room = Room.find(params[:room])
    if current_user.id == $gameStarted[@room.id][2] # Checks to see if the guessing player is pressing the button.
      distance = Levenshtein.normalized_distance params[:answer], $answer, 100
      if distance < 0.4
        correct = "correct!"
        $usersReady[@room.id][ $playerForMoney ][3] = $usersReady[@room.id][ $playerForMoney ][3] + $winnings
      else
        correct = "sorry, that's not right."
        $gameStarted[@room.id][1] = $gameStarted[@room.id][1] + 1
        if $gameStarted[@room.id][1] > $usersReady[@room.id].length
          $gameStarted[@room.id][1] = 1
        end
        $usersReady[@room.id][ $playerForMoney ][3] = $usersReady[@room.id][ $playerForMoney ][3] - $winnings
      end
      RoomChannel.broadcast_to @room,  answer: true, text: params[:answer] + " - " + correct, user: current_user.username
      $answering = false
    end
  end

  def update
    if @room.update_attributes(permitted_parameters)
      flash[:success] = "Room #{@room.name} was updated successfully"
      redirect_to rooms_path
    else
      render :new
    end
  end

  protected

  def load_entities
    if Room.where(id: params[:id]).present?
      @room = Room.find(params[:id]) if params[:id]
    end
  end

  def permitted_parameters
    params.require(:room).permit(:name)
  end
end
