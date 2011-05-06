import QtQuick 1.1
import QMLModuleDiscovery 1.0

Item {
    property Item screensaver
    QMLModuleDiscovery {
        id: qmlscreensavers
        path: generalResourcePath + "/screensavers"
    }
    Connections {
        target: runtime.backend
        onInputActive:
            !!screensaver ? screensaver.destroy() : undefined
    }
    Connections {
        target: runtime.backend
        onInputIdle: {
            if (avPlayer.playing
                || !runtime.config.isEnabled("screensaver", false)
                || !Qt.application.active)
                //bail
                return
            var list = qmlscreensavers.modules
            var index = Math.floor(Math.random() * list.length)
            var screensaverLoader = Qt.createComponent(list[index])
            if (screensaverLoader.status == Component.Ready) {
                screensaver = screensaverLoader.createObject(confluence)
                screensaver.z = 10000
            }
            else if (screensaverLoader.status == Component.Error)
                console.log(screensaverLoader.errorString())
        }
    }
}
