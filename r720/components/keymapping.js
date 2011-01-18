.pragma library

var qmhactions = {
    left: 1,
    up: 2,
    right: 3,
    down: 4,
    forward: 5,
    back: 6,
    play: 7
}

var keyarray = []

//keyarray[qmhactions.right] = ['Qt::Key_Right']
//keyarray[qmhactions.down] = ['Qt::Key_Down']
//keyarray[qmhactions.left] = ['Qt::Key_Left']
//keyarray[qmhactions.up] = ['Qt::Key_Up']
keyarray[qmhactions.left] = [ 0x01000012 ]
keyarray[qmhactions.up] = [ 0x01000013 ]
keyarray[qmhactions.right] = [ 0x01000014 ]
keyarray[qmhactions.down] = [ 0x01000015 ]
//keyarray[qmhactions.forward] = ['Qt::Key_Return', 'Qt::Key_Enter']
keyarray[qmhactions.forward] = [ 0x01000004, 0x01000005 ]
//keyarray[qmhactions.back] = ['Qt::Key_Escape']
keyarray[qmhactions.back] = [ 0x01000000 ]
//keyarray[qmhactions.play] = ['Qt::Key_Space']
keyarray[qmhactions.play] = [ 0x20 ]

function actionMapsToKey(action, keyevent)
{
    var index = keyarray[action].indexOf(keyevent.key)

    return keyevent.accepted = (index != -1)
}
