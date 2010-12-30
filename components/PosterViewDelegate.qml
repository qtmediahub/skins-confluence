import QtQuick 1.0

Item {
    id: delegateItem
    property variant itemdata : model
    width: PathView.view.delegateWidth
    height: PathView.view.delegateHeight
    clip: true
    scale: PathView.scale
    opacity : PathView.opacity
    z: PathView.z

    PathView.onIsCurrentItemChanged: { // QTBUG-16347
        if (PathView.isCurrentItem)
            PathView.view.currentItem = delegateItem
    }

    Keys.onReturnPressed: delegateItem.trigger()

    function trigger()
    {
        var visualDataModel = PathView.view.model
        if (model.hasModelChildren) {
            visualDataModel.rootIndex = visualDataModel.modelIndex(index)
            visualDataModel.model.layoutChanged() // Workaround for QTBUG-16366
        } else {
            PathView.view.currentIndex = index;
            PathView.view.clicked(filePath)
        }
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

    MouseArea {
        anchors.fill: parent;

        onClicked:
            delegateItem.trigger()
    }
}

