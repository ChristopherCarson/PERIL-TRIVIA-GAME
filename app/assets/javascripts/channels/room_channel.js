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
            buzzerModalTitle.text(title);
            buzzerModal.modal('show')
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
