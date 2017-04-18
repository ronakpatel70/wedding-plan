//= require controllers/nav

describe('Navbar', function() {
    var search, icon, field;

    beforeEach(function() {
        MagicLamp.load('base/nav');
        search = id('search');
        icon = id('open-search');
        field = id('search-field');
        results = id('search-results');
        links = results.getElementsByTagName('a');

        NavController();
        jasmine.Ajax.install();
    });

    afterEach(function() {
       MagicLamp.clean();
       jasmine.Ajax.uninstall();
    });

    it('should open and close search on click', function() {
        icon.trigger('mouseup');
        expect(search).toHaveClass('open');
        icon.trigger('mouseup');
        expect(search).not.toHaveClass('open');
        expect(field).toHaveValue('');
    });

    it('should open and close search on keypress', function() {
        document.trigger('keydown', 83);
        expect(search).toHaveClass('open');
        document.trigger('keydown', 27);
        expect(search).not.toHaveClass('open');
        expect(field).toHaveValue('');
    });

    it('should close search on blur', function() {
        icon.trigger('mouseup');
        field.value = 'typed text';
        field.blur();
        expect(search).not.toHaveClass('open');
        expect(field).toHaveValue('');
    });

    it('should fetch search results', function() {
        icon.trigger('mouseup');
        field.value = 'Waits';
        field.trigger('keyup', 13);
        jasmine.Ajax.requests.mostRecent().respondWith(TestResponses.search.success);
        expect(results.childNodes.length).toBe(3);
    });

    it('should select search results with arrow keys', function() {
        icon.trigger('mouseup');
        field.value = 'Waits';
        field.trigger('keyup', 8);
        jasmine.Ajax.requests.mostRecent().respondWith(TestResponses.search.success);
        expect(links[0]).toHaveClass('selected');

        field.trigger('keydown', 40);
        expect(links[0]).not.toHaveClass('selected');
        expect(links[1]).toHaveClass('selected');

        field.trigger('keydown', 38);
        expect(links[1]).not.toHaveClass('selected');
        expect(links[0]).toHaveClass('selected');
    });

    it('should click search result with return key', function() {
        icon.trigger('mouseup');
        field.value = 'Waits';
        field.trigger('keyup', 8);
        jasmine.Ajax.requests.mostRecent().respondWith(TestResponses.search.success);

        spyOn(links[0], 'click');
        field.trigger('keydown', 13);
        expect(links[0].click).toHaveBeenCalled();
    });
});
