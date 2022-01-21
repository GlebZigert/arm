#include "clockcircle.h"
#include <vlc/vlc.h>

ClockCircle::ClockCircle(QQuickItem *parent) :
    QQuickPaintedItem(parent),
    m_backgroundColor(Qt::white),
    m_borderActiveColor(Qt::blue),
    m_borderNonActiveColor(Qt::gray),
    m_angle(0),
    m_circleTime(QTime(0,0,0,0))
{
    internalTimer = new QTimer(this);   // Инициализируем таймер
    /* А также подключаем сигнал от таймера к лямбда функции
     * Структура лямбда-функции [объект](аргументы){тело}
     * */
    connect(internalTimer, &QTimer::timeout, [=](){
        setAngle(angle() - 0.3);                    // поворот определяется в градусах.
        setCircleTime(circleTime().addMSecs(50));   // Добавляем к текущему времени 50 милисекунд
        update();                                   // Перерисовываем объект
    });
}

void ClockCircle::paint(QPainter *painter)
{
    // Отрисовка объекта
    QBrush  brush(m_backgroundColor);               // выбираем цвет фона, ...
    QBrush  brushActive(m_borderActiveColor);       // активный цвет ободка, ...
    QBrush  brushNonActive(m_borderNonActiveColor); // не активный цвет ободка

    painter->setPen(Qt::NoPen);                             // Убираем абрис
    painter->setRenderHints(QPainter::Antialiasing, true);  // Включаем сглаживание

    painter->setBrush(brushNonActive);                          // Отрисовываем самый нижний фон в виде круга
    painter->drawEllipse(boundingRect().adjusted(1,1,-1,-1));   // с подгонкой под текущие размеры, которые
                                                                // будут определяться в QML-слое.
                                                                // Это будет не активный фон ободка

    // Прогресс бар будет формироваться с помощью отрисовки Pie графика
    painter->setBrush(brushActive);                         // Отрисовываем активный фон ободка в зависимости от угла поворота
    painter->drawPie(boundingRect().adjusted(1,1,-1,-1),    // с подгонкой под размеры в QML слое
                     90*16,         // Стартовая точка
                     m_angle*16);   // угол поворота, до которого нужно отрисовать объект

    painter->setBrush(brush);       // основной фон таймера, перекрытием которого поверх остальных
    painter->drawEllipse(boundingRect().adjusted(10,10,-10,-10));   // будет сформирован ободок (он же прогресс бар)
}

void ClockCircle::clear()
{
    setCircleTime(QTime(0,0,0,0));  // Очищаем время
    setAngle(0);                    // Выставляем поворот на ноль
    update();                       // Обновляем объект
    emit cleared();                 // ИСпускаем сигнал очистки
}

void ClockCircle::start()
{
    internalTimer->start(50);       // Запускаем таймер с шагом 50 мс
}

void ClockCircle::stop()
{
    internalTimer->stop();          // Останавливаем таймер
}

QString ClockCircle::name() const
{
    return m_name;
}

QColor ClockCircle::backgroundColor() const
{
    return m_backgroundColor;
}

QColor ClockCircle::borderActiveColor() const
{
    return m_borderActiveColor;
}

QColor ClockCircle::borderNonActiveColor() const
{
    return m_borderNonActiveColor;
}

qreal ClockCircle::angle() const
{
    return m_angle;
}

QTime ClockCircle::circleTime() const
{
    return m_circleTime;
}

void ClockCircle::setName(const QString name)
{
    if (m_name == name)
        return;

    m_name = name;
    emit nameChanged(name);
}

void ClockCircle::setBackgroundColor(const QColor backgroundColor)
{
    if (m_backgroundColor == backgroundColor)
        return;

    m_backgroundColor = backgroundColor;
    emit backgroundColorChanged(backgroundColor);
}

void ClockCircle::setBorderActiveColor(const QColor borderActiveColor)
{
    if (m_borderActiveColor == borderActiveColor)
        return;

    m_borderActiveColor = borderActiveColor;
    emit borderActiveColorChanged(borderActiveColor);
}

void ClockCircle::setBorderNonActiveColor(const QColor borderNonActiveColor)
{
    if (m_borderNonActiveColor == borderNonActiveColor)
        return;

    m_borderNonActiveColor = borderNonActiveColor;
    emit borderNonActiveColorChanged(borderNonActiveColor);
}

void ClockCircle::setAngle(const qreal angle)
{
    if (m_angle == angle)
        return;

    m_angle = angle;

    /* Данное добавление сделано для того,
     * чтобы обнулить поворот при достижении таймером
     * 60 секунд
     * */
    if(m_angle <= -360) m_angle = 0;
    emit angleChanged(m_angle);
}

void ClockCircle::setCircleTime(const QTime circleTime)
{
    if (m_circleTime == circleTime)
        return;

    m_circleTime = circleTime;
    emit circleTimeChanged(circleTime);
}
