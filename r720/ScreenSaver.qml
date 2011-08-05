import QtQuick 1.1

Item {
    property Item screensaver
    Connections {
        target: runtime.window
        onInputActive:
            if (screensaver) screensaver.destroy()
    }
    Connections {
        target: runtime.window
        onInputIdle: {
            if (avPlayer.playing
                || !runtime.config.isEnabled("screensaver", false)
                || !Qt.application.active)
                return
            var list = runtime.file.findQmlModules(runtime.skin.path + "/screensavers")
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
