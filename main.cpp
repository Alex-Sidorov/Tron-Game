#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "gamemanager.h"
#include "network/client.h"


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QApplication app(argc, argv);

    qmlRegisterType<ModeClass>("Mode", 1, 0, "Mode");
    qmlRegisterType<WayClass>("Way", 1, 0, "Way");

    GameManager manager;
    Client client;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QLatin1String("gameManager"), &manager);
    engine.rootContext()->setContextProperty(QLatin1String("client"), &client);


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
