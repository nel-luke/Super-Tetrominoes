#include "tetroclientq.h"

TetroClientQ::TetroClientQ(QObject *parent) :
		QObject(parent),
		manager(new QNetworkAccessManager(this)),
		control_log(),
		control_queue(),
		next_control_number(0),
		control_timer_id(0),
		packet_is_lost(false),
		ready_timer_id(0),
		win_timer_id(0) {
	connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(getReply(QNetworkReply*)));

}

void TetroClientQ::sendData(const QString& message_type, QJsonObject&& data) const {
	QNetworkRequest request(server_address);

	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
	QJsonObject json;
	json["type"] = message_type;
	json["data"] = data;
	QJsonDocument doc(json);

	manager->post(request, doc.toJson());
}

void TetroClientQ::sendControl(ControlName control_name, QVariantList&& args) {
	QJsonObject json;
	json["control_number"] = control_log.size();
	json["control_name"] = control_name;
	json["args"] = QJsonArray::fromVariantList(args);

	control_log.push_back({ control_name, args });

	sendData("Control", std::move(json));
}

QList<QVariantMap> TetroClientQ::makeList(const QJsonArray&& values) const {
	QVector<QVariantMap> list(values.size());
	std::transform(values.begin(), values.end(), list.begin(),
								 [](const QJsonValue& a) { return a.toObject().toVariantMap(); });
	return QList<QVariantMap>::fromVector(list);
}

void TetroClientQ::handleLoginSuccessful(QJsonObject&& data) const {
	emit loginSuccessful(data["username"].toString());
	handlePlayerListReady(std::move(data));
}

void TetroClientQ::appendControls(QJsonArray&& data) {
	QVector<QJsonObject> list(data.size());
	std::transform(data.begin(), data.end(), list.begin(),
								 [](const QJsonValue& a) { return a.toObject(); });

	control_queue.append(std::move(list));

	control_queue.erase( std::unique( control_queue.begin(), control_queue.end(),
		[](const QJsonObject& a, const QJsonObject& b) -> bool {
			return a["control_number"].toInt() == b["control_number"].toInt(); } ), control_queue.end() );

	std::sort(control_queue.begin(), control_queue.end(),
						[](const QJsonObject& a, const QJsonObject& b) -> bool {
			return a["control_number"].toInt() < b["control_number"].toInt(); });

	control_queue.erase(control_queue.begin(), std::lower_bound( control_queue.begin(),
		control_queue.end(), next_control_number, [](const QJsonObject& a, int val) -> bool {
		int t = a["control_number"].toInt();
		return (t != -1) && (t < val); } ) );

	if (control_timer_id == 0) {
		handleControl();

		if (!control_queue.isEmpty() && !packet_is_lost) {
			control_timer_id = startTimer(15);
			qInfo() << "Starting timer " << control_timer_id;
		}
	}
}

void TetroClientQ::handlePlayerListReady(QJsonObject&& data) const {
	int score = data["score"].toString().toUInt();
	auto online_players = makeList(std::move(data["online_players"].toArray()));
	auto leaderboard = makeList(std::move(data["leaderboard"].toArray()));
	emit playerListReady(score, online_players, leaderboard);
}

