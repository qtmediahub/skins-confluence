import QtQuick 1.0

FocusScope {
    id: root
    width: actionListView.width
    height: glassTitleBar.height + actionListView.height + 10

    property alias model: actionListView.model
    property alias title : titleBarText.text
    signal opened
    signal closed

    opacity: 0

    function close() {
        opacity = 0
        root.closed()
    }

    function open() {
        opacity = 1;
        root.opened()
    }

    Behavior on opacity {
        NumberAnimation { }
    }

    BorderImage {
        id: panel
        source: themeResourcePath + "/media/OverlayDialogBackground.png"
        border { top: 20; left: 20; bottom: 20; right: 20; }
        anchors.fill: parent
    }

    ActionListView {
        id: actionListView
        focus: true
        hideItemBackground: true
        anchors.top: glassTitleBar.bottom
        anchors.left: panel.left
        anchors.bottomMargin : panel.border.bottom
        onActivated: root.close()
    }

    Image {
        id: glassTitleBar
        source: themeResourcePath + "/media/GlassTitleBar.png"
        anchors.top: panel.top
        width: panel.width
        height: titleBarText.height + 10

        Text {
            id: titleBarText
            anchors.centerIn: parent
            color: "white"
            text: "Default dialog title"
            font.bold: true
            font.pointSize: 14
        }
    }

    Image {
        id: closeButton
        source: themeResourcePath + "/media/" + (closeButtonMouseArea.pressed ? "DialogCloseButton-focus.png" : "DialogCloseButton.png")
        anchors.top: panel.top
        anchors.right: panel.right
        anchors { rightMargin: 10; topMargin: 5; }
        MouseArea {
            id: closeButtonMouseArea
            anchors.fill: parent;

            onClicked: root.close();
        }
    }

    Keys.onEscapePressed: root.close()
}

