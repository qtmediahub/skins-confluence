import QtQuick 1.0
import "../components/"

Item {
    id: root
    property variant engineName
    property variant engineModel
    property variant informationSheetComponent
    property bool hidePreview: false
    property alias rootIndex: sourcesListView.rootIndex

    signal itemTriggered(variant itemData)

    anchors.centerIn: parent

    TreeView {
        id: sourcesListView
        anchors.fill: parent;
        treeModel: engineModel
        clip: true
        focus: true;
        onClicked: {
            if (currentItem.itemdata.type == "AddNewSource")
                confluence.showModal(addMediaSourceDialog)
            else {
                root.itemTriggered(currentItem.itemdata)
            }
        }
        Keys.onPressed: {
            var itemType = sourcesListView.currentItem.itemdata.type
            if (itemType == "SearchPath") {
                if (event.key == Qt.Key_Delete) {
                    treeModel.removeSearchPath(currentIndex)
                    event.accepted = true
                }
            } else if (itemType == "File") {
                if (event.key == Qt.Key_Return) {
                    root.itemTriggered(currentItem.itemdata)
                    event.accepted = true
                }
            }
        }
    }
}