void TetroClientQ::handleControl() {
	if (control_queue.isEmpty()) {
		if (control_timer_id != 0) {
			killTimer(control_timer_id);
			qInfo() << "Stopping timer " << control_timer_id;
			control_timer_id = 0;
		}
	} else {
		int control_number = control_queue[0]["control_number"].toInt();

		if (control_number == -1) {
			int to_send = control_queue[0]["args"].toInt();
			qInfo() << "Sending control " << to_send;
			control a = control_log[to_send];

			QJsonObject json;
			json["control_number"] = to_send;
			json["control_name"] = a.name;
			json["args"] = QJsonArray::fromVariantList(a.args);
			sendData("Control", std::move(json));

			control_queue.pop_front();
			handleControl();
			return;
		} else if (control_number < next_control_number) {
			qInfo() << "Duplicate skipped";
			control_queue.pop_front();
			handleControl();
			return;
		} else if (control_number > next_control_number) {
			qInfo() << "Packet " << next_control_number << " Lost!";
			QJsonObject json;
			json["control_number"] = -1;
			json["args"] = next_control_number;
			sendData("Control", std::move(json));

			packet_is_lost = true;

			if (control_timer_id != 0) {
				qInfo() << "Lost stopped timer " << control_timer_id;
				killTimer(control_timer_id);
				control_timer_id = 0;
			}
			return;
		}

		packet_is_lost = false;

		qInfo() << "Control number " << control_number;
		QVariantList args = control_queue[0]["args"].toArray().toVariantList();

		switch (control_queue[0]["control_name"].toInt()) {
			case KeyUp: emit getKeyUp();
				break;
			case KeyDown: emit getKeyDown();
				break;
			case KeyLeft: emit getKeyLeft();
				break;
			case KeyRight: emit getKeyRight();
				break;

			case RemovePoints: emit getRemovePoints(args[0].toUInt());
				break;
			case GetSpecial: emit getGetSpecial(args[0].toUInt());
				break;
			case WinGame: emit getWinGame(); control_log.clear(); sendData("Terminate");
				break;
			case SpawnShape: emit getSpawnShape(args[0].toUInt(), args[1].toString());
				break;
			case ServicePlayer: emit getServicePlayer();
				break;
			case DebugPlayer: emit getDebug(args[0].toBool());
		}

		control_queue.pop_front();
		next_control_number++;
	}
}

void TetroClientQ::handleOpponentReady() {
	if (ready_timer_id != 0) {
		killTimer(ready_timer_id);
		ready_timer_id = 0;
		emit startGame();
	}
}


void TetroClientQ::handleTerminated() {
	if (win_timer_id != 0) {
		killTimer(win_timer_id);
		win_timer_id = 0;
	}
	control_log.clear();
}

void TetroClientQ::timerEvent(QTimerEvent* event) {
	int event_id = event->timerId();
	if (event_id == control_timer_id) {
		handleControl();
	} else if (event_id == ready_timer_id) {
		sendData("Ready");
	} else if (event_id == win_timer_id) {
		sendControl(WinGame);
	}
}

void TetroClientQ::login(const QString& username, const QString& real_name) const {
	QJsonObject json;
	json["username"] = username;
	json["real_name"] = real_name;

	sendData("Login", std::move(json));
}

void TetroClientQ::sendChallenge(const QString& player_id) const {
	QJsonObject json;
	json["player_id"] = player_id;

	sendData("SendChallenge", std::move(json));
}

void TetroClientQ::getReply(QNetworkReply *reply) {
	QByteArray str = reply->readAll();
	QJsonObject json = QJsonDocument::fromJson(str).object();

	switch (json["type"].toInt()) {
		case PhpEcho:
			qInfo() << "PHP Echo: " << str;
			break;
		case Success:
			break;
		case Error:
			qInfo() << "Error: " << json["data"].toString();
			break;
		case Debug:
			qInfo() << "Debug: " << json["data"].toString();
			break;

		case LoginSuccess:
			handleLoginSuccessful(json["data"].toObject());
			break;
		case LoginFail:
			emit loginFail();
			break;

		case PlayerList:
			handlePlayerListReady(json["data"].toObject());
			break;

		case ChallengeSent:
			emit challengeSent();
			break;
		case ChallengeAlert:
			emit challengeAlert(json["data"].toString());
			break;

		case Disconnected:
			emit disconnected();
			break;
		case ChallengeAccepted:
			emit challengeAccepted();
			break;
		case ChallengeDeclined:
			emit challengeDeclined();
			break;

		case Control:
			handleOpponentReady();
			appendControls(json["data"].toArray());
			break;
		case OpponentReady:
			handleOpponentReady();
			break;
		case Terminated:
			handleTerminated();
			break;

		default:
			qInfo() << "Error: Missing case for response code " << json["type"].toInt();
			break;
	}
}

void TetroClientQ::sendReady() {
	sendData("Ready");
	if (ready_timer_id == 0) {
		ready_timer_id = startTimer(50);
	}
}

void TetroClientQ::sendWinGame() {
	QJsonObject json;
	json["control_number"] = control_log.size();
	json["control_name"] = WinGame;

	sendData("Control", std::move(json));

	if (win_timer_id == 0) {
		win_timer_id = startTimer(50);
	}
}