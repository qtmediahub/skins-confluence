.pragma library

function FontMetrics(font)
{
    this.font = font
}

// FIXME
FontMetrics.prototype.width = function(text) {
    return text.length * 12
}

// FIXME
FontMetrics.prototype.height = function(text) {
    return 24
}

