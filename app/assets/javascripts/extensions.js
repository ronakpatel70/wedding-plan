// Returns a formatted 12-hour time without suffix
Date.prototype.toSimpleTime = function() {
    var h = this.getHours();
    var m = this.getMinutes();

    if (h > 12) h -= 12;
    if (m < 10) m = '0' + m;

    return h + ':' + m;
};
