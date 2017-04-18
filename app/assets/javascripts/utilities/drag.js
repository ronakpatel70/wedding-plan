/**
 * Drag(draggableElements, dropZones, dropCallback, dragStartCallback, dragEndCallback)
 *
 * Sets up draggable elements and drop targets
 * Fires a callback when a draggable element is dropped on a target
 * Adds 'dragover' class to drop zones when an element is dragged over them
 *
 * Create a drag listener:
 *   var items = document.getElementsByClassName('item');
 *   var dropZone = document.getElementById('zone');
 *   var dragger = new Drag(items, dropZone, function(droppedNode) {...});
 * Add new draggable element:
 *   var newToken = document.getElementById('new-token');
 *   dragger.addElement(newToken);
 */

const Drag = function(dragElements, dropZones, dropCallback, dragStartCallback, dragEndCallback) {
    var dragTargets = Array.prototype.slice.call(dragElements);

    function dragListener(event) {
        event.dataTransfer.setData('text/plain', this.id);
        if (dragStartCallback) dragStartCallback.call(this);
    }

    function onDragOver(event) {
        event.preventDefault();
    }

    function onDragEnter() {
        this.classList.add('dragover');
    }

    function onDragLeave() {
        this.classList.remove('dragover');
    }

    function onDrop(event) {
        event.preventDefault();
        this.classList.remove('dragover');
        var el = document.getElementById(event.dataTransfer.getData('text/plain'));
        dropCallback.call(this, el);
    }

    for (var i=0; i<dragTargets.length; i++) {
        dragTargets[i].draggable = true;
        dragTargets[i].addEventListener('dragstart', dragListener);
        if (dragEndCallback) dragTargets[i].addEventListener('dragend', dragEndCallback);
    }

    for (i=0; i<dropZones.length; i++) {
        dropZones[i].addEventListener('dragover', onDragOver);
        dropZones[i].addEventListener('dragenter', onDragEnter);
        dropZones[i].addEventListener('dragleave', onDragLeave);
        dropZones[i].addEventListener('drop', onDrop);
    }

    this.addElement = function(element) {
        dragTargets.push(element);
        element.draggable = true;
        element.addEventListener('dragstart', dragListener);
        if (dragEndCallback) element.addEventListener('dragend', dragEndCallback);
    };
};
