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
        if (model.hasModelChildren) {
            visualDataModel.rootIndex = visualDataModel.modelIndex(index)
            ListView.view.rootIndexChanged();
        } else if (model.type == "DotDot") { // FIXME: Make this MediaModel.DotDot when we put the model code in a library
            visualDataModel.rootIndex = visualDataModel.parentModelIndex();
            ListView.view.rootIndexChanged();
        } else {
            ListView.view.currentIndex = index;
            ListView.view.clicked()
        }
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true
        onEntered: {
            ListView.view.currentIndex = index
            currentItem.forceActiveFocus()
        }
        onClicked: {
            delegateItem.trigger()
        }
    }

    Keys.onReturnPressed: delegateItem.trigger()
}

