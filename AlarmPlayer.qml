import QtQuick 2.11
import QtMultimedia 5.11

Audio {
    id: audio
    property int lastAlarm: -1

    autoPlay: false
    playlist: Playlist {
        id: playlist
        playbackMode: Playlist.CurrentItemInLoop
        // preserve order!
        PlaylistItem { source: "qrc:/sounds/alarm2.mp3"}
        PlaylistItem { source: "qrc:/sounds/alarm2.mp3"}
        PlaylistItem { source: "qrc:/sounds/alarm.mp3"}
    }

    function playAlarm(name) {
        // index is a priority too
        var i = ["lost", "error", "alarm"].indexOf(name)

        if ("" === name) {
            audio.stop()
            lastAlarm = -1
        } else if (i < 0)
            root.log("Unknown alarm name:", name)
        else if (i > lastAlarm) {
            playlist.currentIndex = i
            audio.play()
            lastAlarm = i
        }
    }
}
