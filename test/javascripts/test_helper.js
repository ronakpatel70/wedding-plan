//= require magic_lamp
//= require turbolinks
//= require jquery
//= require support/jasmine-jquery-2.1.0
//= require helpers/mock_ajax
//= require unwrapped
//= require utilities/shortcut
//= require helpers/test_responses
//
// PhantomJS (Teaspoons default driver) doesn't have support for Function.prototype.bind, which has caused confusion.
// Use this polyfill to avoid the confusion.
//= require support/phantomjs-shims

jasmine.DEFAULT_TIMEOUT_INTERVAL = 1000;

MagicLamp.preload();

CSRF_TOKEN = '1234';

Document.prototype.trigger = Element.prototype.trigger = function(type, key) {
    var event = new Event(type);
    if (type === 'keypress' || type === 'keydown' || type === 'keyup') {
        event.keyCode = key;
    }
    this.dispatchEvent(event);
}
