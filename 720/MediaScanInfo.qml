import QtQuick 1.0

BorderImage {
    id: root
    property string currentPath
    clip: true
    border { top: 20; right: 20; bottom: 20; left: 2 }
    source: themeResourcePath + "/media/InfoMessagePanel.png"
    width: 350
    height: currentPathText.height * 4

    state: "hidden"

    states: [
        State {
            name: "visible"
            when: currentPathText.text != ""
            PropertyChanges { target: root; y: 0 }
        },
        State {
            name: "hidden"
            when: currentPathText.text == ""
            PropertyChanges { target: root; y: -root.height }
        }
            ]
    
    transitions:
        Transition {
            NumberAnimation { target: root; property: "y"; duration: confluenceAnimationDuration; easing.type: confluenceEasingCurve }
        }

    Column {
        id: column
        spacing: 5
        anchors.fill: parent
        anchors { topMargin: border.top; leftMargin: 30; rightMargin: root.border.right; bottomMargin: root.border.bottom }
        Text {
            text: qsTr("Loading media info from files...")
            color: "magenta"
        }
        Text {
            id: currentPathText
            color: "white"
            text: root.currentPath
        }
    }
}

