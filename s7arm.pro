QT += quick widgets  quick quickwidgets  multimedia printsupport

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        printer.cpp
!win32 {
    SOURCES += \
        qml/video/Player/Streamer.cpp \
        qml/video/Player/mythread.cpp \
        qml/video/Player/runner.cpp \
        qml/video/Player/videoplayer.cpp \
        qml/video/Preview/Preview.cpp \
        qml/video/Player/StreamerContainer.cpp \
        qml/video/Player/model.cpp
}
RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    printer.h

!win32 {
    HEADERS += \
        qml/video/Player/Streamer.h \
        qml/video/Player/mythread.h \
        qml/video/Player/runner.h \
        qml/video/Player/videoplayer.h \
        qml/video/Preview/Preview.h \
        qml/video/Player/StreamerContainer.h \
        qml/video/Player/model.h
}
DISTFILES += \
    qml/video/Player/no_signal.jpeg \
    qml/video/no_in_storage.jpeg
!win32 {
    LIBS +=  -lavformat -lswscale  -lavcodec -lavutil
}
