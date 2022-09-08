#include "printer.h"
#include <QtPrintSupport/QPrinter>
#include <QPainter>
#include <QtPrintSupport/QPrintDialog>
#include <QPixmap>
#include <QImage>
#include <QDebug>

Printer::Printer() {

}

void Printer::print(QVariant data, qreal resolution) {
    QImage img = qvariant_cast<QImage>(data);
    QPrinter printer(QPrinter::HighResolution);
    printer.setPageOrientation(img.width() < img.height() ? QPageLayout::Portrait : QPageLayout::Landscape);
    qreal resolutionFactor = printer.resolution() / resolution;
    //qDebug() << "Screen resolution: " << resolution << ", Print: " << printer.resolution();
    QPrintDialog dlg(&printer, nullptr);
    if(dlg.exec() == QDialog::Accepted) {
          QPainter painter(&printer);
          painter.scale(resolutionFactor, resolutionFactor);
          painter.drawImage(QPoint(0,0),img);
          painter.end();
    }
}
