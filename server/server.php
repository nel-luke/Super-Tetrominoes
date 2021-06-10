<?php
$data_in = json_decode(file_get_contents('php://input'), true);

if (strlen($data_in['cookie']) !== 0)
  session_id($data_in['cookie']);

session_start();

require './mailbox.php';
$main = new Main();
$main->go($data_in);

class Main {
  private $pdo;
  private $mailbox;

  function __construct() {
    $this->pdo = $this->connectToDatabase();
    $this->mailbox = new Mailbox($this->pdo);
  }

  function go($data_in) {

    switch ($data_in['type']) {
      case 'Login' : $this->login($data_in['data']['username'], $data_in['data']['real_name']);
        break;
      case 'GetPlayerList' : $this->getPlayerList($_SESSION['player_id']);
        break;
      case 'SendChallenge' : $this->sendChallenge($_SESSION['player_id'], $data_in['data']['player_id']);
        break;
      case 'PollChange' : $this->pollChange($_SESSION['player_id']);
        break;
      case 'AcceptChallenge' : $this->acceptChallenge();
        break;
      case 'DeclineChallenge' : $this->declineChallenge();
        break;
      case 'Control' : $this->sendControl($data_in['data']);
        break;
      case 'WinGame' : $this->winGame();
        break;
      case 'Ready' : $this->sendReady();
        break;
      case 'Terminate': $this->sendTerminate();

        break;
      default : $this->returnData('Error', 'Unkown message type ' . $data_in['type']);
    }

    echo "Forgot to call returnData()";
  }

  function login($username, $real_name) {
    $login_user = $this->pdo->prepare('SELECT id, username FROM player_info WHERE username=? AND real_name=?');
    $login_user->execute([ $username, $real_name ]);
    $user = $login_user->fetch();
    
    if (empty($user)) { // registerUser
      $add_user = $this->pdo->prepare('INSERT INTO player_info (username, real_name) VALUES (?, ?)');
      $query_success = $add_user->execute([ $username, $real_name ]);
      
      if ($query_success) {
        $login_user->execute([ $username, $real_name ]);
        $user = $login_user->fetch();
      } else {
        $this->returnData('LoginFail');
      }
    }

    $_SESSION['player_id'] = $user['id'];
    $this->setStatus('available');
    $this->updateTimestamp();
    $player_list = $this->getPlayerList($user['id'], true);
    $return_data = array_merge($player_list, [ 'username' => $user['username'] ]);
    $this->returnData('LoginSuccess', $return_data);
  }

  function getPlayerList($player_id, $return_now = false) {
    $get_score = $this->pdo->prepare("SELECT score FROM player_info WHERE id = ?");
    $get_score->execute([ $player_id ]);
    $score = $get_score->fetch(PDO::FETCH_ASSOC);

    $get_online = $this->pdo->prepare(
     "SELECT id, username FROM player_info WHERE (id in (SELECT player_info_id FROM online_players WHERE player_info_id != ? and player_status = 'available') )");
    $get_online->execute([ $player_id ]);

    $online_players = $get_online->fetchAll(PDO::FETCH_ASSOC);
    $leaderboard = $this->pdo->query('SELECT username, score FROM player_info ORDER BY score DESC LIMIT 20')->fetchAll(PDO::FETCH_ASSOC);
   
    $player_list = [
      'score' => $score['score'], 'online_players' => $online_players, 'leaderboard' => $leaderboard ];
    
      if ($return_now === true) {
      return $player_list;
    }

    $this->returnData('PlayerList', $player_list);
  }

  function sendChallenge($from_id, $to_id) {
    $this->mailbox->create($from_id, $to_id);
    $send_challenge = $this->pdo->prepare(
      "UPDATE online_players SET player_status = 'check_mailbox' 
      WHERE player_info_id = ? AND player_status = 'available'"
    );
    $result = $send_challenge->execute([ $to_id ]);
    
    if ($result) {
      $this->setStatus('unavailable');
      $this->returnData('ChallengeSent');
    } else {
      $this->mailbox->destroy();
      $this->returnData('ChallengeDeclined');
    }
  }

  function pollChange($player_id) {
    if ($this->mailbox->isAvailable()) {
      $this->checkMailbox();
    } else {
      $this->checkStatus($player_id);
    }
  }

  function acceptChallenge() {
    $this->mailbox->send('Accept');
    $this->returnData('Success');
  }

  function declineChallenge() {
    $this->mailbox->send('Decline');
    $this->mailbox->reset();
    $this->setStatus('Available');
    $this->returnData('Success');
  }

  function winGame() {
    $opponent_id = $this->mailbox->getOpponentId();
    if ($this->mailbox->canIncrement()) {
      $this->decrementScore($opponent_id);
      $this->incrementScore($_SESSION['player_id']);
      $this->mailbox->incremented();
    }
    $this->returnData('WinGameSuccess');
  }

  function sendTerminate() {
    $this->mailbox->send('DeleteMailbox');
    $this->mailbox->reset();
    $this->setStatus('Available');
    $this->returnData('Success');
  }

  function deleteMailbox() {
    $this->mailbox->destroy();
    $this->setStatus('Available');
    $this->returnData('Terminated');
  }

  function sendControl($data) {
    $this->mailbox->send('Control', $data);
    $this->returnData('Success');
  }

  function sendReady() {
    $this->mailbox->send('Ready');
    $this->returnData('Success');
  }

