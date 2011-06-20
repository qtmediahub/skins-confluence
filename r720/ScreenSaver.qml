import QtQuick 1.1
import File 1.0

Item {
    property Item screensaver
    File {
        id: file
    }
    Connections {
        target: runtime.backend
        onInputActive:
            if (screensaver) screensaver.destroy()
    }
    Connections {
        target: runtime.backend
        onInputIdle: {
            if (avPlayer.playing
                || !runtime.config.isEnabled("screensaver", false)
                || !confluence.active)
                return
            var list = file.findQmlModules(generalResourcePath + "/screensavers")
            var index = Math.floor(Math.random() * list.length)
            var screensaverLoader = Qt.createComponent(list[index])
            if (screensaverLoader.status == Component.Ready) {
                screensaver = screensaverLoader.createObject(confluence)
                screensaver.z = 10000
            } else if (screensaverLoader.status == Component.Error)
                console.log(screensaverLoader.errorString())
        }
    }
}
