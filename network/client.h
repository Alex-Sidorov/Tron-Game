#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QPoint>

class Client : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString curWay MEMBER m_curWay NOTIFY changedWay)

public:
    explicit Client(QObject *parent = nullptr);
    virtual ~Client();

    Q_INVOKABLE void connectToHost();
    Q_INVOKABLE void disconnectFromHost();
    Q_INVOKABLE bool isConnected() const;
    Q_INVOKABLE void sendWay(const QString& way);

signals:
    void newPoints(const QPoint first, const QPoint second);
    void waitConnect();
    void errorConnectToHost();
    void connectSuccessfully();
    void disconnectedFromHost();
    void waitingPlayer();
    void startGame();

    void changedWay();

private slots:
    void readData();

private:
    QTcpSocket m_client;

    QString m_addr = "127.0.0.1";
    quint16 m_port = 8080;

    QString m_curWay;

    void parse(const QByteArray &data);

};

#endif // CLIENT_H