  function checkMailbox() {
    $this->updateTimestamp();
    $response = $this->mailbox->get();
    
    if (empty($response)) {
      $this->returnData('Success');
    }

    switch ($response['type']) {
      case 'Disconnected' : $this->disconnected($response['last_type']);
        break;
      case 'Accept' : $this->challengeAccepted();
        break;
      case 'Decline' : $this->challengeDeclined();
        break;
      case 'Control' : $this->returnData('Control', $response['data']);
        break;
      case 'Ready' : $this->returnData('OpponentReady');
        break;
      case 'DeleteMailbox' : $this->deleteMailbox();
        break;

      default : $this->returnData('Error', 'Unknown mailbox code ' . $response['type']);
    }
  }

  function disconnected($last_type) {
    if ($last_type === 'Control') {
      $opponent_id = $this->mailbox->getOpponentId();
      $this->decrementScore($opponent_id);
      $this->incrementScore($_SESSION['player_id']);
    }

    $this->mailbox->destroy();
    $this->setStatus('Available');
    $this->returnData('Disconnected');
  }

  function incrementScore($player_id) {
    $point = $this->pdo->prepare('UPDATE player_info SET score=score+1 WHERE id=?');
    $point->execute([ $player_id ]);
  }

  function decrementScore($player_id) {
    $point = $this->pdo->prepare('UPDATE player_info SET score=score-1 WHERE id=? AND score>0');
    $point->execute([ $player_id ]);
  }

  function challengeAccepted() {
    $this->returnData('ChallengeAccepted');
  }

  function challengeDeclined() {
    $this->mailbox->destroy();
    $this->setStatus('Available');
    $this->returnData('ChallengeDeclined');
  }

  function checkStatus($player_id) {
    $poll_change = $this->pdo->prepare("SELECT player_info_id FROM online_players WHERE player_info_id = ? AND player_status = 'check_mailbox'");
    $poll_change->execute([ $player_id ]);
    $result = $poll_change->fetch();

    if (!empty($result)) {
      $this->setStatus('unavailable');
      $this->updateTimestamp();
      $this->mailbox->setup($player_id);
      $creator_id = $this->mailbox->getOpponentId();

      $check_challenger_username = $this->pdo->prepare('SELECT username FROM player_info WHERE id = ?');
      $check_challenger_username->execute([ $creator_id ]);
      $challenger_username = $check_challenger_username->fetch();
      $this->returnData('ChallengeAlert', $challenger_username['username']);
    } else {
      $this->updateTimestamp();
      $this->returnData('Success');
    }
  }

  function setStatus($new_status) {
    $_SESSION['player_status'] = $new_status;
  }

  function updateTimestamp() {
    $this->pdo->query('DELETE FROM online_players WHERE TIMESTAMPDIFF(SECOND, last_updated, NOW()) > 5');
    $refresh = $this->pdo->prepare("INSERT INTO online_players(player_info_id, player_status) VALUES(?, ?) ON DUPLICATE KEY UPDATE player_status=?");
    $refresh->execute([ $_SESSION['player_id'], $_SESSION['player_status'], $_SESSION['player_status']]);
  }

  function connectToDatabase() {
    $settings = parse_ini_file('../../server.ini');
    $host = $settings['host'];
    $db_name = $settings['db_name'];
    $username = $settings['username'];
    $password = $settings['password'];
    $charset = $settings['charset'];
    
    $dsn = "mysql:host=$host;dbname=$db_name;charset=$charset";
    $options = [
      PDO::ATTR_ERRMODE             => PDO::ERRMODE_EXCEPTION,
      PDO::ATTR_DEFAULT_FETCH_MODE  => PDO::FETCH_ASSOC,
      PDO::ATTR_EMULATE_PREPARES    => false,
    ];

    try {
      $conn = new PDO($dsn, $username, $password);
      return $conn;
    } catch(PDOException $e) {
      $this->returnData('Error', $e->getMessage());
    }
  }
  
  function returnData($MessageType, $data = null) {
    $MessageTypeInt = 0;
    switch ($MessageType) {
      case 'Success' : $MessageTypeInt = 1;
        break;
      case 'Error' : $MessageTypeInt = 2;
        break;
      case 'Debug' : $MessageTypeInt = 3;
        break;
      case 'LoginSuccess' : $MessageTypeInt = 4;
        break;
      case 'LoginFail' : $MessageTypeInt = 5;
        break;
      case 'PlayerList' : $MessageTypeInt = 6;
        break;
      case 'ChallengeSent' : $MessageTypeInt = 7;
        break;
      case 'ChallengeAlert' : $MessageTypeInt = 8;
        break;
      case 'Disconnected' : $MessageTypeInt = 9;
      break;
      case 'ChallengeAccepted' : $MessageTypeInt = 10;
        break;
      case 'ChallengeDeclined' : $MessageTypeInt = 11;
        break;
      case 'Control' : $MessageTypeInt = 12;
        break;
      case 'OpponentReady' : $MessageTypeInt = 13;
        break;
      case 'Terminated' : $MessageTypeInt = 14;
        break;
      case 'WinGameSuccess' : $MessageTypeInt = 15;
    }

    header('Content-type: application/json; charset=utf-8');
    header('Access-Control-Allow-Headers: Content-Type');
    header("Access-Control-Allow-Origin: http://play.super-tetrominoes.online");

    $output = [ 'type' => $MessageTypeInt, 'cookie' => session_id() ];
    if (isset($data)) {
      $output['data'] = $data;
    }
    echo json_encode($output);
    exit();
  } 
}

?>