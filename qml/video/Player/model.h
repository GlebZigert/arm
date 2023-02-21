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

private:
      static int uid;
     QMap<int ,QSharedPointer<Camera>> map;

public:



    explicit Page( QObject *parent = nullptr);


        int count(){return map.count();};
        QMap<int ,QSharedPointer<Camera>> get_map(){return map;};
         bool add_camera();

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

    bool add_camera();



    ~Wall();

     int getCurrent_page() const;
     void setCurrent_page(int newCurrent_page);

private:
     int current_page;



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

    Q_INVOKABLE bool add_camera();

    void setVid(const QString vid);

private:



    QString vid;



    bool add_vid();

    static QMap<QString,QSharedPointer<Wall>> mdl;

signals:

};

#endif // MODEL_H
