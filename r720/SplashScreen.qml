import QtQuick 1.1

Item {
    id: root

    opacity: 1

    function start() {
        splashDelay.start()
    }

    function play() {}

    signal finished

    anchors.fill: parent

    onWidthChanged: {
        settleTimer.start()
    }

    Timer {
        id: splashDelay
        interval: runtime.config.value("splash-lead-time", 500)
        onTriggered: confluenceEntry.load()
    }

    Timer {
        id: settleTimer
        interval: 1000
        onTriggered: splash.opacity = 0
    }

    Image {
        id: splash
        width: root.width; height: root.height
        smooth: true
        fillMode: Image.PreserveAspectCrop
        source: "../3rdparty/splash/splash.jpg"
        Behavior on opacity { PropertyAnimation{ duration: 1000 } }
        onOpacityChanged:
            if(splash.opacity == 0)
                root.finished()
    }
}
