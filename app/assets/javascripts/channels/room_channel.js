$(function() {
  $('[data-channel-subscribe="room"]').each(function(index, element) {
    var $element = $(element),
        room_id = $element.data('room-id');
        chatArea = $('[data-role="chat"]');
        messageTemplate = $('[data-role="message-template"]');
        dataArea = $('[data-role="display-raw-data"]');
        timerArea = $('[data-role="display-timer"]');
        playersReadyArea = $('[data-role="display-ready-players"]');
        buzzerModal = $('[data-role="buzzerModal"]');

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
            if (data.timer == 1){
            buzzerModal.modal('toggle')
            }
          }
          if (data.usersReady !=null){
          var players = 'Players Ready:<br/>'
          for (var i = 0; i < data.usersReady.length; i++){
            players = players + data.usersReady[i] + '<br/>'
          }
          playersReadyArea.html(players);
          }
          dataArea.text(JSON.stringify(data));
          console.log(data);
        }
      }
    );
  });
});
