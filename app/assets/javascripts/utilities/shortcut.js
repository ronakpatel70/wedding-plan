/**
 * Shortcut(uppercaseKey, fireDuringFocus, callback)
 *
 * Fires a callback when a specified key is pressed.
 * Special keys can be referenced using the strings listed below.
 *
 * Create a shortcut:
 *   let aShortcut = new Shortcut('A', false, () => alert('A'));
 * Cancel a shortcut:
 *   aShortcut.cancel();
 */

const SHORTCUT_SPECIAL_KEYS = {
    'DEL': 8,
    'RET': 13,
    'ESC': 27,
    'SPACE': 32,
    'TAB': 9,
    'LEFT': 37,
    'UP': 38,
    'RIGHT': 39,
    'DOWN': 40,
    'SLASH': 191,
};

class Shortcut {
    constructor(key, always, action) {
        this.key = key;
        this.always = always;
        this.action = action;

        document.addEventListener('keydown', (e) => this.callback(e));
    }

    callback(e) {
        if (!this.always && document.activeElement !== document.body) return;
        if (this.matches(e.keyCode)) {
            e.preventDefault();
            this.action();
        }
    }

    // Cancels the keydown listener.
    cancel() {
        document.removeEventListener('keydown', (e) => this.callback(e));
    }

    // Returns true if keyCode matches key.
    matches(keyCode) {
        if (this.key.length === 1) {return String.fromCharCode(keyCode) === this.key;}
        else {return keyCode === SHORTCUT_SPECIAL_KEYS[this.key];}
    }
}
