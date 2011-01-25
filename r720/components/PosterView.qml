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
import ActionMapper 1.0

PathView {
    id: pathView

    anchors.fill: parent

    property variant posterModel // Not an alias because of QTBUG-16357
    property alias rootIndex : visualDataModel.rootIndex
    signal rootIndexChanged() // Fire signals of aliases manually, QTBUG-14089
    property int delegateWidth : confluence.width/6.4
    property int delegateHeight : confluence.width/6.4
    property variant currentItem // QTBUG-16347
    signal clicked()
    signal activated()
    signal rightClicked(int mouseX, int mouseY)

    function currentModelIndex() {
        return visualDataModel.modelIndex(currentIndex);
    }

    function setPathStyle(path) {
        pathView.preferredHighlightBegin = pathHash[path].highlightPos
        pathView.path = pathHash[path]
    }

    model: visualDataModel
    //Fixme: were we deliberately constraining this?
    //pathItemCount: (width+2*delegateWidth)/delegateWidth
    //pathItemCount: 20
    preferredHighlightEnd: pathView.preferredHighlightBegin

    VisualDataModel {
        id: visualDataModel
        delegate : PosterViewDelegate { }
        Component.onCompleted: {
            model = pathView.posterModel // Workaround for QTBUG-16357
            var oldRootIndex = rootIndex
            rootIndex = modelIndex(0)
            rootIndex = oldRootIndex // Workaround for QTBUG-16365
        }
    }

    Component.onCompleted:
        setPathStyle("linearZoom")

    Keys.onPressed:
        if (actionmap.eventMatch(event, ActionMapper.Right))
            pathView.incrementCurrentIndex()
        else if (actionmap.eventMatch(event, ActionMapper.Left))
            pathView.decrementCurrentIndex()

    QtObject {
        id: pathHash
        property Path linearZoom: Path {
            property double highlightPos: 0.5
            startX: -pathView.delegateWidth; startY: pathView.height/2.0
            PathAttribute { name: "scale"; value: 1 }
            PathAttribute { name: "z"; value: 1 }
            PathAttribute { name: "opacity"; value: 0.2 }
            PathLine { x: pathView.width/2.5; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1.0 }
            PathLine { x: pathView.width/2.0; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1.5 }
            PathAttribute { name: "z"; value: 2 }
            PathAttribute { name: "opacity"; value: 1.0 }
            PathLine { x: pathView.width/1.5; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1.0 }
            PathLine { x: pathView.width+pathView.delegateWidth; y: pathView.height/2.0 }
            PathAttribute { name: "scale"; value: 1 }
            PathAttribute { name: "z"; value: 1 }
            PathAttribute { name: "opacity"; value: 0.2 }
        }
        property Path amphitheatreZoom: Path {
            id: amphitheatreZoom
            property double highlightPos: 0.5
            startX: 0; startY: pathView.height/2
            PathAttribute { name: "rotation"; value: 90 }
            PathAttribute { name: "scale"; value: 0.2 }
            PathQuad { x: pathView.width/2; y: amphitheatreZoom.startY/2; controlX: pathView.width/4.0; controlY: amphitheatreZoom.startY/2 }
            PathAttribute { name: "scale"; value: 1.0 }
            PathQuad { x: pathView.width; y: amphitheatreZoom.startY; controlX: pathView.width*3.0/4.0; controlY: amphitheatreZoom.startY/2 }
            PathAttribute { name: "rotation"; value: -90 }
            PathAttribute { name: "scale"; value: 0.2 }
        }
        property Path carousel: Path {
            id: carousel
            property double highlightPos: 0.75

            property double horizCenter: pathView.width/2
            property double vertCenter: pathView.height/2 - offsetHeight

            property double perspectiveFlatteningFactor: 1.6
            property double offsetWidth: pathView.delegateWidth * 2
            property double offsetHeight: pathView.delegateHeight/perspectiveFlatteningFactor

            property double horizHypot: offsetWidth/Math.sqrt(2)
            property double vertHypot: offsetHeight/Math.sqrt(2)

            startX: carousel.horizCenter - offsetWidth; startY: carousel.vertCenter
            //(0, midpoint)
            //(midpoint, end)
            //(end, midpoint)
            //(midpoint, 0)

            PathAttribute { name: "z"; value: 5 }
            PathAttribute { name: "scale"; value: 0.6 }
            PathQuad { x: carousel.horizCenter; y: carousel.vertCenter - carousel.offsetHeight; controlX: carousel.horizCenter - carousel.horizHypot; controlY: carousel.vertCenter - carousel.vertHypot }
            PathAttribute { name: "z"; value: 1 }
            PathAttribute { name: "scale"; value: 0.2 }
            PathQuad { x: carousel.horizCenter + carousel.offsetWidth; y: carousel.vertCenter; controlX: carousel.horizCenter + carousel.horizHypot; controlY: carousel.vertCenter - carousel.vertHypot }
            PathAttribute { name: "z"; value: 5 }
            PathAttribute { name: "scale"; value: 0.6 }
            PathQuad { x: carousel.horizCenter; y: carousel.vertCenter + carousel.offsetHeight; controlX: carousel.horizCenter + carousel.horizHypot; controlY: carousel.vertCenter + carousel.vertHypot }
            PathAttribute { name: "z"; value: 10 }
            PathAttribute { name: "scale"; value: 2.0 }
            //Origin
            PathQuad { x: carousel.startX; y: carousel.startY; controlX: carousel.horizCenter - carousel.horizHypot; controlY: carousel.vertCenter + carousel.vertHypot }
        }
    }
}

