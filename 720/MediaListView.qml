import QtQuick 1.0
import "../components/"

Item {
    id: root
    property variant engineName
    property variant engineModel
    property variant informationSheetComponent
    property bool hidePreview: false
    property alias rootIndex: sourcesListView.rootIndex

    ContextMenu {
        id: contextMenu
        title: qsTr("Actions")
        ConfluenceAction { id: rootAction; text: qsTr("Go to root"); onActivated: sourcesListView.rootIndex = undefined; }
        ConfluenceAction { id: removeAction; text: qsTr("Remove"); onActivated: engineModel.removeSearchPath(sourcesListView.currentIndex)
                           enabled: sourcesListView.currentItem.itemdata.type == "SearchPath" } 
        ConfluenceAction { id: rescanAction; text: qsTr("Rescan this item"); onActivated: engineModel.rescan(sourcesListView.currentIndex)
                           enabled: sourcesListView.currentItem.itemdata.type == "SearchPath" } 
        ConfluenceAction { id: addSourceAction; text: qsTr("Add Source Path"); onActivated: confluence.showModal(addMediaSourceDialog) }

        actionModel: [rootAction, removeAction, rescanAction, addSourceAction]
    }

    Panel {
        id: sourcesPanel
        x: 60
        y: 80
        width: root.hidePreview ? 950 : 700
        height: 550

        TreeView {
            id: sourcesListView
            anchors.fill: parent;
            treeModel: engineModel
            clip: true
            focus: true;
            onClicked: {
                if (currentItem.itemdata.type == "AddNewSource")
                    confluence.showModal(addMediaSourceDialog)
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
                } else if (itemType == "File") {
                    if (event.key == Qt.Key_I && informationSheetComponent) {
                        var sheet =  confluence.showModal(informationSheetComponent)
                        sheet.currentItem = sourcesListView.currentItem // this is not a binding for lazy loading
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

    Component {
        id: addMediaSourceDialog
        AddMediaSource {
            engineModel: root.engineModel
            title: qsTr("Add %1 source").arg(root.engineName)
            opacity: 0

            onClosed: sourcesListView.forceActiveFocus()
        }
    }
}

