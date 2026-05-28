pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    property string source: Wallpapers.current
    property Item current: one
    property bool completed

    // Read the selected animation type from config (default: "zoom")
    readonly property string animType: Config.background.wallpaperTransition ?? "fade"

    onSourceChanged: {
        if (!source)
            current = null;
        else if (current === one)
            two.update();
        else
            one.update();
    }

    Component.onCompleted: {
        if (source)
            Qt.callLater(() => {
                one.update();
                completed = true;
            });
    }

    Loader {
        asynchronous: true
        anchors.fill: parent

        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Tokens.spacing.large

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.extraLarge * 5
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.extraLarge * 2
                        font.bold: true
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Tokens.padding.large * 2
                        implicitHeight: selectWallText.implicitHeight + Tokens.padding.small * 2

                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary
                            onClicked: dialog.open()
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Tokens.font.size.large
                        }
                    }
                }
            }
        }
    }

    Img { id: one }
    Img { id: two }

    // ─────────────────────────────────────────────────────────────────────────
    // Img component — wraps CachingImage and drives all transition animations
    // via four animatable proxy properties so we never fight anchors.fill.
    // ─────────────────────────────────────────────────────────────────────────
    component Img: Item {
        id: img

        // Public surface used by the outer Item
        property alias path: inner.path
        property alias status: inner.status

        function update(): void {
            if (path === root.source)
                root.current = this;
            else
                path = root.source;
        }

        // ── Proxy animation properties ────────────────────────────────────
        // All four start at their "hidden" defaults; the "visible" State
        // drives them to their resting values (0 / 0 / 1 / 0).
        property real animOpacity: 0
        property real animTX: 0          // horizontal translation (px)
        property real animTY: 0          // vertical   translation (px)
        property real animScale: 1       // uniform scale
        property real animRotation: 0    // Z rotation in degrees

        // Fill parent — no conflicts because we translate/scale via transform
        width: parent.width
        height: parent.height

        // Compose the per-frame transform
        transform: [
            Rotation {
                angle: img.animRotation
                origin.x: img.width  / 2
                origin.y: img.height / 2
            },
            Scale {
                xScale: img.animScale
                yScale: img.animScale
                origin.x: img.width  / 2
                origin.y: img.height / 2
            },
            Translate {
                x: img.animTX
                y: img.animTY
            }
        ]

        opacity: img.animOpacity

        CachingImage {
            id: inner
            anchors.fill: parent

            onStatusChanged: {
                if (status === Image.Ready)
                    root.current = img;
            }
        }

        // ── State ─────────────────────────────────────────────────────────
        states: State {
            name: "visible"
            when: root.current === img

            PropertyChanges {
                img.animOpacity:  1
                img.animTX:       0
                img.animTY:       0
                img.animScale:    1
                img.animRotation: 0
            }
        }

        // ── Transitions ───────────────────────────────────────────────────
        transitions: [

            // ── ENTERING: new wallpaper appears ──────────────────────────
            Transition {
                from: ""
                to: "visible"

                SequentialAnimation {
                    // Let the outgoing image start fading first
                    PauseAnimation { duration: 150}

                    ParallelAnimation {

                        // Opacity — all modes
                        NumberAnimation {
                            target: img
                            property: "animOpacity"
                            from: 0
                            to: 1
                            duration: root.animType === "fade" ? 1800 : 1800
                            easing.type: Easing.InOutQuad
                        }

                        // ── ZOOM BLOOM: scale from 1.08 → 1.00 ──────────
                        NumberAnimation {
                            target: img
                            property: "animScale"
                            from: (root.animType === "zoom" || root.animType === "spin")
                                  ? 1.08 : 1.0
                            to: 1.0
                            duration: 950
                            easing.type: Easing.OutExpo
                        }

                        // ── SLIDE: push in from the right ────────────────
                        NumberAnimation {
                            target: img
                            property: "animTX"
                            from: root.animType === "slide" ? img.width : 0
                            to: 0
                            duration: 680
                            easing.type: Easing.OutCubic
                        }

                        // ── RISE: lift up from below ─────────────────────
                        NumberAnimation {
                            target: img
                            property: "animTY"
                            from: root.animType === "rise" ? img.height * 0.18 : 0
                            to: 0
                            duration: 700
                            easing.type: Easing.OutCubic
                        }

                        // ── SPIN: counter-clockwise twist in ─────────────
                        NumberAnimation {
                            target: img
                            property: "animRotation"
                            from: root.animType === "spin" ? -7 : 0
                            to: 0
                            duration: 820
                            easing.type: Easing.OutBack
                        }
                    }
                }
            },

            // ── LEAVING: old wallpaper exits ─────────────────────────────
            Transition {
                from: "visible"
                to: ""

                ParallelAnimation {

                    // Opacity — all modes fade out
                    NumberAnimation {
                        target: img
                        property: "animOpacity"
                        from: 1
                        to: 0
                        duration: root.animType === "fade" ? 1800 : 1800
                        easing.type: Easing.InOutQuad
                    }

                    // ZOOM / SPIN: scale drifts back to 1.06 as it fades
                    NumberAnimation {
                        target: img
                        property: "animScale"
                        from: 1.0
                        to: (root.animType === "zoom" || root.animType === "spin")
                             ? 1.06 : 1.0
                        duration: 500
                        easing.type: Easing.InQuad
                    }

                    // SLIDE: exit to the left
                    NumberAnimation {
                        target: img
                        property: "animTX"
                        from: 0
                        to: root.animType === "slide" ? -img.width * 0.28 : 0
                        duration: 420
                        easing.type: Easing.InCubic
                    }

                    // RISE: exit upward
                    NumberAnimation {
                        target: img
                        property: "animTY"
                        from: 0
                        to: root.animType === "rise" ? -img.height * 0.15 : 0
                        duration: 420
                        easing.type: Easing.InCubic
                    }

                    // SPIN: clockwise drift on exit
                    NumberAnimation {
                        target: img
                        property: "animRotation"
                        from: 0
                        to: root.animType === "spin" ? 4 : 0
                        duration: 420
                        easing.type: Easing.InCubic
                    }
                }
            }
        ]
    }
}
