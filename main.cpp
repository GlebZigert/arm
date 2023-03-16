#include <QApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QNetworkProxy>
#include <QQuickWindow>
#include "printer.h"

#ifndef WIN32
#include "qml/video/Player/videoplayer.h"
#include "qml/video/Player/model.h"
#include "qml/video/Preview/Preview.h"
#include "qml/video/Player/runner.h"
#endif


//#include <imagemaker.h>

int main(int argc, char *argv[])
{
    // disable debug output
    #ifdef QT_NO_DEBUG
    //qputenv("QT_LOGGING_RULES", "*.debug=false;qml=false");
    #endif

    //Глеб - регистрирую свои классы
    #ifndef WIN32
    qmlRegisterType<Preview>("Preview",1,0,"Preview");
    qmlRegisterType<VideoPlayer>("VideoPlayer",1,0,"VideoPlayer");
    qmlRegisterType<Model>("Model",1,0,"Model");

    Runner::declareQML();
    #endif


    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    //QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Direct3D12);
    //QCoreApplication::setAttribute(Qt::ApplicationAttribute::AA_UseOpenGLES, true);
    //QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL, true);

    //QGuiApplication app(argc, argv);
    QApplication app(argc, argv);

    // fix FileDialog QML errors
    app.setOrganizationName("Start-7");
    app.setApplicationName("Rif-7");
    /*QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("192.168.0.1");
    proxy.setPort(3128);
    QNetworkProxy::setApplicationProxy(proxy);*/
    QNetworkProxy::setApplicationProxy(QNetworkProxy(QNetworkProxy::NoProxy));

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());

    // for printing
    Printer *printer = new Printer;
    engine.rootContext()->setContextProperty("printer", printer);

    engine.load(url);

    return app.exec();
}

