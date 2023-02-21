#ifndef MODEL_H
#define MODEL_H

#include <QQuickItem>

class Camera : public QObject
{
    Q_OBJECT


public:

    explicit Camera( QObject *parent = nullptr);

    ~Camera();
};

class Page : public QObject
{
    Q_OBJECT



public:

    QMap<int ,QSharedPointer<Camera>> list;

    explicit Page( QObject *parent = nullptr);

    ~Page();
};

class Wall : public QObject
{
    Q_OBJECT

public:

    explicit Wall( QObject *parent = nullptr);

    QList<QSharedPointer<Page>> list;

    int count(){return list.count();};

    bool add_page(QSharedPointer<Page>);

    bool delete_page(int page);

    bool add_camera(int page);

    ~Wall();



};


class Model : public QQuickItem
{
    Q_OBJECT

     Q_PROPERTY(QString vid WRITE setVid)

public:
    Model();

    Q_INVOKABLE QString get_info();

    Q_INVOKABLE int get_vid_count();

    Q_INVOKABLE void show();

    Q_INVOKABLE int get_pages_count();

    Q_INVOKABLE bool add_page();

    Q_INVOKABLE   bool delete_page(int page);

    Q_INVOKABLE bool to_page(int page);

    Q_INVOKABLE bool add_camera(int page);

    void setVid(const QString vid);

private:

    QString vid;

    bool add_vid();

    static QMap<QString,QSharedPointer<Wall>> mdl;

signals:

};

#endif // MODEL_H
