import QtQuick 1.0

Item {
    id: delegateItem

    property variant itemdata : model
    width: ListView.view.width
    height: sourceText.height + 8
    Image {
        id: backgroundImage
        anchors.fill: parent; 
        source: themeResourcePath + "/media/" + (ListView.isCurrentItem ? "MenuItemFO.png" : "MenuItemNF.png");
    }
    Text {
        id: sourceText
        anchors.verticalCenter: parent.verticalCenter
        z: 1 // ensure it is above the background
        text: model.display
        font.pointSize: 16
        font.weight: Font.Light
        color: "white"
    }

    function trigger() {
        var visualDataModel = ListView.view.model
        if (model.hasModelChildren) {
            visualDataModel.rootIndex = visualDataModel.modelIndex(index)
            ListView.view.rootIndexChanged();
        } else {
            ListView.view.currentIndex = index;
            ListView.view.clicked()
        }
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: {
            ListView.view.currentIndex = index
            currentItem.focus = true
        }
        onClicked: {
            if (mouse.button == Qt.LeftButton)
                delegateItem.trigger()
            else {
                ListView.view.rightClicked(delegateItem.x + mouseX, delegateItem.y + mouseY)
            }
        }
    }

    Keys.onReturnPressed: delegateItem.trigger()
}

