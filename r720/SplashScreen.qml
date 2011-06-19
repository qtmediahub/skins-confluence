import QtQuick 1.1

Item {
    id: root

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
        onTriggered:
            confluenceEntry.load()
    }

    Timer {
        id: settleTimer
        interval: 1000
        onTriggered:
            splash.x = -splash.width
    }

    Image {
        id: splash
        width: root.width; height: root.height
        smooth: true
        fillMode: Image.PreserveAspectCrop
        source: "../3rdparty/splash/splash.jpg"
        Behavior on x { PropertyAnimation{ duration: 1000 } }
        onXChanged:
            if(x == -width)
                root.finished()
    }
}
