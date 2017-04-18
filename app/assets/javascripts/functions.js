// Global functions used by controllers and utility classes

// Sends a GET request to a URL
function api(url, callback) {
    let request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.onload = function() {callback && callback.call(this)};

    return request.send();
}

// Sends ajax request (with CSRF token) and updates global status label
// Data can be object or url-encoded string
function ajaxWithStatus(method, url, data, callback) {
    Status.set('Saving...', 'warning');

    let request = new XMLHttpRequest();
    request.open(method, url, true);
    request.onload = function() {
        if (this.status >= 200 && this.status < 300)
            Status.set('Saved', 'success', true);
        else
            Status.set('Error', 'alert', false);
        if (callback) callback.call(this);
    };

    if (method === 'GET') {
        return request.send();
    }
    else if (typeOf(data) === 'Object') {
        data[CSRF.param()] = CSRF.token();
        request.setRequestHeader("Content-Type", "application/json");
        request.send(JSON.stringify(data));
    }
    else {
        data = data ? data + '&' : '';
        data += `${CSRF.param()}=${encodeURIComponent(CSRF.token())}`;
    	request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        request.send(data);
    }
}

// Holds function calls and fires the last one after a delay
function debounce(fn, delay) {
    let timer = null;
    return function() {
        let context = this, args = arguments;
        clearTimeout(timer);
        timer = setTimeout(function() {
            fn.apply(context, args);
        }, delay);
    }
}

// Creates an element
function createElement(tag, content, className) {
    let el = document.createElement(tag);
    el.className = className;

    switch (typeOf(content)) {
    case 'Array':
        for (let c of content) el.appendChild(c);
        break;
    case 'String':
        el.innerHTML = content;
        break;
    default:
        el.appendChild(content);
    }

    return el;
}

// Creates an element with a text node inside
function createTextElement(tag, text, className) {
    let el = document.createElement(tag);
    let textNode = document.createTextNode(text);
    el.className = className;
    el.appendChild(textNode);
    return el;
}

// Returns the index of el in its parent
function indexOf(el) {
    return [].slice.call(el.parentNode.children).indexOf(el);
}

// Logs a performance time diff in milliseconds
function mark(desc, last) {
    let now = performance.now();
    if (last) console.log(last[0], now - last[1]);
    else console.warn('Start timer');
    if (desc) return [desc, now];
}

// Parses a time string and returns a Date
function parseTime(str) {
    let segments = str.split(':');
    let hour = parseInt(segments[0]) % 12;
    let min = parseInt(segments[1].substr(0, 2));
    let suf = segments[1].substr(2, 2);
    if (suf === 'pm') hour += 12;

    let date = new Date(1970, 1, 1, hour, min, 0);
    return date;
}

// Returns the real type of an object
function typeOf(object) {
	return Object.prototype.toString.call(object).slice(8, -1);
}
