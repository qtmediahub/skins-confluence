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
        interval: runtime.config.value("splash-time", 2000)
        onTriggered: splash.opacity = 0
    }

    Rectangle {
        id: splash
        width: root.width; height: root.height
        smooth: true
        color: "black"

        Image {
            anchors.centerIn: parent
            source: "../3rdparty/skin.confluence/media/Confluence_Logo.png"
            asynchronous: true
        }

        Behavior on opacity { PropertyAnimation{ duration: 1000 } }
        onOpacityChanged:
            if(splash.opacity == 0)
                root.finished()
    }
}
