import QtQuick 1.1
import "components/"

Rectangle {
    property bool descriptive: false
    color: "black"
    z: 1000
    width: childrenRect.width; height: childrenRect.height
    anchors { top: dateTimeHeader.bottom; right: confluence.right }
    ConfluenceText {
        text: (descriptive ? "Max FPS is: " : "") + runtime.frontend.framerateCap
        font.pixelSize: 60
    }
}
