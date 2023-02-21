#ifndef MODEL_H
#define MODEL_H

#include <QQuickItem>

class Page : public QObject
{
    Q_OBJECT

public:

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




    ~Wall();



};


class Model : public QQuickItem
{
    Q_OBJECT
public:
    Model();

    Q_INVOKABLE QString get_info();

    Q_INVOKABLE int get_vid_count();

    Q_INVOKABLE void show();

     Q_INVOKABLE int get_pages_count(QString vid);

    Q_INVOKABLE bool add_page(QString vid);

     Q_INVOKABLE   bool delete_page(QString vid, int page);

    Q_INVOKABLE bool to_page(QString vid,int page);

private:

    bool add_vid(QString vid);

static QMap<QString,QSharedPointer<Wall>> mdl;

signals:

};




#endif // MODEL_H
