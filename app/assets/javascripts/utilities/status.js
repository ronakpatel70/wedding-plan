/**
 * Status
 *
 * Creates a global status indicator below the nav bar.
 * Optionally fades out after 1.5 seconds.
 *
 * Use:
 *   Status.set(text, style, shouldFade)
 * Example:
 *   Status.set('Success!', 'success', true)
 */

const Status = (function() {
    let status = {};
    let label;
    let fadeTimer;

    function createStatusLabel(text, style) {
        label = document.createElement('div');
        label.className = `label radius ${style} light status`;
        label.id = 'status';
        label.innerHTML = text + iconForStyle(style);
        document.body.appendChild(label);
        label.style.marginLeft = (-0.5) * label.offsetWidth + 'px';
        return label;
    }

    function iconForStyle(style) {
        switch (style) {
            case 'success': return ' <i class="fi-check"></i>';
            case 'alert': return ' <i class="fi-alert"></i>';
            default: return '';
        }
    }

    function fadeLabel() {
        label.classList.add('fade');
        label.addEventListener('transitionend', (e) => e.target.remove());
    }

    status.set = function(text, style, fade) {
        if (label) label.remove();
        if (fadeTimer) clearTimeout(fadeTimer);

        label = createStatusLabel(text, style);
        fadeTimer = fade && setTimeout(fadeLabel, 1500);
    };

    return status;
})();
