#include "barcode.h"

#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;


    qmlRegisterType<bcr::Barcode>("org.iplusbot.Qt", 1,  0, "Barcode");

//    bcr::Barcode barcode;
//    engine.rootContext()->setContextProperty("bcr", &barcode);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;


    return app.exec();
}
