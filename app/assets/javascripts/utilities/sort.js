/**
 * Sort
 *
 * Sorts a table when a column header is clicked. Sorting behavior for a column can be changed by
 * adding a data-sort-as attribute to the column header. A value of "int" treats the cell values
 * as integers; "custom" sorts by data-sort-by attributes on each cell. To indicate that a column
 * is presorted add a class of "asc" or "desc" to the header. Add a data-sort-none attribute to a
 * header to disable sorting for that column. Add a data-cycle-col="n" attribute to the table to enable
 * rotating columns, where n is the 1-based index of the first column to display.
 *
 * Use:
 *   new Sort(tableElement);
 */

const Sort = function(table) {
    const headers = table.tHead.rows[0].cells;
    let activeHeader = table.tHead.getElementsByClassName('asc')[0] ||
        table.tHead.getElementsByClassName('desc')[0];
    const cycleCol = table.dataset.cycleCol;
    if (cycleCol) table.dataset.cycleCur = cycleCol;

    const tbody = table.tBodies[0];
    let rows = Array.prototype.slice.call(tbody.rows);
    const valueMap = [];
    for (let i=0; i<headers.length; i++) {
        valueMap.push([]);
        if (headers[i].hasAttribute('data-sort-none')) continue;
        const sortAs = headers[i].getAttribute('data-sort-as');
        let val;
        for (let r of rows) {
            if (r.classList.contains('fold')) continue;
            switch (sortAs) {
            case 'int':
                val = parseInt(r.cells[i].textContent.replace(/[^0-9]+/g, ''));
                break;
            case 'custom':
                val = r.cells[i].getAttribute('data-sort-by');
                break;
            default:
                val = r.cells[i].textContent.slice(0, 32).toLowerCase();
                if (val == '' || val == '--') val = "\u007F";
            }
            valueMap[i].push([val, rows.indexOf(r)]);
        }
        headers[i].title = tooltipFor(headers[i]);
        headers[i].addEventListener('click', clickHandler);
    }

    function clickHandler() {
        table.getElementsByClassName('fold').each(function() {this.style.display = 'none';});
        const index = indexOf(this, this.parentNode);
        if (parseInt(table.dataset.cycleCur) == index + 1)
            return clickHandler.call(nextHeader(this));
        else if (index >= cycleCol - 1) table.dataset.cycleCur = index + 1;

        let unsorted = valueMap[index];
        let sorted = sort(unsorted, this.getAttribute('data-sort-as'));
        willSortDesc(this) && sorted.reverse();
        tbody.remove();
        for (const s of sorted) {
            tbody.appendChild(rows[s[1]]);
        }
        table.appendChild(tbody);

        activeHeader = setActive(this, index >= cycleCol - 1);
    }

    // Returns true if the column will sort descending when clicked
    function willSortDesc(th) {
        return th.classList.contains('asc') ||
            (th.hasAttribute('data-sort-reverse') &&
            !th.classList.contains('desc'));
    }

    // Returns the header that comes next in the cycle
    function nextHeader(th) {
        return th.nextElementSibling || headers[cycleCol-1];
    }

    // Adds/removes classes on the active header and updates the tooltip
    function setActive(el, noarr) {
        if (activeHeader === el) {
            el.classList.toggle('asc');
            el.classList.toggle('desc');
            el.title = tooltipFor(el);
            return el;
        }

        if (activeHeader) {
            activeHeader.classList.remove('asc', 'desc');
            activeHeader.title = tooltipFor(activeHeader);
        }

        el.classList.add(el.hasAttribute('data-sort-reverse') ? 'desc' : 'asc');
        noarr && el.classList.add('noarr');
        el.title = tooltipFor(el);
        return el;
    }

    // Returns a sorted array
    function sort(array, type) {
        array = array.slice();
        switch (type) {
            case 'int':
                return array.sort(function(a, b) {return a[0] - b[0];});
                break;
            default: return array.sort();
        }
    }

    // Returns a tooltip explaining which action the header performs on click
    function tooltipFor(th) {
        if (indexOf(th, th.parentNode) >= cycleCol - 1) {
            return `Swap column to ${nextHeader(th).textContent}`;
        }

        const dir = willSortDesc(th) ? 'descending' : 'ascending';
        return `Sort in ${dir} order`;
    }
};
