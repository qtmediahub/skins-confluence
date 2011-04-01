function initialize() {
    if (typeof(cursor) != 'undefined') {
        cursor.idleTimeout = 2
        cursor.defaultCursorPath = themeResourcePath + "/media/pointer-focus.png"
        cursor.clickedCursorPath = themeResourcePath + "/media/pointer-focus-click.png"
    }
}

