const NavController = function() {
    let wrap = id('search');
    let searchField = id('search-field');
    let searchIcon = id('open-search');
    let searchResults = id('search-results');
    let escape, selected;
    let links = searchResults.getElementsByTagName('a');
    let shortcut = new Shortcut('SLASH', false, () => openSearch());
    const LIMIT = 8;
    const SEARCH_API = searchField.dataset.url;
    if (searchField.value != null) {
        searchField.focus();
        searchField.select();
    }

    function openSearch() {
    	wrap.classList.add('open');
    	wrap.childNodes[1].focus();
    	escape = new Shortcut('ESC', true, () => searchField.blur());
    	searchField.on('blur', function() {
            if (document.activeElement === this) {return true;}
        	escape.cancel();
        	wrap.children[0].value = '';
        	searchResults.innerHTML = '';
        	wrap.classList.remove('open');
        });
    }

    searchResults.addEventListener('mousedown', (e) => e.preventDefault());
    searchIcon.children.on('mousedown', (e) => e.preventDefault());

    searchIcon.addEventListener('mouseup', function() {
    	wrap.classList.contains('open') ? searchField.blur() : openSearch();
    });

    searchField.addEventListener('keydown', function(e) {
        switch (e.keyCode) {
        case 13:
            if (links[selected]) {links[selected].click();}
            break;
        case 38:
            if (selected > 0) {
                links[selected].classList.remove('selected');
                links[--selected].classList.add('selected');
            }
            break;
        case 40:
            if (links.length - 1 > selected) {
                links[selected].classList.remove('selected');
                links[++selected].classList.add('selected');
            }
            break;
        default: return true;
        }
        e.preventDefault();
    });

    searchField.addEventListener('keyup', debounce(search, 100));
    document.addEventListener('turbolinks:before-cache', () => searchField.blur());

    function search(e) {
        if (e.which > 8 && e.which < 48 || e.which === 90 || e.which === 91) {
            return false;
        } else if (this.value.length < 3) {
            searchResults.innerHTML = '';
            return true;
        }

        let q = encodeURIComponent(searchField.value);
        let url = `${SEARCH_API}?query=${q}&limit=${LIMIT}`;
        api(url, responseHandler);
    }

    function responseHandler() {
        let searchURL = `/search?query=${encode(searchField.value)}`;
        searchResults.innerHTML = '';
        searchResults.appendChild(link(`Search for '${searchField.value}'`, searchURL, 'selected'));
        selected = 0;

        let results = JSON.parse(this.responseText);
        if (!results.length) return;
        searchResults.appendChild(createElement('li', '', 'divider'));
        for (let j in results) {
            searchResults.appendChild(link(results[j].name, results[j].url));
		}
    }

    function link(text, url, classname = '') {
        let a = Element.create('a', text, {href: url, class: classname});
        let li = Element.create('li', a);
        return li;
    }

    function encode(str) {
        return encodeURIComponent(str).replace(/%20/g, '+');
    }
};
