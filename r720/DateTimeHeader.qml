import QtQuick 1.1
import "components/"

Header {
    id: root
    property bool showDate: true
    width: dateTimeText.x + dateTimeText.width + 10
    property variant now

    Timer {
        id: updateTimer
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: { root.now = new Date() }
    }

    function currentTime() {
        var now = new Date();
        return "<span style=\"color:'white'\">" + Qt.formatDateTime(root.now, "hh:mm:ss AP") + "</span>"
    }

    function currentDateTime() {
        return "<span style=\"color:'gray'\">" + Qt.formatDateTime(root.now, "dddd, MMMM dd, yyyy") + " </span> " 
               + "<span style=\"color:'white'\"> | </span>"
               + currentTime()
 
    }

    ConfluenceText {
        id: shadowText

        property string plainCurrentTime: Qt.formatDateTime(root.now, "hh:mm:ss AP")
        property string plainCurrentDateTime: Qt.formatDateTime(root.now, "dddd, MMMM dd, yyyy") + " | " + plainCurrentTime

        x: root.showDate ? 41 : 21;
        y: 1
        color: "white"
        text: showDate ? plainCurrentDateTime : plainCurrentTime
        anchors.verticalCenter: parent.verticalCenter
        animated: false
    }

    ConfluenceText {
        id: dateTimeText
        x: root.showDate ? 40 : 20
        text: showDate ? currentDateTime() : currentTime()
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        animated: false
    }
}

