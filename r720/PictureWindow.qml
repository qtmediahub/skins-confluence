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

import QtQuick 1.0
import confluence.r720.components 1.0

MediaWindow {
    id: root

    mediaWindowName: "picture"
    informationSheet: PictureInformationSheet { id: pictureInformationSheet }
    mediaEngine: pictureEngine

    function startSlideShow(autoPlay) {
        slideShow.showItem(viewLoader.item.currentItem.itemdata.mediaInfo)

        slideShow.x = viewLoader.item.currentThumbnailRect[0]
        slideShow.y = viewLoader.item.currentThumbnailRect[1]
        slideShow.width = viewLoader.item.currentThumbnailRect[2]
        slideShow.height = viewLoader.item.currentThumbnailRect[3]

        slideShow.state = "visible"
        slideShow.forceActiveFocus()
    }

    function itemActivated(item) {
        root.startSlideShow(false /* autoPlay */)
    }

    PictureSlideShow {
        id: slideShow
        opacity: 0
        z: parent.z + 1
    }

    //FIXME: only outstanding item is to add actions at will!
//        blade.addAction(
//            Qt.createQmlObject('import QtQuick 1.0;\
//                                import confluence.r720.components 1.0; \
//                                ConfluenceAction { \
//                                text: qsTr("SLIDESHOW"); \
//                                onTriggered: root.startSlideShow(true /*autoPlay */) }'
//                               , blade, ""))
        //            ConfluenceAction {
        //                id: slideShowAction
        //                text: qsTr("SLIDESHOW")
        //                onTriggered: root.startSlideShow(true /*autoPlay */)
        //            }]

}
