#include "gamemanager.h"
#include <QtCharts/QXYSeries>

GameManager::GameManager()
{
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

void GameManager::resetRound()
{
    m_usedAreas.clear();

    m_firstPlayerWay = WayClass::Right;
    m_secondPlayerWay = WayClass::Left;
}

void GameManager::resetGame()
{
    resetRound();
    m_firstPoints = m_secondPoints = 0;
    emit changeScore();
}

bool GameManager::updatePoints(QAbstractSeries *series, int way)
{
    QXYSeries *xySeries = static_cast<QXYSeries*>(series);

    if(!xySeries || !xySeries->count())
        return true;

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

    if(x > MAX_X)
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

        point.setX(MAX_X);
    }

    if(y > MAX_Y)
    {
        xySeries->append(x , MAX_Y + 10);
        xySeries->append(MAX_X + 10, MAX_Y + 10);
        xySeries->append(MAX_X + 10, -10);
        xySeries->append(x, -10);

        point.setY(0);
    }
    else if(y < 0)
    {
        xySeries->append(x , -10);
        xySeries->append(MAX_X + 10, -10);
        xySeries->append(MAX_X + 10, MAX_Y + 10);
        xySeries->append(x, MAX_Y + 10);

        point.setY(MAX_Y);
    }

    if(m_usedAreas.contains(qMakePair(point.x(), point.y())))
        return false;

    xySeries->append(point);
    m_usedAreas.insert(qMakePair(point.x(), point.y()));

    return true;
}