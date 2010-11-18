import QtQuick 1.0
import "components"


FocusScope {
    id: rootMenu
    height: parent.height; width: parent.width
    property variant clickComponent: Qt.createComponent("components/QMHAudio.qml");
    property variant menuSoundEffect

    Component.onCompleted: {
        if(clickComponent.status == Component.Ready) {
            menuSoundEffect = clickComponent.createObject(mainBlade)
            menuSoundEffect.source = themeResourcePath + "/sounds/click.wav"
        }
    }

    Keys.onLeftPressed:
        buttonGrid.focusUpperItem()

    Item {
        id: bannerPlaceHolder
        height: banner.height
    }

    ListView {
        id: mainBladeList

        signal itemTriggered
        signal itemSelected

        //Oversized fonts being downscaled
        spacing: -30
        focus: true
        keyNavigationWraps: true
        //highlightFollowsCurrentItem: true

        anchors { right: rootMenu.right; rightMargin: 30; top: bannerPlaceHolder.bottom; bottom: buttonGrid.top }

        width: bladeWidth

        model: backend.engines //menuList
        delegate:
            BladeListItem { }
        onItemTriggered: {
            if(currentItem.role == "weather")
                confluence.state = "showingWeatherDialog"
            if(currentItem.role == "system")
                confluence.state = "showingSystemDialog"
            if(currentItem.role == "web")
                confluence.state = "showingWebDialog"
            if(currentItem.role == "maps")
                confluence.state = "showingMapsDialog"
            if(currentItem.role == "dashboard")
                confluence.state = "showingDashboard"
        }
        onItemSelected: {
            background.asyncSetRole(currentItem.role)
            if(menuSoundEffect != undefined) {
                menuSoundEffect.play()
            }
        }
        Keys.onEnterPressed:
            itemTriggered()
        Keys.onReturnPressed:
            itemTriggered()
        Keys.onRightPressed:
            if(currentItem.hasSubBlade)
                mediaBlade.state = "open"
    }

    ButtonList {
        id: buttonGrid
        x: mainBlade.bladeX + 5; y: parent.height - height;
        spacing: 2
        width: parent.width

        onUpperBoundExceeded: {
            mainBladeList.focus = true
        }

        PixmapButton { basePixmap: "home-playmedia"; focusedPixmap: "home-playmedia-FO" }
        PixmapButton { basePixmap: "home-favourites"; focusedPixmap: "home-favourites-FO" }
        PixmapButton {
            basePixmap: "home-power";
            focusedPixmap: "home-power-FO";
            onClicked:
                confluence.state = "showingExitDialog"
        }
    }
}
