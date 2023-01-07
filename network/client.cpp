#include "client.h"
#include <QByteArray>
#include <QtDebug>

#include <QJsonObject>
#include <QJsonValue>
#include <QJsonDocument>

Client::Client(QObject *parent)
    : QObject{parent}
{
    connect(&m_client, &QTcpSocket::readyRead, this, &Client::readData);
    connect(&m_client, &QTcpSocket::connected, this, &Client::connectSuccessfully);
    connect(&m_client, &QTcpSocket::errorOccurred, this, &Client::errorConnectToHost);
}

Client::~Client()
{
    disconnectFromHost();
}

void Client::connectToHost()
{
    m_client.connectToHost(m_addr, m_port);
    emit waitConnect();
}

void Client::disconnectFromHost()
{
    if(isConnected())
    {
        m_client.disconnectFromHost();
        emit disconnectedFromHost();
    }
}

bool Client::isConnected() const
{
    return m_client.isOpen();
}

void Client::sendWay(const QString &way)
{
    if(!isConnected())
        return;

    QJsonObject json({{"cmd", "way"},{"way", way}});
    m_client.write(QJsonDocument(json).toJson());
    m_client.flush();
}

void Client::readData()
{
    if(!isConnected())
        return;

    parse(m_client.readAll());
}

void Client::parse(const QByteArray &data)
{
    qDebug() << "Recv data size: " << data.size();

    if(data.isEmpty())
        return;

    auto json = QJsonDocument::fromJson(data).object();

    auto cmd = json["cmd"].toString();

    if(cmd == QLatin1String("points"))
    {
        QPoint first(json["x1"].toInt(), json["y1"].toInt());
        QPoint second(json["x2"].toInt(), json["y2"].toInt());

        emit newPoints(first, second);
    }
    else if(cmd == QLatin1String("wait"))
        emit waitingPlayer();
    else if(cmd == QLatin1String("start"))
        emit startGame();
    else if(cmd == QLatin1String("way"))
    {
        m_curWay = json["way"].toString();
        emit changedWay();
    }
}
