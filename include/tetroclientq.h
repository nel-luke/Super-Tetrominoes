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
#include <QTimerEvent>

#include <qqml.h>

#include <vector>
#include <algorithm>

class TetroClientQ : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QString server_address READ serverAddress WRITE setServerAddress
		NOTIFY serverAddressChanged)
private:
	enum ResponseType {
		PhpEcho = 0,
		Success,
		Error,
		Debug,
		LoginSuccess,
		LoginFail,
		PlayerList,
		ChallengeSent,
		ChallengeAlert,
		Disconnected,
		ChallengeAccepted,
		ChallengeDeclined,
		Control,
		OpponentReady,
		Terminated,
		WinGameSuccess,

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
		DebugPlayer,
	};

	struct control {
		ControlName name;
		QVariantList args;
	};

	QNetworkAccessManager* const manager;
	QUrl server_address;
	QList<control> control_log;
	QVector<QJsonObject> control_queue;
	int next_control_number;
	int control_timer_id;
	bool packet_is_lost;
	int ready_timer_id;
	int win_timer_id;
	QString session_cookie;
	bool hold_control;

	// Private Methods
	void sendData(const QString& message_type, QJsonObject&& data = QJsonObject()) const;
	void sendControl(ControlName control_name, QVariantList&& args = QVariantList());
	QList<QVariantMap> makeList(const QJsonArray&& values) const;
	//void makeLeaderboard(const QJsonArray& values) const;
	void appendControls(QJsonArray&& data);

	// Handlers
	void handleLoginSuccessful(QJsonObject&& data) const;
	void handlePlayerListReady(QJsonObject&& data) const;
	void handleControl();
	void handleOpponentReady();
	void handleTerminated();
	void handleDisconnected();

protected:
	void timerEvent(QTimerEvent * event) override;

public:

	// Constructors
	explicit TetroClientQ(QObject *parent = nullptr);

	// Getter Methods
	inline QString serverAddress() const
		{ return server_address.toString(); }

	// Setter Methods
	inline void setServerAddress(const QString& server_addr)
		{ server_address = QUrl(server_addr); emit serverAddressChanged(); }

private slots:
	void getReply(QNetworkReply* reply);

public slots:

	// Server Commands
	void login(const QString& username, const QString& real_name) const;
	void sendChallenge(const QString& player_id) const;
	void sendReady();
	inline void getOnlinePlayers() const
		{ sendData("GetPlayerList"); }

	inline void pollChange() const
		{ sendData("PollChange"); }

	inline void acceptChallenge() const
		{ sendData("AcceptChallenge"); }

	inline void declineChallenge() const
		{ sendData("DeclineChallenge"); }

	// Send Key Controls
	inline void sendKeyUp()
		{ sendControl(KeyUp); }

	inline void sendKeyDown()
		{ sendControl(KeyDown); }

	inline void sendKeyLeft()
		{ sendControl(KeyLeft); }

	inline void sendKeyRight()
		{ sendControl(KeyRight); }

	inline void sendDebug(bool result)
		{ sendControl(DebugPlayer, { result }); }

	// Send State Controls
	void sendWinGame();
	inline void sendRemovePoints(unsigned int num_points)
		{ sendControl(RemovePoints, {num_points}); }

	inline void sendGetSpecial(unsigned int special_type)
		{ sendControl(GetSpecial, {special_type}); }

	inline void sendSpawnShape(unsigned int shape_type, QColor shape_color)
		{ sendControl(SpawnShape, {shape_type, shape_color}); }

	inline void sendServicePlayer()
		{ sendControl(ServicePlayer); }

signals:

	// Server Responses
	void serverAddressChanged() const;
	void loginSuccessful(const QString& username) const;
	void loginFail() const;
	void playerListReady(int score, const QList<QVariantMap>& online_players,
		const QList<QVariantMap>& leaderboard) const;

	void challengeSent() const;
	void challengeAlert(const QString& username) const;
	void disconnected() const;
	void challengeAccepted() const;
	void challengeDeclined() const;
	void startGame() const;

	// Get Key Controls
	void getKeyUp() const;
	void getKeyDown() const;
	void getKeyLeft() const;
	void getKeyRight() const;
	void getDebug(bool result) const;

	// Get State Controls
	void getRemovePoints(unsigned int num_points) const;
	void getGetSpecial(unsigned int special_type) const;
	void getWinGame() const;
	void getSpawnShape(unsigned int shape_type, QColor shape_color) const;
	void getServicePlayer() const;
};

#endif // TETROCLIENTQ_H
