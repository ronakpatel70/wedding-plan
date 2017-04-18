/**
 * Modal
 *
 * A modal. Available options are title (required text), alert (html),
 * body (text), and footer (html).
 *
 * Use:
 *   new Modal(title);
 */

const Modal = function(options) {
    var modal, overlay, wrapper, x, escape;
    init();
    show();

    function init() {
        wrapper = document.createElement('div');
        wrapper.className = 'modal-wrapper';

        overlay = document.createElement('div');
        overlay.className = 'modal-overlay';
        wrapper.appendChild(overlay);

        modal = document.createElement('div');
        modal.className = 'modal';
        var h = createTextElement('h4', options.title, 'left');
        x = createTextElement('a', '×', 'close x');
        modal.appendChild(createElement('div', [h, x], 'modal-header'));

        if (options.alert)
            modal.appendChild(createElement('div', options.alert, 'modal-alert'));

        if (options.body) {
            var body = document.createElement('div');
            body.className = 'modal-body';
            body.appendChild(createTextElement('label', options.body));
            modal.appendChild(body);
        }

        var footer = createElement('div', options.button, 'modal-footer');
        modal.appendChild(footer);

        wrapper.appendChild(modal);
    }

    function show() {
        document.body.appendChild(wrapper);
        x.addEventListener('click', hide);
        overlay.addEventListener('click', hide);
        escape = new Shortcut('ESC', false, hide);
    }

    function hide() {
        wrapper.remove();
        escape.cancel();
    }
}
