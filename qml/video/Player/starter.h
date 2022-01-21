#ifndef STARTER_H
#define STARTER_H

#include <QObject>
#include "ffplayer.h"
#include <QImage>
#include <QThread>


class Starter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString URL READ URL WRITE setURL NOTIFY URLChanged)
    Q_PROPERTY(int step READ step WRITE setStep NOTIFY stepChanged)

public:
    explicit Starter(QObject *parent = nullptr);

    FFPlayer *m_player;
    QThread m_thread;



    void run();

    int step() const;
    void setStep(int value);

    QString URL() const;
    void setURL(QString value);

private:
    int m_step;
    QString m_URL;
    int prev;

public slots:
    void new_frame();
    void slot_timeout();

signals:
 void finished();
 void stepChanged(int step);
  void URLChanged(QString URL);
};

#endif // STARTER_H
