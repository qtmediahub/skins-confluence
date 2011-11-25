import QtQuick 1.1

Item {
    id: root

    opacity: 1

    function start() {}

    function play() {
        splash.opacity = 0
    }

    signal finished

    anchors.fill: parent

    Timer {
        id: settleTimer
        interval: 1
        onTriggered: confluenceEntry.load()
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

        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: 1000 }
                PropertyAnimation{ duration: 1000 }
            }
        }
        onOpacityChanged:
            if(splash.opacity < 0.1)
                root.finished()
    }
    Component.onCompleted:
        settleTimer.start()
}
