#ifndef Preview_H
#define Preview_H

#include <QtQuick/QQuickPaintedItem>
#include <QColor>
#include <QBrush>
#include <QPen>
#include <QPainter>
#include <QTime>
#include <QTimer>
#include <QNetworkReply>
#include <QSharedPointer>

class Preview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QString url READ readURL WRITE setURL NOTIFY URLChanged)

    /*
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor borderActiveColor READ borderActiveColor WRITE setBorderActiveColor NOTIFY borderActiveColorChanged)
    Q_PROPERTY(QColor borderNonActiveColor READ borderNonActiveColor WRITE setBorderNonActiveColor NOTIFY borderNonActiveColorChanged)
    Q_PROPERTY(qreal angle READ angle WRITE setAngle NOTIFY angleChanged)
    Q_PROPERTY(QTime circleTime READ circleTime WRITE setCircleTime NOTIFY circleTimeChanged)
    */

public:

    QImage current;
    QSharedPointer<QNetworkAccessManager> manager;
    explicit Preview(QQuickItem *parent = 0);

    QString m_URL;
    QTimer *timer;



    void paint(QPainter *painter) override; // Переопределяем метод, в котором будет отрисовываться наш объект


/*
    // Методы, доступные из QML для ...
    Q_INVOKABLE void clear();   // ... очистки времени, ...
    Q_INVOKABLE void start();   // ... запуска таймера, ...
    Q_INVOKABLE void stop();    // ... остановки таймера, ...

    QString name() const;
    QColor backgroundColor() const;
    QColor borderActiveColor() const;
    QColor borderNonActiveColor() const;
    qreal angle() const;
    QTime circleTime() const;
*/


    QString readURL() const;
    void setURL(const QString &URL);

public slots:

    void replyFinished(QNetworkReply* reply);
    void onWidthChanged();
    void onheightChanged();
    void onTimer();

    /*
    void setName(const QString name);
    void setBackgroundColor(const QColor backgroundColor);
    void setBorderActiveColor(const QColor borderActiveColor);
    void setBorderNonActiveColor(const QColor borderNonActiveColor);
    void setAngle(const qreal angle);
    void setCircleTime(const QTime circleTime);
    */

signals:
     void URLChanged(const QString URL);
 /*
    void cleared();

    void nameChanged(const QString name);
    void backgroundColorChanged(const QColor backgroundColor);
    void borderActiveColorChanged(const QColor borderActiveColor);
    void borderNonActiveColorChanged(const QColor borderNonActiveColor);
    void angleChanged(const qreal angle);
    void circleTimeChanged(const QTime circleTime);
*/
private:
    /*
    QString     m_name;                 // Название объекта, по большей части до кучи добавлено
    QColor      m_backgroundColor;      // Основной цвет фона
    QColor      m_borderActiveColor;    // Цвет ободка, заполняющий при прогрессе ободок таймера
    QColor      m_borderNonActiveColor; // Цвет ободка фоновый
    qreal       m_angle;                // Угол поворота графика типа пирог, будет формировать прогресс на ободке
    QTime       m_circleTime;           // Текущее время таймера

    QTimer      *internalTimer;         // Таймер, по которому будет изменяться время
    */
};

#endif // Preview_H
