const TimesheetController = function() {
    var timeRegex = /^[0-9]{1,2}:[0-9]{2}[ap]m$/;
    var shifts = document.getElementsByClassName('timecard');
    for (var i=0; i<shifts.length; i++) {
        var inputs = shifts[i].getElementsByTagName('input');
        for (var k=0; k<inputs.length; k++) {
            inputs[k].addEventListener('change', saveShift);
        }
    }

    function saveShift(event) {
        if (!this.value.match(timeRegex)) {
            if (this.value !== '') {
                Status.set('Invalid time', 'alert', false);
                this.value = '';
            }
            return;
        }

        var shift = this.parentNode;
        var in_time = shift.children['shift[in_time]'].value;
        var out_time = shift.children['shift[out_time]'].value;
        if (in_time && out_time) {
            var diff = (parseTime(out_time) - parseTime(in_time)) / 1000 / 3600;
            shift.dataset.timeWorked = diff;
            sumTimes(shift.parentNode);
        }

        var data = {shift: {}};
        var param = this.name.match(/in_time|out_time/)[0];
        data.shift[param] = this.value;
        ajaxWithStatus('PUT', shift.dataset.url, data);
    }

    function sumTimes(row) {
        var times = row.getElementsByClassName('timecard');
        var sum = 0;
        for (var i=0; i<times.length; i++) {
            sum += parseFloat(times[i].dataset.timeWorked);
        }
        row.getElementsByClassName('total')[0].children[0].textContent = Math.round(sum * 10, 1) / 10;
    }
};
