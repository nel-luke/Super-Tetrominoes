#ifndef TETROCLIENTQ_H
#define TETROCLIENTQ_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QUrl>
#include <QColor>
#include <QString>
#include <QList>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>

#include <qqml.h>

#include <vector>
#include <algorithm>

class TetroClientQ : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QString server_address READ serverAddress WRITE setServerAddress NOTIFY serverAddressChanged)
private:
	enum ResponseType {
		PhpEcho = 0,
		Success,
		Error,
		Debug,
		LoginSuccess,
		LoginFail,
		OnlinePlayers,
		Leaderboard,
		ChallengeSent,
		ChallengeAlert,
		Disconnected,
		ChallengeAccepted,
		ChallengeDeclined,
		Control
	};

	enum ControlName {
		KeyUp,
		KeyDown,
		KeyLeft,
		KeyRight,
		RemovePoints,
		GetSpecial,
		WinGame,
		SpawnShape,
		ServicePlayer,
		DebugPlayer
	};

	QNetworkAccessManager* const manager;
	QUrl server_address;

	void sendData(const QString& message_type, QJsonObject&& data = QJsonObject()) const;
	void sendControl(ControlName control_name, QVariantList&& args = QVariantList()) const;
	QList<QVariantMap> makeList(const QJsonArray&& values) const;
	void makeLeaderboard(const QJsonArray& values) const;

	void handleLoginSuccessful(QJsonObject&& data) const;
	void handleControl(QJsonArray&& data) const;

public:

	// Constructors
	explicit TetroClientQ(QObject *parent = nullptr);

	// Getter Methods
	inline QString serverAddress() const { return server_address.toString(); }

	// Settor Methods
	inline void setServerAddress(const QString& server_addr) {
		server_address = QUrl(server_addr); emit serverAddressChanged(); }

	// Interface
	Q_INVOKABLE void login(const QString& username, const QString& real_name) const;
	Q_INVOKABLE void getOnlinePlayers() const { sendData("GetOnlinePlayers"); }
	Q_INVOKABLE void getLeaderboard() const { sendData("GetLeaderboard"); }
	Q_INVOKABLE void sendChallenge(const QString& player_id) const;
	Q_INVOKABLE void pollChange() const { sendData("PollChange"); }
	Q_INVOKABLE void acceptChallenge() const { sendData("AcceptChallenge"); }
	Q_INVOKABLE void declineChallenge() const { sendData("DeclineChallenge"); }

	// Controls
	Q_INVOKABLE void sendKeyUp() const { sendControl(KeyUp); }
	Q_INVOKABLE void sendKeyDown() const { sendControl(KeyDown); }
	Q_INVOKABLE void sendKeyLeft() const { sendControl(KeyLeft); }
	Q_INVOKABLE void sendKeyRight() const { sendControl(KeyRight); }
	Q_INVOKABLE void sendDebug(bool result) const { sendControl(DebugPlayer, { result }); }

private slots:
	void getReply(QNetworkReply* reply) const;

public slots:
	void sendRemovePoints(unsigned int num_points) const
		{ sendControl(RemovePoints, {num_points}); }
	void sendGetSpecial(unsigned int special_type) const
		{ sendControl(GetSpecial, {special_type}); }
	void sendWinGame() const { sendControl(WinGame); }

	void sendSpawnShape(unsigned int shape_type, QColor shape_color) const
		{ sendControl(SpawnShape, {shape_type, shape_color}); }
	void sendServicePlayer() const { sendControl(ServicePlayer); }

signals:
	void serverAddressChanged() const;
	void loginSuccessful(const QString& username, unsigned int score) const;
	void loginFail() const;
	void onlinePlayersReady(const QList<QVariantMap>& list) const;
	void leaderboardReady(const QList<QVariantMap>& list) const;
	void challengeSent() const;
	void challengeAlert(const QString& username) const;
	void disconnected() const;
	void challengeAccepted() const;
	void challengeDeclined() const;

	void getKeyUp() const;
	void getKeyDown() const;
	void getKeyLeft() const;
	void getKeyRight() const;
	void getDebug(bool result) const;

	void getRemovePoints(unsigned int num_points) const;
	void getGetSpecial(unsigned int special_type) const;
	void getWinGame() const;
	void getSpawnShape(unsigned int shape_type, QColor shape_color) const;
	void getServicePlayer() const;
};

#endif // TETROCLIENTQ_H
