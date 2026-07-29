import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import ".." // Theme, Motion, LauncherState

// Application launcher. Type to filter, arrows to move, Enter to run.
//
// The list is ordered by how often you actually start things. With the search
// empty that is the whole ranking, so the app you use most is under the cursor
// the moment the launcher opens.
//
// While searching, match quality comes first and usage breaks the ties: an app
// whose name starts with what you typed still outranks one that merely mentions
// it in its description, but among equally good matches the familiar one wins.
// The tiers are deliberately coarse — no length arithmetic — so that usage, not
// a two-character difference in name length, decides the order inside a tier.
Scope {
    id: root

    readonly property string terminal: "kitty"

    readonly property int rowHeight: 56
    readonly property int maxRows: 7

    property string query: ""
    property int selected: 0

    // The true number of matches, not the capped list length.
    property int matchCount: 0

    function score(entry, needle) {
        // Everything ties when nothing is typed, so usage alone orders the list.
        if (needle === "")
            return 1;

        const name = (entry.name ?? "").toLowerCase();
        const generic = (entry.genericName ?? "").toLowerCase();
        const comment = (entry.comment ?? "").toLowerCase();
        const keywords = (entry.keywords ?? []).join(" ").toLowerCase();

        if (name === needle)
            return 7;
        if (name.startsWith(needle))
            return 6;
        // A match at a word boundary reads as intentional; mid-word is weaker.
        if (name.includes(" " + needle))
            return 5;
        if (name.includes(needle))
            return 4;
        if (generic.includes(needle))
            return 3;
        if (keywords.includes(needle))
            return 2;
        if (comment.includes(needle))
            return 1;
        return 0;
    }

    readonly property var results: {
        const needle = root.query.trim().toLowerCase();
        const out = [];

        for (const entry of DesktopEntries.applications.values) {
            if (entry.noDisplay)
                continue;
            const value = root.score(entry, needle);
            if (value > 0)
                out.push({
                    entry: entry,
                    score: value,
                    uses: LauncherState.countFor(entry)
                });
        }

        // Match quality, then how often it is used. The shorter-name tiebreak
        // only helps while searching ("fi" should reach Firefox before Firefox
        // Developer Edition); with nothing typed it would sort the untouched
        // tail by name length, which reads as random, so fall back to A-Z.
        const searching = needle !== "";
        out.sort((a, b) => b.score - a.score || b.uses - a.uses || (searching ? a.entry.name.length - b.entry.name.length : 0) || a.entry.name.localeCompare(b.entry.name));
        root.matchCount = out.length;
        // Rendering every match is pointless when only seven are on screen.
        return out.slice(0, 40).map(r => r.entry);
    }

    onResultsChanged: root.selected = 0

    function launch(entry) {
        if (!entry)
            return;
        LauncherState.bump(entry);
        if (entry.runInTerminal)
            Quickshell.execDetached([root.terminal, "-e", ...entry.command]);
        else
            Quickshell.execDetached(entry.command);
        LauncherState.close();
    }

    LazyLoader {
        active: LauncherState.open

        PanelWindow {
            id: overlay

            screen: {
                const wanted = Hyprland.focusedMonitor?.name ?? "";
                return Quickshell.screens.find(s => s.name === wanted) ?? null;
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            focusable: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Component.onCompleted: {
                root.query = "";
                root.selected = 0;
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.alpha(Theme.shadow, 0.5)

                opacity: 0
                Component.onCompleted: opacity = 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.normal
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: LauncherState.close()
                }
            }

            Rectangle {
                id: card

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Math.round(parent.height * 0.16)

                width: 620
                // Grows with the results instead of leaving a hollow box.
                height: search.height + Math.min(list.contentHeight, root.maxRows * root.rowHeight) + (root.results.length > 0 ? 20 : 0)

                radius: 24
                color: Theme.alpha(Theme.surfaceContainer, 0.98)
                clip: true

                opacity: 0
                scale: 0.95
                transformOrigin: Item.Top

                Component.onCompleted: {
                    opacity = 1;
                    scale = 1;
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.normal
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Motion.normal
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Motion.emphasized
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: Motion.normal
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Motion.emphasized
                    }
                }

                MouseArea {
                    anchors.fill: parent
                }

                Item {
                    id: search

                    width: parent.width
                    height: 66

                    Text {
                        id: glass

                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u{f0349}"
                        color: input.text === "" ? Theme.textMuted : Theme.primary
                        font.family: Theme.iconFamily
                        font.pixelSize: 20

                        Behavior on color {
                            ColorAnimation {
                                duration: Motion.fast
                            }
                        }
                    }

                    TextInput {
                        id: input

                        anchors.left: glass.right
                        anchors.leftMargin: 16
                        anchors.right: counter.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        focus: true
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 19
                        selectionColor: Theme.alpha(Theme.primary, 0.35)
                        selectedTextColor: Theme.text
                        clip: true

                        onTextChanged: root.query = text

                        Keys.onEscapePressed: LauncherState.close()
                        Keys.onUpPressed: root.selected = Math.max(0, root.selected - 1)
                        Keys.onDownPressed: root.selected = Math.min(root.results.length - 1, root.selected + 1)
                        Keys.onReturnPressed: root.launch(root.results[root.selected])
                        Keys.onEnterPressed: root.launch(root.results[root.selected])

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: "Rechercher une application…"
                            color: Theme.alpha(Theme.textMuted, 0.6)
                            font: input.font
                        }
                    }

                    Text {
                        id: counter

                        anchors.right: parent.right
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.matchCount
                        color: Theme.alpha(Theme.textMuted, 0.7)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Theme.alpha(Theme.outlineVariant, 0.5)
                        visible: root.results.length > 0
                    }
                }

                ListView {
                    id: list

                    anchors.top: search.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.min(contentHeight, root.maxRows * root.rowHeight)

                    model: root.results
                    currentIndex: root.selected
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    // ListView animates the highlight for us, which is exactly
                    // the sliding selection this wants.
                    highlightMoveDuration: Motion.normal
                    highlightResizeDuration: 0
                    highlightFollowsCurrentItem: true
                    preferredHighlightBegin: 60
                    preferredHighlightEnd: height - 60
                    highlightRangeMode: ListView.ApplyRange

                    highlight: Item {
                        z: 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            radius: Theme.radiusModule
                            color: Theme.alpha(Theme.primary, 0.18)
                        }
                    }

                    delegate: Item {
                        id: row

                        required property var modelData
                        required property int index

                        readonly property bool chosen: root.selected === index

                        width: list.width
                        height: root.rowHeight

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 22
                            anchors.rightMargin: 22
                            spacing: 16

                            IconImage {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 34
                                height: 34
                                asynchronous: true

                                // A handful of stale waydroid entries point at
                                // PNGs that no longer exist. Quickshell's icon
                                // provider answers those with a placeholder
                                // rather than an error, so neither `check` nor
                                // an Image.Error handler can catch them; the
                                // fix belongs in those .desktop files.
                                source: Quickshell.iconPath(row.modelData.icon, true) || Quickshell.iconPath("application-x-executable")

                                scale: row.chosen ? 1.1 : 1

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Motion.normal
                                        easing.type: Easing.Bezier
                                        easing.bezierCurve: Motion.bounce
                                    }
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Text {
                                    text: row.modelData.name
                                    color: row.chosen ? Theme.text : Theme.alpha(Theme.text, 0.85)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontNormal + 1
                                    font.weight: row.chosen ? Font.DemiBold : Font.Normal

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Motion.fast
                                        }
                                    }
                                }

                                Text {
                                    width: card.width - 130
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                    text: row.modelData.comment || row.modelData.genericName || ""
                                    color: Theme.alpha(Theme.textMuted, 0.75)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSmall
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selected = row.index
                            onClicked: root.launch(row.modelData)
                        }
                    }
                }

                // Nothing matched: say so rather than showing an empty box.
                Text {
                    anchors.top: search.bottom
                    anchors.topMargin: 26
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.results.length === 0 && root.query !== ""
                    text: "Aucune application"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontNormal
                }
            }
        }
    }
}
