pragma Singleton

import Quickshell

// Which dropdown is open, and on which screen.
//
// The state is shared so two monitors never show the same panel at once, but it
// is keyed by screen as well as by name — otherwise every bar matches on the
// name alone and the calendar opens on all of them.
Singleton {
    id: root

    property string open: ""
    property string screen: ""

    function isOpen(name, screenName) {
        return root.open === name && root.screen === screenName;
    }

    function toggle(name, screenName) {
        if (root.isOpen(name, screenName)) {
            root.close();
            return;
        }
        root.open = name;
        root.screen = screenName;
    }

    function close() {
        root.open = "";
        root.screen = "";
    }
}
