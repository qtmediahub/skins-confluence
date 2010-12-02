import QtQuick 1.0
import "components"

Dialog {
    id: root
    Engine { name: qsTr("About"); role: "about"; visualElement: root; }

    Flow {
        anchors.centerIn: parent
        //width: childrenRect.width; height: childrenRect.height
        flow:  Flow.TopToBottom
        Item {
            anchors.right: parent.right
            width: childrenRect.width; height: childrenRect.height
            ConfluenceText { id: confTxt; text: qsTr("All resources and style from ") }
            Image {
                anchors { left: confTxt.right; verticalCenter: confTxt.verticalCenter }
                source: themeResourcePath + "/media/Confluence_Logo.png"
            }
        }
        Item {
            anchors.right: parent.right
            width: childrenRect.width; height: childrenRect.height
            ConfluenceText { id: xbmcTxt; text: qsTr("Inspired by ") }
            Image {
                anchors { left: xbmcTxt.right; verticalCenter: xbmcTxt.verticalCenter }
                source: themeResourcePath + "/media/XBMC_Logo.png"
            }
        }
        ConfluenceText { anchors.horizontalCenter: parent.horizontalCenter; text: "http://xbmc.org/"}
        ConfluenceText { anchors.horizontalCenter: parent.horizontalCenter; text: "QtMediaCenter is hosted at http://gitorious.org/qtmediahub"}
    }
}
