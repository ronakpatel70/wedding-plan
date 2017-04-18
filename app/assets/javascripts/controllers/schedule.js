const ScheduleController = function(showStart, showEnd, shifts) {
    // Set the initial position of the shift bars.
    const rowWidth = document.getElementsByClassName('shifts')[0].offsetWidth;
    for (let id in shifts) {
        let start_time = new Date(shifts[id].start_time);
        let end_time = new Date(shifts[id].end_time);
        let shiftBar = document.getElementById('shift-' + id);
        shiftBar.style.left = (start_time.getTime() - showStart) * rowWidth / 43200000 + 'px';
        shiftBar.style.right = (showEnd - end_time.getTime()) * rowWidth / 43200000 + 'px';
    }

    // Set up the shift drag events.
    let handles = classes('handle');
    handles.on('mousedown', function(e) {
        e.preventDefault();

        let el = this.parentNode;
        let shift = shifts[el.id.split('-')[1]];
        el.classList.add('sliding');

        let moveListener = slideShift(shift, el, this.classList[1], e.pageX);
        let upListener = saveShift(shift, el, moveListener);
        document.addEventListener('mousemove', moveListener);
        document.addEventListener('mouseup', upListener);
    });

    // Remove event listeners and persist the shift to the database.
    function saveShift(shift, el, move) {
        return function() {
            document.removeEventListener('mouseup', saveShift);
            document.removeEventListener('mousemove', move);
            el.parentNode.parentNode.classes('status')[0].innerHTML =
                '<i class="octicon octicon-primitive-dot warning" title="Pending - updated just now"></i>';
            el.classList.remove('sliding');
            ajaxWithStatus('PUT', shift.url, {shift: {start_time: shift.start_time, end_time: shift.end_time}});
        }
    }

    // Adjust the left/right position of a shift bar and calculate the corresponding time.
    function slideShift(shift, el, dir, initX) {
        let shiftX = parseInt(el.style[dir]);
        return function(e) {
            let deltaX = initX - e.pageX;
            let n = shiftX - deltaX * (!dir[4] * 2 - 1);
            if (n < 0) n = 0;
            el.style[dir] = n + 'px';

            shift.start_time = new Date(showStart + parseInt(el.style.left) * 43200000 / rowWidth);
            shift.end_time = new Date(showEnd - parseInt(el.style.right) * 43200000 / rowWidth);
            el.classes('time left')[0].innerHTML = shift.start_time.toSimpleTime();
            el.classes('time right')[0].innerHTML = shift.end_time.toSimpleTime();
        };
    }
};
