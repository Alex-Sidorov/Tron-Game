#ifndef GAMEMANAGER_H
#define GAMEMANAGER_H

#include <QObject>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QXYSeries>
#include <QSet>
#include <QPair>

QT_CHARTS_USE_NAMESPACE

class ModeClass : public QObject
{
    Q_OBJECT

public:
    explicit ModeClass(){}

    enum Mode
    {
        None = -1,
        Friend,
        Bot,
        Online
    };

    Q_ENUM(Mode)
};

class WayClass : public QObject
{
    Q_OBJECT

public:

    enum Way
    {
        Up,
        Right,
        Down,
        Left
    };

    Q_ENUM(Way)
};

class GameManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int MAX_X MEMBER MAX_X CONSTANT)
    Q_PROPERTY(int MAX_Y MEMBER MAX_Y CONSTANT)

    Q_PROPERTY(int mode READ getMode WRITE setMode NOTIFY changeMode)

    Q_PROPERTY(qreal speed MEMBER m_speed NOTIFY changeSpeed)

    Q_PROPERTY(int firstPoints MEMBER m_firstPoints NOTIFY changeScore)
    Q_PROPERTY(int secondPoints MEMBER m_secondPoints NOTIFY changeScore)

    Q_PROPERTY(int firstWay READ getFirstPlayerWay WRITE setFirstPlayerWay NOTIFY changeWays)
    Q_PROPERTY(int secondWay READ getSecondPlayerWay WRITE setSecondPlayerWay NOTIFY changeWays)

    Q_PROPERTY(bool isRun MEMBER m_isRun NOTIFY updateTimer)

    static const int MAX_X = 200;
    static const int MAX_Y = 200;

public:
    GameManager();
    virtual ~GameManager();

    int getMode() const;
    void setMode(int mode);

    int getFirstPlayerWay() const;
    int getSecondPlayerWay() const;

    void setFirstPlayerWay(int way);
    void setSecondPlayerWay(int way);

    Q_INVOKABLE void resetRound();
    Q_INVOKABLE void resetGame();

    Q_INVOKABLE void gameIteration(QAbstractSeries *first, QAbstractSeries *second);

signals:
    void changeMode();
    void changeSpeed();
    void changeWays();
    void changeScore();
    void resetArea();
    void updateTimer();

private:
    bool m_usedAreas[MAX_X][MAX_Y];

    qreal m_speed = 1;

    ModeClass::Mode m_mode = ModeClass::Mode::None;

    int m_firstPoints = 0;
    int m_secondPoints = 0;

    WayClass::Way m_firstPlayerWay;
    WayClass::Way m_secondPlayerWay;

    bool m_isRun = false;

    void clearArea();
    bool checkPoints(const int x, const int y) const;
    QPointF getNewPoints(QAbstractSeries *series, int way);
    void addPoint(const int x, const int y, QXYSeries* player);
    void finishRound(int& scoreWinner);
};

#endif // GAMEMANAGER_H
