#include <QApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QNetworkProxy>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    //QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Direct3D12);
    //QCoreApplication::setAttribute(Qt::ApplicationAttribute::AA_UseOpenGLES, true);
    //QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL, true);

    //QGuiApplication app(argc, argv);
    QApplication app(argc, argv);

    // fix FileDialog QML errors
    app.setOrganizationName("Start7");
    app.setOrganizationDomain("OrgDom");
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
    engine.load(url);

    return app.exec();
}

