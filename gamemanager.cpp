#include "gamemanager.h"
#include <QtDebug>
#include <future>
#include <algorithm>

GameManager::GameManager() : QObject(nullptr)
{
    connect(this, &GameManager::changeSpeed, this, &GameManager::resetRound);
}

GameManager::~GameManager()
{
}

int GameManager::getMode() const
{
    return m_mode;
}

void GameManager::setMode(int mode)
{
    m_mode = static_cast<ModeClass::Mode>(mode);
    emit changeMode();
}

int GameManager::getFirstPlayerWay() const
{
    return m_firstPlayerWay;
}

int GameManager::getSecondPlayerWay() const
{
    return m_secondPlayerWay;
}

void GameManager::setFirstPlayerWay(int way)
{
    m_firstPlayerWay = static_cast<WayClass::Way>(way);
    emit changeWays();
}

void GameManager::setSecondPlayerWay(int way)
{
    m_secondPlayerWay = static_cast<WayClass::Way>(way);
    emit changeWays();
}

WayClass::Way GameManager::getBotStep(const QPoint& start) const
{
    const auto& botWay = m_secondPlayerWay;


    std::future<int> upDistance;
    std::future<int> downDistance;
    std::future<int> leftDistance;
    std::future<int> rightDistance;

    if(botWay != WayClass::Way::Up)
        downDistance = std::async(&GameManager::countDistanceToWall, this, start, WayClass::Way::Down);

    if(botWay != WayClass::Way::Down)
        upDistance = std::async(&GameManager::countDistanceToWall, this, start, WayClass::Way::Up);

    if(botWay != WayClass::Way::Left)
        rightDistance = std::async(&GameManager::countDistanceToWall, this, start, WayClass::Way::Right);

    if(botWay != WayClass::Way::Right)
        leftDistance = std::async(&GameManager::countDistanceToWall, this, start, WayClass::Way::Left);

    QVector<QPair<int, WayClass::Way>> distances(4);

    if(upDistance.valid())
    {
        upDistance.wait();
        distances[0] = qMakePair(upDistance.get(), WayClass::Way::Up);
    }

    if(downDistance.valid())
    {
        downDistance.wait();
        distances[1] = qMakePair(downDistance.get(), WayClass::Way::Down);
    }

    if(leftDistance.valid())
    {
        leftDistance.wait();
        distances[2] = qMakePair(leftDistance.get(), WayClass::Way::Left);
    }

    if(rightDistance.valid())
    {
        rightDistance.wait();
        distances[3] = qMakePair(rightDistance.get(), WayClass::Way::Right);
    }

    auto result = std::max_element(distances.begin(), distances.end(),
    [](QPair<int, WayClass::Way>& first, QPair<int, WayClass::Way>& second) {
        return first.first < second.first;
    });

    return result->second;
}

int GameManager::countDistanceToWall(const QPoint& start, const WayClass::Way direction) const
{
    auto x = start.x();
    auto y = start.y();

    const auto range = MAX_X + MAX_Y;

    int result = 0;
    if(direction == WayClass::Way::Up)
    {
        do
        {
            y += m_speed;
            ++result;

            if(y >= MAX_Y && m_isBotHard)
                y = 0;
            else if(y >= MAX_Y)
                return result;

        }while(m_usedAreas[x][y] == false && result < range);
    }
    else if(direction == WayClass::Way::Down)
    {
        do
        {
            y -= m_speed;
            ++result;

            if(y <= 0 && m_isBotHard)
                y = MAX_Y - m_speed;
            else if(y < 0)
                return result;

        }while(m_usedAreas[x][y] == false && result < range);
    }
    else if(direction == WayClass::Way::Left)
    {
        do
        {
            x -= m_speed;
            ++result;

            if(x <= 0 && m_isBotHard)
                x = MAX_X - m_speed;
            else if(x < 0)
                return result;

        }while(m_usedAreas[x][y] == false && result < range);
    }
    else if(direction == WayClass::Way::Right)
    {
        do
        {
            x += m_speed;
            ++result;

            if(x >= MAX_X && m_isBotHard)
                x = 0;
            else if(x >= MAX_X)
                return result;

        }while(m_usedAreas[x][y] == false && result < range);
    }

    return result;
}

void GameManager::clearArea()
{
    memset(m_usedAreas, false, MAX_X * MAX_Y);
}

