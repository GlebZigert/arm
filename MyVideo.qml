import QtQuick 2.0

Loader {
    property int panePosition
    source: switch (userSettings.videoMode) {
            case 1: return "Video.qml"
            case 2: return "VideoRB.qml"
            default: return "Video.qml"
    }
    onPanePositionChanged: root.videoPane=panePosition
}
