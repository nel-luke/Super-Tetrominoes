#include "tetroclientq.h"

TetroClientQ::TetroClientQ(QObject *parent) :
		QObject(parent), manager(new QNetworkAccessManager(this)) {
	connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(getReply(QNetworkReply*)));
}

void TetroClientQ::sendData(const QString& message_type, QJsonObject&& data) const {
	QNetworkRequest request(server_address);

	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
	data["type"] = message_type;
	QJsonDocument doc(data);

	manager->post(request, doc.toJson());
}

void TetroClientQ::sendControl(ControlName control_name, QVariantList&& args) const {
	QJsonObject json;
	json["control_name"] = control_name;
	json["args"] = QJsonArray::fromVariantList(args);

	sendData("Control", std::move(json));
}

QList<QVariantMap> TetroClientQ::makeList(const QJsonArray&& values) const {
	QVector<QVariantMap> list(values.size());
	std::transform(values.begin(), values.end(), list.begin(),
								 [](const QJsonValue& a) { return a.toObject().toVariantMap(); });
	return QList<QVariantMap>::fromVector(std::move(list));
}

void TetroClientQ::handleLoginSuccessful(QJsonObject&& data) const {
	emit loginSuccessful(data["username"].toString(), data["score"].toInt());
}

void TetroClientQ::handleControl(QJsonArray&& data) const {
	for (const auto& entry : data) {
		QJsonObject json = entry.toObject();
		QVariantList args = json["args"].toArray().toVariantList();
		switch (json["control_name"].toInt()) {
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

void TetroClientQ::getReply(QNetworkReply *reply) const {
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
			emit challengeAlert((json["data"].toObject())["username"].toString());
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

		default:
			qInfo() << "Error: Missing case for response code " << json["type"].toInt();
			break;
	}
}

