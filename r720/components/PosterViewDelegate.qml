import QtQuick 1.0
import ActionMapper 1.0

Item {
    id: delegateItem
    property variant itemdata : model
    width: PathView.view.delegateWidth
    height: PathView.view.delegateHeight
    clip: true
    scale: PathView.scale ? PathView.scale : 1.0
    opacity : PathView.opacity ? PathView.opacity : 1.0
    z: PathView.z ? PathView.z : 1

    transform: Rotation {
        axis { x: 0; y: 1; z: 0 }
        origin { x: width/2 }
        angle: PathView.rotation ? PathView.rotation : 0
    }

    PathView.onIsCurrentItemChanged: { // QTBUG-16347
        if (PathView.isCurrentItem)
            PathView.view.currentItem = delegateItem
    }

    BorderImage {
        id: border
        anchors.fill: parent
        source: themeResourcePath + "/media/" + "ThumbBorder.png"
        border.left: 10; border.top: 10
        border.right: 10; border.bottom: 10

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: model.previewUrl ? model.previewUrl : ""
            anchors.margins: 6

            Image {
                id: glassOverlay
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width*0.7
                height: parent.height*0.6
                source: themeResourcePath + "/media/" + "GlassOverlay.png"
            }
        }
    }

    function activate()
    {
        var visualDataModel = PathView.view.model
        if (model.hasModelChildren) {
            visualDataModel.rootIndex = visualDataModel.modelIndex(index)
            PathView.view.rootIndexChanged() // Fire signals of aliases manually, QTBUG-14089
            visualDataModel.model.layoutChanged() // Workaround for QTBUG-16366
        } else {
            PathView.view.currentIndex = index;
            PathView.view.activated()
        }
    }

    MouseArea {
        anchors.fill: parent;
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked:
            if (mouse.button == Qt.LeftButton) {
                PathView.view.clicked()
                delegateItem.activate()
            } else {
                PathView.view.rightClicked(delegateItem.x + mouseX, delegateItem.y + mouseY)
            }
    }

    Keys.onPressed:
        if (actionmap.eventMatch(event, ActionMapper.Enter))
            delegateItem.activate()
        else if (actionmap.eventMatch(event, ActionMapper.Context))
            PathView.view.rightClicked(delegateItem.x + delegateItem.width/2, delegateItem.y + delegateItem.height/2)
}

