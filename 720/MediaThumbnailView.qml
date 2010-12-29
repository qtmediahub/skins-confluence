import QtQuick 1.0
import "../components/"

Item {
    id: root
    property variant engineName
    property variant engineModel
    property variant informationSheet
    property bool hidePreview: false
    property alias rootIndex: sourcesListView.rootIndex

    signal itemTriggered(variant itemData)

    ContextMenu {
        id: contextMenu
        title: qsTr("Actions")
        ConfluenceAction { id: rootAction; text: qsTr("Go to root"); onActivated: sourcesListView.rootIndex = undefined; }
        ConfluenceAction { id: removeAction; text: qsTr("Remove"); onActivated: engineModel.removeSearchPath(sourcesListView.currentIndex)
                           enabled: sourcesListView.currentItem.itemdata.type == "SearchPath" } 
        ConfluenceAction { id: informationAction; text: qsTr("Show Information"); onActivated: root.showInformationSheet()
                           enabled: sourcesListView.currentItem.itemdata.type == "File" } 
        ConfluenceAction { id: rescanAction; text: qsTr("Rescan this item"); onActivated: engineModel.rescan(sourcesListView.currentIndex)
                           enabled: sourcesListView.currentItem.itemdata.type == "SearchPath" } 
        ConfluenceAction { id: addSourceAction; text: qsTr("Add Source Path"); onActivated: confluence.showModal(addMediaSourceDialog) }

        model: [rootAction, removeAction, informationAction, rescanAction, addSourceAction]
    }

    function showInformationSheet() {
        if (!informationSheet)
            return
        confluence.showModal(informationSheet)
        informationSheet.currentItem = sourcesListView.currentItem
    }

    Panel {
        id: sourcesPanel
        x: 60
        y: 80
        width: root.hidePreview ? 950 : 700
        height: 550

        ConfluenceGridView {
            id: sourcesListView
            anchors.fill: parent;
            treeModel: engineModel
            clip: true
            focus: true;
            onClicked: {
                if (currentItem.itemdata.type == "AddNewSource")
                    confluence.showModal(addMediaSourceDialog)
                else
                    root.itemTriggered(currentItem.itemdata)
            }
            onRightClicked: {
                var scenePos = sourcesPanel.mapToItem(null, mouseX, mouseY)
                confluence.showContextMenu(contextMenu, scenePos.x, scenePos.y)
            }
            Keys.onPressed: {
                var itemType = sourcesListView.currentItem.itemdata.type
                if (itemType == "SearchPath") {
                    if (event.key == Qt.Key_Delete) {
                        treeModel.removeSearchPath(currentIndex)
                        event.accepted = true
                    }
                }
            }
        }
    }

    Item {
        id: sourceArtWindow
        anchors.left: sourcesPanel.right;
        anchors.leftMargin: 65;
        anchors.bottom: sourcesPanel.bottom;
        opacity: root.hidePreview ? 0 : 1

        width: sourcesArt.width
        height: sourcesArt.height

        ImageCrossFader {
            id: sourcesArt
            anchors.fill: parent;

            width: sourcesListView.currentItem ? sourcesListView.currentItem.itemdata.previewWidth : 0
            height: sourcesListView.currentItem ? sourcesListView.currentItem.itemdata.previewHeight : 0
            source: sourcesListView.currentItem ? sourcesListView.currentItem.itemdata.previewUrl : ""
        }
    }

    AddMediaSourceDialog {
        id: addMediaSourceDialog
        engineModel: root.engineModel
        title: qsTr("Add %1 source").arg(root.engineName)
        opacity: 0

        onClosed: sourcesListView.forceActiveFocus()
    }
}

