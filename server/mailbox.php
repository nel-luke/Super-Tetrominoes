<?php

class Mailbox {
  private $pdo;

  function __construct($pdo_ref) {
    $this->pdo = $pdo_ref;
  }

  function create($from_id, $to_id) {
    $create_mailbox = $this->pdo->prepare("INSERT INTO mailboxes(player_id_A, player_id_B) VALUES (?, ?)");
    $create_mailbox->execute([ $from_id, $to_id ]);

    $check_mailbox = $this->pdo->prepare('SELECT id FROM mailboxes WHERE player_id_A = ?');
    $check_mailbox->execute([ $from_id ]);
    $mailbox_info = $check_mailbox->fetch();

    $this->setInfo($mailbox_info['id'], $to_id, true, true);
  }

  function destroy() {
    $destroy_mailbox = $this->pdo->prepare("DELETE FROM mailboxes WHERE id = ?");
    $destroy_mailbox->execute([ $_SESSION['mailbox_id'] ]);
    $this->setInfo(null, null, null, null);
  }

  function setup($player_id) {
    $get_mailbox = $this->pdo->prepare('SELECT id, player_id_A FROM mailboxes WHERE player_id_B = ?');
    $get_mailbox->execute([ $player_id ]);
    $mailbox_info = $get_mailbox->fetch();

    $this->setInfo($mailbox_info['id'], $mailbox_info['player_id_A'], false, true);
  }

  function reset() {
    $this->setInfo(null, null, null, null);
  }

  function canIncrement() {
    return $_SESSION['can_increment'];
  }

  function incremented() {
    $_SESSION['can_increment'] = false;
  }

  function getOpponentId() {
    return $_SESSION['opponent_id'];
  }

  function send($message_type, $data = null) {
    if (!isset($_SESSION['mailbox_id']))
      return;

    $new_message = [ 'type' => $message_type ];
    if (isset($data)) {
      if (is_array($data))
        $new_message['data'] = $data;
      else
        $new_message['data'] = [ $data ];
    }

    if ($_SESSION['created_mailbox']) {
      $get_old = $this->pdo->prepare('SELECT from_A FROM mailboxes WHERE id = ?');
      $message_mailbox = $this->pdo->prepare('UPDATE mailboxes SET from_A = ? WHERE id = ?');
    } else {
      $get_old = $this->pdo->prepare('SELECT from_B FROM mailboxes WHERE id = ?');
      $message_mailbox = $this->pdo->prepare('UPDATE mailboxes SET from_B = ? WHERE id = ?');
    }
    
    $get_old->execute([ $_SESSION['mailbox_id'] ]);
    $old_message = $get_old->fetch(PDO::FETCH_NUM);

    if (!empty($old_message[0])) {
      $old_message = json_decode($old_message[0], true);

      if ($old_message['type'] === 'Control' && $new_message['type'] === 'Control') {
        $new_message['data'] = array_merge($old_message['data'], $new_message['data']);
      }
    }

    $message_mailbox->execute([ json_encode($new_message), $_SESSION['mailbox_id'] ]);
  }

  function get() {
    // if (!isset($_SESSION['mailbox_id']))
    //   return [ 'type' => 'Disconnected', 'last_type' => '' ];

    if ($_SESSION['created_mailbox']) {
      $get_message = $this->pdo->prepare('SELECT player_id_B, from_B FROM mailboxes WHERE id = ?');
      $clean_message = $this->pdo->prepare("UPDATE mailboxes SET from_B = '' WHERE id = ?");
    } else {
      $get_message = $this->pdo->prepare('SELECT player_id_A, from_A FROM mailboxes WHERE id = ?');
      $clean_message = $this->pdo->prepare("UPDATE mailboxes SET from_A = '' WHERE id = ?");
    }

    $get_message->execute([ $_SESSION['mailbox_id'] ]);
    $clean_message->execute([ $_SESSION['mailbox_id'] ]);

    $message = $get_message->fetch(PDO::FETCH_NUM);

    $json = json_decode($message[1], true);

    if (!isset($message[0])) {
      return [ 'type' => 'Disconnected', 'last_type' => $json['type'] ];
    }
    
    return $json;
  }

  function isAvailable() {
    return isset($_SESSION['mailbox_id']);
  }

  private function setInfo($mailbox_id, $opponent_id, $created_mailbox, $can_increment) {
    $_SESSION['mailbox_id'] = $mailbox_id;
    $_SESSION['opponent_id'] = $opponent_id;
    $_SESSION['created_mailbox'] = $created_mailbox;
    $_SESSION['can_increment'] = $can_increment;
  }
}

?>