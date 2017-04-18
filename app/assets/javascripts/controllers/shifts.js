const ShiftsController = function() {
    var colors = /info|secondary|success|warning/;
    var trash = id('trash');
    var positions = classes('position');
    var dragger = new Drag(classes('user'), classes('drop-zone'), userWasDropped, userWasDragged, dragDidEnd);
    for (var i=0; i<positions.length; i++) {
        colorPanel(positions[i], null, 0);
        colorDupes(positions[i].parentNode);
    }

    function userWasDropped(user) {
        this.id === 'trash' ? deleteShift(user) : moveUser(this, user);
    }

    function userWasDragged() {
        this.closest({class: 'user-bank'}) || trash.classList.remove('hide');
    }

    function dragDidEnd() {
        trash.classList.add('hide');
    }

    function moveUser(panel, user) {
        var uid = user.dataset.userId;
        if (panel.classes('user-' + uid).length) return;

        if (user.dataset.url) {
            deleteShift(user);
        }
        else {
            user = user.cloneNode(true);
            dragger.addElement(user);
        }
        panel.appendChild(user);
        panel.appendChild(new Text('\n'));

        colorPanel(panel, uid, 1);
        colorDupes(panel.parentNode, uid);
        createShift(panel.dataset.id, user, panel.dataset.secondShift === 'true' ? panel.closest({class: 'columns'}).dataset.time : null);
    }

    function createShift(pid, user, start) {
        var data = {shift: {position_id: pid, user_id: user.dataset.userId, start_time: start}};
        ajaxWithStatus('POST', shifts_path, data, function() {
            var resp = JSON.parse(this.response);
            user.id = 'shift-' + resp.id;
            user.dataset.url = resp.url;
        });
    }

    function deleteShift(user) {
        var panel = user.parentNode;
        user.remove();
        colorPanel(panel, user.dataset.userId, -1);
        colorDupes(panel.parentNode);
        ajaxWithStatus('DELETE', user.dataset.url);
    }

    function colorPanel(panel, userId, delta) {
        var filled = panel.dataset.qtyFilled = parseInt(panel.dataset.qtyFilled) + delta;
        var needed = parseInt(panel.dataset.qtyNeeded);

        var color = 'info';
        if (filled === needed) color = 'success';
        else if (filled > needed) color = 'warning';

        panel.className = panel.className.replace(colors, '');
        panel.classList.add(color);
        panel.classes('label').each(function() {
            this.className = this.className.replace(colors, '');
            this.classList.add(color);
        });
    }

    function colorDupes(col, uid) {
        var users = uid ? col.classes('user-' + uid) : col.classes('user');
        for (var j=0; j<users.length; j++) {
            users[j].classList.toggle('alert', col.classes('user-' + users[j].dataset.userId).length > 1);
        }
    }
};
