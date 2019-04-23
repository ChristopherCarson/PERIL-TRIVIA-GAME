$(function() {
  $('[data-channel-subscribe="room"]').each(function(index, element) {
    var $element = $(element),
        room_id = $element.data('room-id');
        chatArea = $('[data-role="chat"]');
        messageTemplate = $('[data-role="message-template"]');
        dataArea = $('[data-role="display-raw-data"]');
        timerArea = $('[data-role="timer-countdown"]');
        playersReadyArea = $('[data-role="display-ready-players"]');
        buzzerModal = $('[data-role="buzzerModal"]');
        buzzerModalClue = $('[data-role="buzzerModalClue"]');
        buzzerModalTitle = $('[data-role="buzzerModalTitle"]');
        buzzerModalButton = $('[data-role="buzzerModalButton"]');
        answerModal = $('[data-role="answerModal"]');
        answerModalTitle = $('[data-role="answer-modal-title"]');
        textInput = $('[id="text-input"]');
        var buttons = [];
        buttons[0] = $('[data-role="Button_00"]');
        buttons[1] = $('[data-role="Button_01"]');
        buttons[2] = $('[data-role="Button_02"]');
        buttons[3] = $('[data-role="Button_03"]');
        buttons[4] = $('[data-role="Button_04"]');
        buttons[5] = $('[data-role="Button_05"]');
        buttons[10] = $('[data-role="Button_10"]');
        buttons[11] = $('[data-role="Button_11"]');
        buttons[12] = $('[data-role="Button_12"]');
        buttons[13] = $('[data-role="Button_13"]');
        buttons[14] = $('[data-role="Button_14"]');
        buttons[15] = $('[data-role="Button_15"]');
        buttons[20] = $('[data-role="Button_20"]');
        buttons[21] = $('[data-role="Button_21"]');
        buttons[22] = $('[data-role="Button_22"]');
        buttons[23] = $('[data-role="Button_23"]');
        buttons[24] = $('[data-role="Button_24"]');
        buttons[25] = $('[data-role="Button_25"]');
        buttons[30] = $('[data-role="Button_30"]');
        buttons[31] = $('[data-role="Button_31"]');
        buttons[32] = $('[data-role="Button_32"]');
        buttons[33] = $('[data-role="Button_33"]');
        buttons[34] = $('[data-role="Button_34"]');
        buttons[35] = $('[data-role="Button_35"]');
        buttons[40] = $('[data-role="Button_40"]');
        buttons[41] = $('[data-role="Button_41"]');
        buttons[42] = $('[data-role="Button_42"]');
        buttons[43] = $('[data-role="Button_43"]');
        buttons[44] = $('[data-role="Button_44"]');
        buttons[45] = $('[data-role="Button_45"]');
        player1Winnings = $('[data-role="player-1-winnings"]');
        player2Winnings = $('[data-role="player-2-winnings"]');
        player3Winnings = $('[data-role="player-3-winnings"]');
        

    $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000)        

    App.cable.subscriptions.create(
      {
        channel: "RoomChannel",
        room: room_id
      },
      {
        received: function(data) {
          if (data.message != null){
          var content = messageTemplate.children().clone(true, true);
          content.find('[data-role="user-avatar"]').attr('src', data.user_avatar_url);
          content.find('[data-role="message-text"]').text(data.message);
          content.find('[data-role="message-date"]').text(data.updated_at);
          
          chatArea.append(content);
          chatArea.animate({ scrollTop: chatArea.prop("scrollHeight")}, 1000);
          }
          if (data.timer !=null){
            timerArea.text(JSON.stringify(data.timer));
          }
          
          if (data.closeClueModal !=null){
            buzzerModal.modal('hide')
          }
          
          if (data.closeAnswerModal !=null){
          textInput.val('');
          answerModal.modal('hide');
          }
          
          if (data.start !=null){
            location.reload()
          }
          
          if (data.nextPlayer !=null){
            var player = JSON.stringify(data.player);
            player = player.substring(1, player.length-1);
            playersReadyArea.text("Player " + player + ", it's your turn to choose a category.")
            var winnings1 = "$"+JSON.stringify(data.winnings1);
            var winnings2 = "$"+JSON.stringify(data.winnings2);
            var winnings3 = "$"+JSON.stringify(data.winnings3);
            player1Winnings.text(winnings1);
            player2Winnings.text(winnings2);
            player3Winnings.text(winnings3);
          }
          
          
          if (data.answer !=null){
            answerModal.modal('hide');
            var answer = JSON.stringify(data.text);
            answer = answer.substring(1, answer.length-1);
            var user = JSON.stringify(data.user);
            user = user.substring(1, user.length-1);
            answer = user + " guessed: " + answer
            playersReadyArea.text(answer)
          }
          
          
          if (data.buzzerModal !=null){
            var clue = JSON.stringify(data.clue).replace(String.fromCharCode(92), "").replace(String.fromCharCode(92), "")
            clue = clue.substring(1, clue.length-1);
            buzzerModalClue.text(clue);
            var title = JSON.stringify(data.title);
            title = title.substring(1, title.length-1);
            var button = JSON.stringify(data.buzzerModal);
            button = button.substring(1, button.length-1);
            buzzerModalTitle.text(title);
            buzzerModal.modal('show')
            buttons[parseInt(button)].text('')
            
          }
          
          if (data.buzzer !=null){
            buzzerModal.modal('hide')
            answerModal.modal('show');
            var title = JSON.stringify(data.user.username);
            title = title.substring(1, title.length-1);
            title = title + " is answering";
            answerModalTitle.text(title);

          }
          
          if (data.usersReady !=null){
          var players = 'Players Ready:<br/>'
          for (var i = 0; i < data.usersReady.length; i++){
            players = players + data.usersReady[i][1] + '<br/>'
          }
          playersReadyArea.html(players);
          location.reload()
          }
          //dataArea.text(JSON.stringify(data));
          console.log(data);
          
          
        }
      }
    );
  });
});
