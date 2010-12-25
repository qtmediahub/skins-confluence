import QtQuick 1.0

Item {
    id: delegateItem
    property variant itemdata : model
    width: sourceImg.width
    height: sourceImg.height

    Image {
        id: sourceImg
        width: 142
        height: 142
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
        z: 1 // ensure it is above the background
        source: model.previewUrl
    }

    Text {
        anchors.bottom: sourceImg.bottom
        z: 2 // ensure it is above the background
        width:  sourceImg.width
        text: model.display
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 10
        font.weight: Font.Light
        color: "white"
        visible: model.type != "File"
    }

    function trigger() {
        var visualDataModel = GridView.view.model
        if (model.hasModelChildren) {
            visualDataModel.rootIndex = visualDataModel.modelIndex(index)
            GridView.view.rootIndexChanged();
        } else {
            GridView.view.currentIndex = index;
            GridView.view.clicked()
        }
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true
        onEntered: {
            GridView.view.currentIndex = index
            currentItem.forceActiveFocus()
        }
        onClicked: {
            delegateItem.trigger()
        }
    }

    Keys.onReturnPressed: delegateItem.trigger()
}

