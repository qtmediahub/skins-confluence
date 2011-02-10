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
import ActionMapper 1.0

Flow {
    id: root

    property int upperThreshold: children.length - 1

    property bool wrapping: false
    property int focusedIndex: 0

    signal activity
    signal lowerBoundExceeded
    signal upperBoundExceeded

    Keys.onPressed:
        if (actionmap.eventMatch(event, ActionMapper.Right))
            flow == Flow.LeftToRight ? adjustIndex(+1) : undefined
        else if (actionmap.eventMatch(event, ActionMapper.Left))
            flow == Flow.LeftToRight ? adjustIndex(-1) : undefined

    function adjustIndex(delta)
    {
        activity()
        var exceededLower = false
        var exceededUpper = false

        focusedIndex += delta
        
        //FIXME: surely I can queue these?!
        if(focusedIndex < 0) {
            focusedIndex = wrapping ? upperThreshold : 0
            exceededLower = true
        }
        if(focusedIndex > upperThreshold) {
            focusedIndex = wrapping ? 0 : upperThreshold
            exceededUpper = true
        }
        //Propagate beyond spacers
        children[focusedIndex].children.length == 0 && !exceededUpper && !exceededLower
            ? adjustIndex(delta)
            : children[focusedIndex].forceActiveFocus() 

        if(exceededLower)
            lowerBoundExceeded()
        if(exceededUpper)
            upperBoundExceeded()
    }

    function focusItem() {
        var index = -1
        for(var i = 0; i < children.length; i++)
            children[i].activeFocus ? index = i : undefined
        return index == -1 ? undefined : children[index]
    }

    function setFocusItem(item) {
        var index = -1

        for(var i = 0; i < children.length; i++)
            item == children[i] ? index = i : undefined

        if (index != -1) {
            children[index].forceActiveFocus()
            activity()
        }
    }

    function resetFocus() {
        focusedIndex = 0
        adjustIndex(0)
    }

    function giveFocus() {
        children[focusedIndex].focus = true
    }

    function focusLowerItem() {
        focusedIndex = 0
        adjustIndex(0)
    }

    function focusUpperItem() {
        focusedIndex = upperThreshold
        adjustIndex(0)
    }

    move: Transition {
        NumberAnimation {
            properties: "x,y"
            easing.type: confluence.standardEasingCurve
        }
    }

    add: Transition {
        NumberAnimation {
            properties: "x,y"
            easing.type: confluence.standardEasingCurve
        }
    }
}

