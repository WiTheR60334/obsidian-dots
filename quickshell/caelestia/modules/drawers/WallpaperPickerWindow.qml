pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Caelestia.Config
import Caelestia.Models
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.images
import qs.services
import qs.utils
import QtQuick.Effects

StyledWindow {
    id: root

    required property DrawerVisibilities visibilities

    readonly property bool pickerActive: visibilities.wallpaperPicker

    name: "wallpaper-picker"

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.pickerActive ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: root.pickerActive ? null : emptyRegion

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    Region {
        id: emptyRegion
    }

    HyprlandFocusGrab {
        id: focusGrab

        active: root.pickerActive
        windows: [root]
        onCleared: root.visibilities.wallpaperPicker = false
    }

    // Full-screen dismiss area (clicks outside the panel)
    MouseArea {
        anchors.fill: parent
        visible: root.pickerActive
        onClicked: root.visibilities.wallpaperPicker = false
    }

    // ── Picker panel (centered) ───────────────────────────────────────────────
    Item {
        id: pickerPanel

        // Consume clicks so they don't reach the dismiss MouseArea
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        anchors.centerIn: parent

        width: Math.min(root.width * 0.72, 960)
        height: Math.min(root.height * 0.76, 675)

        opacity: root.pickerActive ? 1 : 0
        scale: root.pickerActive ? 1 : 0.95

        Behavior on opacity {
            Anim {}
        }

        Behavior on scale {
            Anim {
                type: Anim.DefaultSpatial
            }
        }

        StyledRect {
            anchors.fill: parent
            color: Colours.palette.m3surface
            opacity: 0.87
            radius: Tokens.rounding.large

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.padding.larger
                spacing: Tokens.spacing.normal

                // ── Header row ───────────────────────────────────────────────
                RowLayout {
                    spacing: Tokens.spacing.normal

                    MaterialIcon {
                        text: "folder_open"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.larger
                    }

                    StyledText {
                        text: qsTr("Choose Wallpaper")
                        font.pointSize: Tokens.font.size.larger
                        font.weight: 500
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Search field
                    StyledRect {
                        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                        radius: Tokens.rounding.full
                        implicitWidth: 220
                        implicitHeight: Math.max(searchIcon.implicitHeight, searchField.implicitHeight)

                        MaterialIcon {
                            id: searchIcon

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Tokens.padding.normal

                            text: "search"
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Tokens.font.size.normal
                        }

                        StyledTextField {
                            id: searchField

                            anchors.left: searchIcon.right
                            anchors.right: parent.right
                            anchors.rightMargin: Tokens.padding.normal
                            anchors.leftMargin: Tokens.spacing.small

                            topPadding: Tokens.padding.normal
                            bottomPadding: Tokens.padding.normal

                            placeholderText: qsTr("Search wallpapers…")

                            // ── Keyboard navigation ──────────────────────────
                            Keys.onEscapePressed: root.visibilities.wallpaperPicker = false

                            // Arrow keys navigate the grid while keeping search focused
                            Keys.onUpPressed: event => {
                                wallpaperGrid.moveCurrentIndexUp();
                                event.accepted = true;
                            }
                            Keys.onDownPressed: event => {
                                wallpaperGrid.moveCurrentIndexDown();
                                event.accepted = true;
                            }
                            Keys.onLeftPressed: event => {
                                wallpaperGrid.moveCurrentIndexLeft();
                                event.accepted = true;
                            }
                            Keys.onRightPressed: event => {
                                wallpaperGrid.moveCurrentIndexRight();
                                event.accepted = true;
                            }

                            // Enter/Return selects the currently highlighted grid item
                            Keys.onReturnPressed: selectCurrentItem()
                            Keys.onEnterPressed: selectCurrentItem()
                        }

                        Connections {
                            target: root.visibilities

                            function onWallpaperPickerChanged(): void {
                                if (root.visibilities.wallpaperPicker) {
                                    searchField.text = "";
                                    wallpaperGrid.currentIndex = 0;
                                    searchField.forceActiveFocus();
                                }
                            }
                        }
                    }
                }

                // ── Wallpaper grid ───────────────────────────────────────────
                GridView {
                    id: wallpaperGrid

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true

                    // Fixed 4 columns
                    readonly property int columnsCount: 4

                    cellWidth: width / columnsCount
                    cellHeight: 130 + Tokens.spacing.large

                    // Native keyboard navigation when the grid itself is focused
                    keyNavigationEnabled: true
                    keyNavigationWraps: false

                    model: ScriptModel {
                        values: Wallpapers.query(searchField.text)
                    }

                    // Reset index on search text changes so the cursor stays visible
                    onCountChanged: currentIndex = 0

                    StyledScrollBar.vertical: StyledScrollBar {
                        flickable: wallpaperGrid
                    }

                    // Enter/Return from within the grid when it has focus
                    Keys.onReturnPressed: selectCurrentItem()
                    Keys.onEnterPressed: selectCurrentItem()
                    Keys.onEscapePressed: root.visibilities.wallpaperPicker = false

                    delegate: Item {
                        id: delegate

                        required property var modelData
                        required property int index

                        // Whether this wallpaper is the active system wallpaper
                        readonly property bool isCurrent: delegate.modelData && delegate.modelData.path === Wallpapers.actualCurrent
                        // Whether this item is highlighted by keyboard navigation
                        readonly property bool isKeySelected: GridView.isCurrentItem // qmllint disable missing-property

                        readonly property real itemMargin: Tokens.spacing.large
                        readonly property real itemRadius: Tokens.rounding.normal

                        width: wallpaperGrid.cellWidth
                        height: wallpaperGrid.cellHeight

                        // Click to set wallpaper immediately
                        StateLayer {
                            anchors.fill: parent
                            anchors.margins: delegate.itemMargin
                            radius: delegate.itemRadius

                            onClicked: {
                                wallpaperGrid.currentIndex = delegate.index;
                                Wallpapers.setWallpaper(delegate.modelData.path);
                                root.visibilities.wallpaperPicker = false;
                            }
                        }

                        StyledClippingRect {
                            id: thumbRect

                            anchors.fill: parent
                            anchors.margins: delegate.itemMargin
                            color: Colours.tPalette.m3surfaceContainer
                            radius: delegate.itemRadius

                            CachingImage {
                                anchors.fill: parent
                                path: delegate.modelData.path
                                fillMode: Image.PreserveAspectCrop
                                smooth: !wallpaperGrid.moving
                                sourceSize: Qt.size(thumbRect.width * 2, thumbRect.height * 2)
                            }

                            // Gradient + filename label
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: filenameLabel.implicitHeight + Tokens.padding.normal * 2

                                gradient: Gradient {
                                    GradientStop {
                                        position: 0
                                        color: "transparent"
                                    }

                                    GradientStop {
                                        position: 1
                                        color: Qt.rgba(0, 0, 0, 0.65)
                                    }
                                }
                            }

                            StyledText {
                                id: filenameLabel

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: Tokens.padding.small
                                anchors.rightMargin: Tokens.padding.small
                                anchors.bottomMargin: Tokens.padding.small

                                text: delegate.modelData.relativePath
                                font.pointSize: Tokens.font.size.smaller
                                font.weight: 500
                                color: "white"
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                                renderType: Text.QtRendering
                            }
                        }

                        // ── Active-wallpaper border (primary colour) ─────────
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: delegate.itemMargin
                            color: "transparent"
                            radius: delegate.itemRadius + 2
                            border.width: delegate.isCurrent ? 2 : 0
                            border.color: Colours.palette.m3primary
                            antialiasing: true

                            Behavior on border.width {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }

                            MaterialIcon {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: Tokens.padding.small

                                visible: delegate.isCurrent
                                text: "check_circle"
                                fill: 1
                                color: Colours.palette.m3primary
                                font.pointSize: Tokens.font.size.large
                            }
                        }

                        // ── Keyboard-selection highlight (secondary colour) ──
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: delegate.itemMargin
                            color: "transparent"
                            radius: delegate.itemRadius + 2
                            border.width: delegate.isKeySelected && !delegate.isCurrent ? 2 : 0
                            border.color: Colours.palette.m3secondary
                            antialiasing: true

                            Behavior on border.width {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }
            }

            Behavior on color {
                CAnim {}
            }
        }
    }

    // ── Helper: select the keyboard-highlighted item ──────────────────────────
    function selectCurrentItem(): void {
        const item = wallpaperGrid.currentItem;
        if (item) {
            Wallpapers.setWallpaper(item.modelData.path);
            root.visibilities.wallpaperPicker = false;
        }
    }
}
