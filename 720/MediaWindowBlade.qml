import QtQuick 1.0
import "../components/"

Blade {
    id: pictureOptions
    clip: false

    property variant actionList

    bladeWidth: banner.x + banner.width + 50
    bladePixmap: themeResourcePath + "/media/HomeBlade.png"

    hoverEnabled: true
    onEntered: state = "open"
    onExited: state = "closed"

    content: Column {
        anchors.fill: parent
        anchors.topMargin: 50
        anchors.leftMargin: closedBladePeek + 5
        anchors.rightMargin: 5

        Image {
            id: banner
            source: themeResourcePath + "/media/Confluence_Logo.png"
            anchors.bottomMargin: 10
        }
        
        ConfluenceListView2 {
            id: listView
            width: parent.width
            height: parent.height - banner.height
            actionModel: pictureOptions.actionList
        }
    }
}

