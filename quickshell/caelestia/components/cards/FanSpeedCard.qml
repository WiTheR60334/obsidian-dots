import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import Caelestia.Config
import qs.components

Rectangle {
    id: root

    width: 120
    height: 300
    radius: Tokens.rounding.large
    color: "#162322"

    property int cpuFan: 0
    property int gpuFan: 0
    property int maxRpm: 6000

    Process {
        id: fanProcess
        command: ["bash", "-c", "~/.config/hypr/scripts/fan.sh"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                if (parts.length >= 3) {
                    root.cpuFan = parseInt(parts[1])
                    root.gpuFan = parseInt(parts[2])
                    cpuGauge.requestPaint()
                    gpuGauge.requestPaint()
                }
                fanProcess.running = false
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fanProcess.running = true
    }

    function gaugeColor(value) {
        const percent = value / maxRpm
        if (percent < 0.4) return "#7ce0c3"
        if (percent < 0.7) return "#f2d06b"
        return "#ff7b7b"
    }

    // Outer item to vertically center the whole content block
    Item {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: 10

            // TITLE
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "Fan Speed"
                color: "#dfeceb"
                font.pointSize: Tokens.font.size.normal
                font.weight: Font.DemiBold
            }

            Item { Layout.preferredHeight: 2 }

            // CPU FAN
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 3

                    // Tinted fan icon (white)
                    ColorOverlay {
                        source: Image {
                            source: "file:///home/wither/.config/quickshell/caelestia/components/cards//fan-blades-icon.svg"
                            width: 16
                            height: 16
                            sourceSize: Qt.size(width, height)
                            smooth: true
                        }
                        color: "#ffffff"
                        width: 16
                        height: 16
                    }

                    StyledText {
                        text: " CPU Fan"
                        color: "#c6d7d4"
                        font.pointSize: Tokens.font.size.small
                        font.weight: Font.Medium
                    }
                }

                Item {
                    Layout.topMargin: 10
                    width: 78
                    height: 78

                    Canvas {
                        id: cpuGauge
                        anchors.fill: parent
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            const centerX = width / 2
                            const centerY = height / 2
                            const radius = 35
                            const percent = Math.min(root.cpuFan / root.maxRpm, 1)

                            ctx.beginPath()
                            ctx.lineWidth = 8
                            ctx.strokeStyle = "#233533"
                            ctx.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * 2.25)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.lineWidth = 8
                            ctx.lineCap = "round"
                            ctx.strokeStyle = root.gaugeColor(root.cpuFan)
                            ctx.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * (0.75 + 1.5 * percent))
                            ctx.stroke()
                        }
                    }

                    // Stacked text: value above "RPM"
                    Item {
                        anchors.centerIn: parent
                        width: 60
                        height: 52

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            StyledText {
                                text: root.cpuFan
                                color: "white"
                                font.pointSize: Tokens.font.size.normal
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: 8
                            }
                            StyledText {
                                text: "RPM"
                                color: "#70817e"
                                font.pointSize: Tokens.font.size.smaller - 1
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            // DIVIDER
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                height: 1
                radius: 999
                color: "#324240"
                opacity: 0.35
            }

            // GPU FAN
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 3

                    // Tinted fan icon (white)
                    ColorOverlay {
                        source: Image {
                            source: "file:///home/wither/.config/quickshell/caelestia/components/cards//fan-blades-icon.svg"
                            width: 16
                            height: 16
                            sourceSize: Qt.size(width, height)
                            smooth: true
                        }
                        color: "#ffffff"
                        width: 16
                        height: 16
                    }

                    StyledText {
                        text: " GPU Fan"
                        color: "#c6d7d4"
                        font.pointSize: Tokens.font.size.small
                        font.weight: Font.Medium
                    }
                }

                Item {
                    Layout.topMargin: 10
                    width: 78
                    height: 78

                    Canvas {
                        id: gpuGauge
                        anchors.fill: parent
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            const centerX = width / 2
                            const centerY = height / 2
                            const radius = 35
                            const percent = Math.min(root.gpuFan / root.maxRpm, 1)

                            ctx.beginPath()
                            ctx.lineWidth = 8
                            ctx.strokeStyle = "#233533"
                            ctx.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * 2.25)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.lineWidth = 8
                            ctx.lineCap = "round"
                            ctx.strokeStyle = root.gaugeColor(root.gpuFan)
                            ctx.arc(centerX, centerY, radius, Math.PI * 0.75, Math.PI * (0.75 + 1.5 * percent))
                            ctx.stroke()
                        }
                    }

                    // Stacked text: value above "RPM"
                    Item {
                        anchors.centerIn: parent
                        width: 60
                        height: 52

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            StyledText {
                                text: root.gpuFan   // FIXED: was root.cpuFan
                                color: "white"
                                font.pointSize: Tokens.font.size.normal
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                topPadding: 8
                            }
                            StyledText {
                                text: "RPM"
                                color: "#70817e"
                                font.pointSize: Tokens.font.size.smaller - 1
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            // STATUS
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                readonly property int avgFan: (root.cpuFan + root.gpuFan) / 2
                text: avgFan > 3500 ? "Turbo" : (avgFan > 2000 ? "Normal" : "Quiet")
                color: avgFan > 3500 ? "#ff7b7b" : (avgFan > 2000 ? "#f2d06b" : "#7ce0c3")
                font.pointSize: Tokens.font.size.Medium
                font.weight: Font.DemiBold
                opacity: 0.95
            }
        }
    }
}