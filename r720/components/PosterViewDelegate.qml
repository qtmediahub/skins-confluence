import QtQuick 1.1
import ActionMapper 1.0

Item {
    id: delegateItem
    property variant itemdata : model
    property int frameMargin: 6
    width: PathView.view.delegateWidth
    height: PathView.view.delegateHeight
    clip: true
    scale: PathView.scale ? PathView.scale : 1.0
    opacity : PathView.opacity ? PathView.opacity : 1.0
    z: PathView.z ? PathView.z : 1

    transform: Rotation {
        axis { x: 0; y: 1; z: 0 }
        origin { x: width/2 }
        angle: delegateItem.PathView.rotation ? delegateItem.PathView.rotation : 0
    }

    PathView.onIsCurrentItemChanged: { // QTBUG-16347
        if (PathView.isCurrentItem)
            PathView.view.currentItem = delegateItem
    }

    QtObject {
        id: d
        property string fallbackImagePath: themeResourcePath + "/media/DefaultMusicAlbums.png"
    }

    BorderImage {
        id: border
        anchors.centerIn: parent
        width: backgroundImage.width + frameMargin*2
        height: backgroundImage.height + frameMargin*2
        source: themeResourcePath + "/media/" + "ThumbBorder.png"
        border.left: 10; border.top: 10
        border.right: 10; border.bottom: 10
    }

    Image {
        id: backgroundImage
        source: model.previewUrl ? model.previewUrl : d.fallbackImagePath
        anchors.centerIn: parent
        width: (sourceSize.width > sourceSize.height ? delegateItem.width : (sourceSize.width / sourceSize.height) * delegateItem.width) - frameMargin*2
        height: (sourceSize.width <= sourceSize.height ? delegateItem.height : (sourceSize.height / sourceSize.width) * delegateItem.height) - frameMargin*2
        onStatusChanged:
            if ((status == Image.Error) && (source != d.fallbackImagePath))
                source = d.fallbackImagePath
    }

    Image {
        id: glassOverlay
        anchors.left: backgroundImage.left
        anchors.top: backgroundImage.top
        width: backgroundImage.width * 0.8
        height: backgroundImage.height * 0.6
        source: themeResourcePath + "/media/" + "GlassOverlay.png"
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
                delegateItem.PathView.view.clicked()
                delegateItem.activate()
            } else {
                delegateItem.PathView.view.rightClicked(delegateItem.x + mouseX, delegateItem.y + mouseY)
            }
    }

    Keys.onPressed:
        if (runtime.actionmap.eventMatch(event, ActionMapper.Enter))
           delegateItem.activate()
}