void GameManager::resetRound()
{
    clearArea();

    m_firstPlayerWay = WayClass::Right;
    m_secondPlayerWay = WayClass::Left;

    emit resetArea();
}

void GameManager::resetGame()
{
    resetRound();
    m_firstPoints = m_secondPoints = 0;

    emit changeScore();
}

void GameManager::gameIteration(QAbstractSeries *first, QAbstractSeries *second)
{
    if(!first || !second)
        return;

    auto firstXY = static_cast<QXYSeries*>(first);
    auto secondXY = static_cast<QXYSeries*>(second);

    if(!firstXY->count() || !secondXY->count())
    {
        addPoint(0, MAX_Y / 2, firstXY);
        addPoint(MAX_X - m_speed, MAX_Y / 2, secondXY);
        return;
    }

    auto newPointFirst = getNewPoints(first, m_firstPlayerWay);
    if(checkPoints(newPointFirst.x(), newPointFirst.y()))
    {
        addPoint(newPointFirst.x(), newPointFirst.y(), firstXY);
    }
    else
    {
        finishRound(m_secondPoints);
        return;
    }

    if(m_mode == ModeClass::Mode::Bot)
    {
        auto lastPoint = secondXY->at(secondXY->count() - 1);
        setSecondPlayerWay(getBotStep(QPoint(lastPoint.x(), lastPoint.y())));
    }

    auto newPointSecond = getNewPoints(second, m_secondPlayerWay);
    if(checkPoints(newPointSecond.x(), newPointSecond.y()))
    {
        addPoint(newPointSecond.x(), newPointSecond.y(), secondXY);
    }
    else
    {
        finishRound(m_firstPoints);
        return;
    }
}

bool GameManager::checkPoints(const int x, const int y) const
{
    if(x < 0 || x >= MAX_X || y < 0 || y >= MAX_Y)
        return false;

    return m_usedAreas[x][y] == false;
}

void GameManager::addPoint(const int x, const int y, QXYSeries *player)
{
    if(!player || x < 0 || x >= MAX_X || y < 0 || y >= MAX_Y)
        return;

    m_usedAreas[x][y] = true;
    player->append(x,y);
}

void GameManager::finishRound(int &scoreWinner)
{
    m_isRun = false;
    resetRound();
    ++scoreWinner;

    emit changeScore();
    emit updateTimer();
}

QPointF GameManager::getNewPoints(QAbstractSeries *series, int way)
{
    QXYSeries *xySeries = static_cast<QXYSeries*>(series);

    if(!xySeries || !xySeries->count())
        return {0,0};

    auto point = xySeries->at(xySeries->count() - 1);
    auto y = point.y();
    auto x = point.x();

    switch (way)
    {
    case WayClass::Way::Up:
        point.setY(y + m_speed);
        break;

    case WayClass::Way::Right:
        point.setX(x + m_speed);
        break;

    case WayClass::Way::Down:
        point.setY(y - m_speed);
        break;

    case WayClass::Way::Left:
        point.setX(x - m_speed);
        break;

    default: break;
    }

    y = point.y();
    x = point.x();

    if(x >= MAX_X)
    {
        xySeries->append(x + 10, y);
        xySeries->append(x, MAX_Y + 10);
        xySeries->append(-10, MAX_Y + 10);
        xySeries->append(-10, y);

        point.setX(0);
    }
    else if(x < 0)
    {

        xySeries->append(-10, y);
        xySeries->append(-10, MAX_Y + 10);
        xySeries->append(MAX_X + 10, MAX_Y + 10);
        xySeries->append(MAX_X + 10, y);

        point.setX(MAX_X - m_speed);
    }

    if(y >= MAX_Y)
    {
        xySeries->append(x, MAX_Y + 10);
        xySeries->append(MAX_X + 10, MAX_Y + 10);
        xySeries->append(MAX_X + 10, -10);
        xySeries->append(x, -10);

        point.setY(0);
    }
    else if(y < 0)
    {
        xySeries->append(x, -10);
        xySeries->append(MAX_X + 10, -10);
        xySeries->append(MAX_X + 10, MAX_Y + 10);
        xySeries->append(x, MAX_Y + 10);

        point.setY(MAX_Y - m_speed);
    }
    return point;
}
