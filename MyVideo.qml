import QtQuick 2.0

Loader {
    property int panePosition
    source: switch (userSettings.videoMode) {
            case 1: return "OnlyStorageAlarm.qml"//"Video.qml"
         //   case 2: return "OnlyStorageAlarm.qml"
           case 2: return "VideoRB.qml"
            default: return "OnlyStorageAlarm.qml"// "Video.qml"
    }
    onPanePositionChanged: root.videoPane=panePosition
}
