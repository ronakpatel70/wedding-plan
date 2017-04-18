/**
 * TokenField
 *
 * Converts a text input into a searchable token field. Sends a GET request
 * with a "query" parameter to searchUrl and expects a response with "id" and
 * "text" keys. Allowed options are
 *
 * Use:
 *   new TokenField(textField, searchUrl[, options[, callback]]);
 * Example:
 *   var textField = document.getElementById('user_id');
 *   new TokenField(textField, '/search.json');
 */

const TokenField = function(input, url, options = {}, callback = null) {
    var hidden, wrap, dropdown, container, tokens;
    input.autocomplete = 'off';
    input.spellcheck = false;
    input.placeholder = 'Search';
    wrap = document.createElement('div');
    wrap.classList.add('token-field');
    input.parentNode.insertBefore(wrap, input);
    wrap.appendChild(input);
    dropdown = document.createElement('ul');
    dropdown.classList.add('f-dropdown');
    wrap.parentNode.appendChild(dropdown);
    if (options.multiple) {
        wrap.classList.add('multiple');
        container = document.createElement('div');
        container.className = 'token-container';
        wrap.appendChild(container);
        tokens = container.getElementsByClassName('token');
    }
    if (options.values) {
        for (var i=0; i<options.values.length; i++) {
            if (options.values[i]) addToken(options.values[i].to_s, options.values[i].id);
        }
    }
    input.addEventListener('keyup', debounce(search, 100));
    input.addEventListener('keydown', function(e) {
        e.keyCode === 8 && !input.value.length && tokens.length
            && deleteToken(tokens[tokens.length - 1]);
    });

    function search() {
        if (this.value.length < 3) {
            while (dropdown.firstChild) {dropdown.firstChild.remove();}
            return;
        }

        var request = new XMLHttpRequest();
        request.open('GET', url + (url.includes('?') ? '&' : '?') + 'query=' + this.value, true);
        request.onload = responseHandler;
        request.send();
    }

    function responseHandler() {
        while (dropdown.firstChild) {dropdown.firstChild.remove();}

        var resp = JSON.parse(this.response);
        var hits = [];
        for (var i=0; i<resp.length; i++) {
            hits.push([resp[i].id, resp[i].name]);
        }
        if (!hits.length) return;

        for (var i=0; i<hits.length; i++) {
            var li = document.createElement('li');
            var a = document.createElement('a');
            a.dataset.value = hits[i][0];
            a.textContent = hits[i][1];
            a.addEventListener('click', clickHandler);
            li.appendChild(a);
            dropdown.appendChild(li);
        }

        dropdown.classList.add('open');
    }

    function addToken(text, value) {
        var clear = document.createElement('a');
        clear.className = 'clear x';
        clear.textContent = '×';
        clear.addEventListener('click', clearHandler);

        hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = input.name;
        hidden.value = value;

        if (options.multiple) {
            var token = document.createElement('div');
            token.className = 'token';
            token.textContent = text;
            token.appendChild(clear);
            token.appendChild(hidden);
            container.appendChild(token);
            input.value = '';
            scaleContainer();
        } else {
            input.value = text;
            input.disabled = true;
            wrap.appendChild(clear);
            wrap.appendChild(hidden);
        }

        dropdown.classList.remove('open');
        while (dropdown.firstChild) {dropdown.firstChild.remove();}

        callback && callback.call(input, text, value);
    }

    function clickHandler() {
        addToken(this.textContent, this.dataset.value);
        options.multiple && input.focus();
    }

    function clearHandler() {
        if (options.multiple) {
            deleteToken(this.parentNode);
        } else {
            this.remove();
            hidden.remove();
            input.value = '';
            input.disabled = false;
        }

        callback && callback(null);
        input.focus();
    }

    function deleteToken(token) {
        token.remove();
        scaleContainer();
    }

    function scaleContainer() {
        var left = container.offsetWidth - 5;
        input.style.paddingLeft = tokens.length ? left + 'px' : null;
        if (container.offsetWidth < 480) {
            input.style.width = null;
            dropdown.style.left = left + 'px';
        }
        else {
            input.style.width = (left + 120) + 'px';
            dropdown.style.left = '360px';
        }
    }
};
