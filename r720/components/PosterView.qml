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

PathView {
    id: pathView
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

    model : visualDataModel
    pathItemCount: (width+2*delegateWidth)/delegateWidth
    preferredHighlightBegin : 0.5
    preferredHighlightEnd : 0.5

    path: Path {
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

    Keys.onRightPressed: pathView.incrementCurrentIndex()
    Keys.onLeftPressed: pathView.decrementCurrentIndex()
}

