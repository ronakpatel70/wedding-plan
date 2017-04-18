document.addEventListener('turbolinks:load', function() {

    classes('link').on('click', function(e) {
        if (e.target.tagName === 'A') return;

        const url = this.dataset.href;

        if (e.metaKey || e.ctrlKey)
            window.open(url, '_blank');
        else
            Turbolinks.visit(url);
    });

    classes('has-dropdown').on('click', function() {
        let dropdown = this;
        dropdown.classList.toggle('hover');
        document.body.addEventListener('mouseup', closeDropdown);

        function closeDropdown(e) {
            if (e.target.parentNode === dropdown) return;
            dropdown.classList.remove('hover');
            document.body.removeEventListener('mouseup', closeDropdown);
        }
    });

    classes('dropdown').on('click', function() {
        let dropdown = document.getElementById(this.dataset.dropdown);
        this.classList.add('open');

        dropdown.classList.add('open', 'f-open-dropdown');
        dropdown.style.position = 'absolute';
        dropdown.style.left = this.offsetLeft + this.offsetWidth - dropdown.offsetWidth + 'px';
        dropdown.style.top = this.offsetTop + this.offsetHeight + 'px';

        document.body.addEventListener('mouseup', closeDropdown);
        function closeDropdown(e) {
            if (e.target.parentNode === dropdown) return;
            dropdown.classList.remove('open', 'f-open-dropdown');
            document.body.removeEventListener('mouseup', closeDropdown);
        }
    });

    classes('fold').on('click', function(e) {
        let el = this.nextElementSibling;
        while (el && el.classList.contains('folded')) {
            el.classList.remove('folded');
            el = el.nextElementSibling;
        }
        this.remove();
    });

    classes('modal-trigger').on('click', function(e) {
        e.preventDefault();
        let content = JSON.parse(this.dataset.modal);
        new Modal(content);
    });

    classes('toggle').on('click', function(e) {
       e.preventDefault();

       if (!id(this.dataset.toggle).classList.toggle('hide'))
           if (this.dataset.hide !== undefined) this.classList.add('hide');
    });

    // Toggles accordion segments open and closed.
    classes('accordion navigation').on('click', (e) => e.target.nextElementSibling.classList.toggle('active'));

    // Closes an alert box.
    classes('close').on('click', function(e) {
        e.preventDefault();

        let alertBox = this.closest({class: 'alert-box'});
        alertBox.addEventListener('transitionend', function() {this.remove();});
        alertBox.classList.add('alert-close');
    });

    classes('markdown-editor-tab-link').on('click', function(e) {
        e.preventDefault();

        let wrap = this.closest({class: 'markdown-editor'});
        let tab = this.closest({class: 'markdown-editor'}).classes(this.dataset.tab)[0];
        this.closest({class: 'markdown-editor'}).classes('tab').each(function() {
            this.classList.add('hide');
        });

        if (this.dataset.tab === 'preview') {
            let markdown = wrap.classes('markdown-field')[0].value;
            if (markdown.length === 0) {
                tab.innerHTML = 'Nothing to preview.';
                tab.classList.remove('hide');
                return;
            }
            HTTP.post('/preview', markdown, function() {
                const src = '<style>body {color: #222; font-family: HelveticaNeue, Helvetica, Arial, sans-serif; font-size: 14px;}</style>' + this.response;
                tab.innerHTML = this.response;
                tab.children[0].srcdoc = src;
                tab.classList.remove('hide');
            });
        } else {
            tab.classList.remove('hide');
        }
    });

    // Inserts a new add-on row to the booth add-ons table.
    classes('new-add-on').on('click', function(e) {
        let body = id('add-on-table').tBodies[0];
        let mimic = body.rows[body.rows.length - 1];
        let fields = [
            createElement('td', mimic.cells[0].innerHTML.replace(/\[[0-9]\]/, '[100]')),
            createElement('td', '--'),
            createElement('td', mimic.cells[2].innerHTML.replace(/\[[0-9]\]/, '[100]')),
            createElement('td', '--'),
            createElement('td', '--')
        ];
        let row = createElement('tr', fields);
        body.appendChild(row);
    });

    window.tableSorter = null;
    let table = classes('sort')[0];
    if (table) window.tableSorter = new Sort(table);

});
