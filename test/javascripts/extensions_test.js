//= require extensions

describe('Extension', function() {
    it('Date.toSimpleTime should return formatted time', function() {
        var time = new Date(2015, 1, 1, 10, 9, 0);
        expect(time.toSimpleTime()).toBe('10:09');
    });
});
