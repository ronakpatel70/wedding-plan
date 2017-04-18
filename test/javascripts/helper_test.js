//= require utilities/status
//= require functions

describe('Helper', function() {
    beforeEach(function() {
        jasmine.Ajax.install();
    });

    afterEach(function() {
        jasmine.Ajax.uninstall();
    });

    it('ajaxWithStatus should send POST request', function() {
        ajaxWithStatus('POST', '/test.json', {data: 'testdata'}, function() {
            expect(this.status).toBe(200);
        });
        jasmine.Ajax.requests.mostRecent().respondWith(TestResponses.empty);
    });

    it('ajaxWithStatus should create status badge', function() {
        ajaxWithStatus('POST', '/test.json', {data: 'testdata'}, function() {
            expect(id('status')).toHaveClass('success');
        });
        jasmine.Ajax.requests.mostRecent().respondWith(TestResponses.empty);

        ajaxWithStatus('POST', '/test.json', {data: 'testdata'}, function() {
            expect(id('status')).toHaveClass('alert');
        });
        jasmine.Ajax.requests.mostRecent().respondWith(TestResponses.error);

        id('status').remove();
    });
});
