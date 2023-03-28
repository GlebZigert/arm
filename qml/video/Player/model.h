#ifndef MODEL_H
#define MODEL_H

#include <QQuickItem>
#include <QSettings>
#include "StreamerContainer.h"

class Camera : public QObject
{
    Q_OBJECT


public:

    explicit Camera( QObject *parent = nullptr);

    ~Camera();

    int cid;
    bool alarm;
    QString url;


};

class Page : public QObject
{
    Q_OBJECT

private:
    static int uid;



public:


    int scale;
    QString name;

    QMap<int ,QSharedPointer<Camera>> map;
    explicit Page(QString nm="default name");
    explicit Page( QObject *parent = nullptr, QString nm="default name");


    int count(){return map.count();};
    QMap<int ,QSharedPointer<Camera>> get_map(){return map;};

    bool add_camera();

    void next_scale();
    int current_scale(){return scale;};

    void check_the_scale(int id,bool alarm);

    void set_cid_for_uid(int cid, int uid);
    void set_url_for_uid(QString url, int uid);

    int get_uid_at(int i);

    int get_cid_at(int i);

    QString get_url_at(int i);

    bool get_alarm_at(int i);

    void clear_if_not_alarm();

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

    bool contain_page(QString name);

    bool delete_page(int page);

    bool add_camera();

    void next_scale();

    int current_scale();
    ~Wall();

    int getCurrent_page() const;
    void setCurrent_page(int newCurrent_page);

    int get_uid_at(int i);

    int get_cid_at(int i);

    QString get_url_at(int i);

    bool get_alarm_at(int i);

    void check_the_scale(int id,bool alarm);

    void set_cid_for_uid(int cid, int uid);
    void set_url_for_uid(QString url, int uid);

     int current_page;

     void clear_if_not_alarm();


private:




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

    Q_INVOKABLE bool add_page(QString pageName);

    Q_INVOKABLE   bool delete_page(int page);

    Q_INVOKABLE bool to_page(int page);

    Q_INVOKABLE bool to_page(QString name);

    Q_INVOKABLE bool to_next_page();

    Q_INVOKABLE int current_page();

    Q_INVOKABLE bool add_camera();

    Q_INVOKABLE void clear_if_not_alarm();

    Q_INVOKABLE void next_scale();

   Q_INVOKABLE void set_scale(int val);

    Q_INVOKABLE int current_scale();

    Q_INVOKABLE void check_the_scale(int id,bool alarm);

    Q_INVOKABLE int get_uid_at(int i);

    Q_INVOKABLE QList<int> get_cids();

    Q_INVOKABLE int get_cid_at(int i);

    Q_INVOKABLE QString get_url_at(int i);

    Q_INVOKABLE bool get_alarm_at(int i);

    Q_INVOKABLE void set_cid_for_uid(int cid, int uid);

    Q_INVOKABLE void set_url_for_uid(QString url, int uid);

    Q_INVOKABLE QString get_current_page_name();

    void setVid(const QString vid);

    Q_INVOKABLE void save_to_settings();

    void load_from_settings();



private:

  //  QString filename="./settings.txt";

    QString vid;

    static StreamerContainer container;

    bool add_vid();

    static QMap<QString,QSharedPointer<Wall>> mdl;
    static bool fl;

signals:

};

#endif // MODEL_H
