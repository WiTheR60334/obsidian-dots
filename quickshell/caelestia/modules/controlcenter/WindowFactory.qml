pragma Singleton

import QtQuick
import Quickshell
import qs.components
import qs.services

Singleton {
    id: root

    // Track the single live instance
    property var activeWindow: null

    function create(parent: Item, props: var): void {
        if (root.activeWindow !== null) {
            root.activeWindow.destroy();
            root.activeWindow = null;
            return;
        }
        const win = controlCenter.createObject(parent ?? dummy, props);
        root.activeWindow = win;
    }

    function toggle(parent: Item, props: var): void {
        create(parent, props);
    }

    function close(): void {
        if (root.activeWindow !== null) {
            root.activeWindow.destroy();
            root.activeWindow = null;
        }
    }

    QtObject {
        id: dummy
    }

    Component {
        id: controlCenter

        FloatingWindow {
            id: win

            property alias active: cc.active
            property alias navExpanded: cc.navExpanded

            color: Colours.tPalette.m3surface

            onVisibleChanged: {
                if (!visible) {
                    root.activeWindow = null;
                    destroy();
                }
            }

            Component.onDestruction: {
                if (root.activeWindow === win)
                    root.activeWindow = null;
            }

            implicitWidth: cc.implicitWidth
            implicitHeight: cc.implicitHeight

            minimumSize.width: implicitWidth
            minimumSize.height: implicitHeight
            maximumSize.width: implicitWidth
            maximumSize.height: implicitHeight

            title: qsTr("Caelestia Settings - %1").arg(cc.active.slice(0, 1).toUpperCase() + cc.active.slice(1))

            // Close on Escape
            Shortcut {
                sequence: "Escape"
                onActivated: win.destroy()
            }

            ControlCenter {
                id: cc

                anchors.fill: parent
                screen: win.screen
                onClose: win.destroy()
                floating: true
            }

            Behavior on color {
                CAnim {}
            }
        }
    }
}
