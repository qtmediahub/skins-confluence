import QtQuick 1.0
import QMLModuleDiscovery 1.0

Item {
    property Item screensaver
    QMLModuleDiscovery {
        id: qmlscreensavers
        path: generalResourcePath + "/screensavers"
    }
    Connections {
        target: backend
        onInputActive:
            !!screensaver ? screensaver.destroy() : undefined
    }
    Connections {
        target: backend
        onInputIdle: {
            if (avPlayer.playing
                || !frontend.isActiveWindow)
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
