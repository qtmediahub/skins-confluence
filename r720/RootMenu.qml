/****************************************************************************

This file is part of the QtMediaHub project on http://www.gitorious.org.

Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).*
All rights reserved.

Contact:  Nokia Corporation (qt-info@nokia.com)**

You may use this file under the terms of the BSD license as follows:

"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

****************************************************************************/

import QtQuick 1.1
import confluence.r720.components 1.0
import ActionMapper 1.0

FocusScope {
    id: rootMenu
    height: parent.height; width: parent.width

    property variant menuSoundEffect
    property string name: "rootmenu"
    property alias currentItem: rootMenuList.currentItem
    property alias currentIndex: rootMenuList.currentIndex
    property alias buttonGridX : buttonGrid.x

    signal openSubMenu

    Component.onCompleted: {
        if (config.isEnabled("menu-soundeffects", false)) {
            var menuSoundEffectLoader = Qt.createComponent("./components/QMHAudio.qml");
            if (menuSoundEffectLoader.status == Component.Ready) {
                menuSoundEffect = menuSoundEffectLoader.createObject(parent)
                menuSoundEffect.source = themeResourcePath + "/sounds/click.wav"
            } else if (menuSoundEffectLoader.status == Component.Error) {
                backend.log(menuSoundEffectLoader.errorString())
            }
        }
    }

    ConfluenceListView {
        id: rootMenuList

        scrollbar: false
        //Oversized fonts being downscaled
        spacing: confluence.width/40 //30
        focus: true

        //Root menu is a special case
        //Since should not be a massive number of items
        keyNavigationWraps: false

        anchors { left: parent.left; right: parent.right; top: banner.bottom; bottom: buttonGrid.top }
        preferredHighlightBegin: banner.height; preferredHighlightEnd: height - buttonGrid.height

        highlight: Image {
            source:  themeResourcePath + "/media/black-back2.png"
            opacity:  0.5
        }

        model: backend.advertizedEngines //menuList
        delegate:
            RootMenuListItem { }

        onCurrentIndexChanged: {
            background.role = currentItem.role
            !!menuSoundEffect ? menuSoundEffect.play() : undefined
        }

        Keys.onPressed: {
            if (actionmap.eventMatch(event, ActionMapper.Enter))
                currentItem.trigger()
            else if (actionmap.eventMatch(event, ActionMapper.Right))
                rootMenu.openSubMenu()
            else if (actionmap.eventMatch(event, ActionMapper.Left))
                playMediaButton.forceActiveFocus()
            else if (actionmap.eventMatch(event, ActionMapper.Right))
                playMediaButton.forceActiveFocus()
        }
    }

    Image {
        id: banner
        x: 20
        z: rootMenuList.z + 1
        source: themeResourcePath + "/media/Confluence_Logo.png"
    }

    ExitDialog {
        id: exitDialog
    }

    Row {
        id: buttonGrid
        y: parent.height - height
        spacing: 2
        width: parent.width

        Keys.onPressed:
            actionmap.eventMatch(event, ActionMapper.Up)
            ||actionmap.eventMatch(event, ActionMapper.Down)
            ? rootMenuList.focus = true
            : undefined

        ConfluencePixmapButton {
            id: playMediaButton
            basePixmap: "home-playmedia"
            focusedPixmap: "home-playmedia-FO"
            onClicked: confluence.show(avPlayer)

            Keys.onPressed:
                if (actionmap.eventMatch(event, ActionMapper.Left))
                    rootMenuList.focus = true
                else if (actionmap.eventMatch(event, ActionMapper.Right))
                    favouritesButton.focus = true
        }
        ConfluencePixmapButton {
            id: favouritesButton
            basePixmap: "home-favourites"
            focusedPixmap: "home-favourites-FO"
            onClicked: confluence.show(aboutWindow)

            Keys.onPressed:
                if (actionmap.eventMatch(event, ActionMapper.Left))
                    playMediaButton.focus = true
                else if (actionmap.eventMatch(event, ActionMapper.Right))
                    powerButton.focus = true
        }
        ConfluencePixmapButton {
            id: powerButton
            basePixmap: "home-power";
            focusedPixmap: "home-power-FO";
            onClicked: confluence.showModal(exitDialog)

            Keys.onPressed:
                if (actionmap.eventMatch(event, ActionMapper.Left))
                    favouritesButton.focus = true
                else if (actionmap.eventMatch(event, ActionMapper.Right))
                    rootMenuList.focus = true
        }
    }
}

