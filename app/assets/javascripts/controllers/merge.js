const MergeController = function() {
    this.tokenFieldCallback = function(text, id) {
        const fields = ['industry', 'rewards_status', 'email', 'phone', 'cell_phone', 'website', 'facebook'];
        let submit = document.getElementById('submit');
        let duplicate = document.getElementById('duplicate_vendor_fields');

        if (text === null) {
            duplicate.hidden = true;
            submit.disabled = true;
            return;
        }

        api("/vendors/" + id + ".json", function() {
            let data = JSON.parse(this.response);

            duplicate.hidden = false;
            submit.disabled = false;

            for (let f of fields) {
                let baseField = document.getElementById('base_vendor_' + f);
                let dupField = document.getElementById('duplicate_vendor_' + f);
                dupField.classList.remove('success', 'deleted');

                if (data[f] && data[f].length) {
                    dupField.textContent = data[f];
                } else {
                    dupField.textContent = '--';
                    continue;
                }

                if (baseField.textContent === '') {
                    dupField.classList.add('success');
                } else if (baseField.textContent !== data[f]) {
                    dupField.classList.add('deleted');
                }
            }
        });
    }
}
