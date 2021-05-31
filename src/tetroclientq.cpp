#include "tetroclientq.h"

TetroClientQ::TetroClientQ(QObject *parent) :
		QObject(parent), manager(new QNetworkAccessManager(this)),
		control_log(), control_queue(), next_control_number(0) {
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
	emit loginSuccessful(data["username"].toString(), data["score"].toString().toUInt());
}

void TetroClientQ::handleControl(QJsonArray&& data) {

	QVector<QJsonObject> list(data.size());
	std::transform(data.begin(), data.end(), list.begin(),
								 [](const QJsonValue& a) { return a.toObject(); });

	control_queue.append(list);
	std::sort(control_queue.begin(), control_queue.end(),
						[](const QJsonObject& a, const QJsonObject& b) -> bool {
		return a["control_number"].toInt() < b["control_number"].toInt(); });

//	list.erase( std::unique( list.begin(), list.end(),
//			[](const QJsonObject& a, const QJsonObject& b) -> bool {
//		return a["control_number"].toInt() == b["control_number"].toInt(); } ), list.end() );

	while (!control_queue.isEmpty()) {
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
			continue;
		} else if (control_number < next_control_number) {
			qInfo() << "Duplicate skipped";
			control_queue.pop_front();
			continue;
		} else if (control_number > next_control_number) {
			qInfo() << "Packet " << next_control_number << " Lost!";
			QJsonObject json;
			json["control_number"] = -1;
			//json["control_name"] = RepeatControl;
			json["args"] = next_control_number;
			sendData("Control", std::move(json));
			break;
		}

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
			case WinGame: emit getWinGame();
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

		case OnlinePlayers:
			emit onlinePlayersReady(makeList(json["data"].toArray()));
			break;
		case Leaderboard:
			emit leaderboardReady(makeList(json["data"].toArray()));
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
			handleControl(json["data"].toArray());
			break;
		//case RepeatControl:
		//	handleRepeatControl(json["data"].toString().toInt());
		//	break;

		default:
			qInfo() << "Error: Missing case for response code " << json["type"].toInt();
			break;
	}
}

