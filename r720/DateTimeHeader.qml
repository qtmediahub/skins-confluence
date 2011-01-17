import QtQuick 1.0
import confluence.r720.components 1.0

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

    Text {
        property string plainCurrentTime: Qt.formatDateTime(root.now, "hh:mm:ss AP")
        property string plainCurrentDateTime: Qt.formatDateTime(root.now, "dddd, MMMM dd, yyyy") + " | " + plainCurrentTime
        id: shadowText
        x: root.showDate ? 41 : 21;
        y: 1
        font.pointSize: 14
        color: "black"
        text: showDate ? plainCurrentDateTime : plainCurrentTime
    }

    Text {
        id: dateTimeText
        x: root.showDate ? 40 : 20
        text: showDate ? currentDateTime() : currentTime()
        font.pointSize: 14
        color: "white"
    }
}

