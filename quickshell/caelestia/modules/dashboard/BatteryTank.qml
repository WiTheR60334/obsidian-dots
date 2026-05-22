import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.services

StyledClippingRect {
        id: batteryTank

        property real percentage: UPower.displayDevice.percentage
        property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging
        property color accentColor: Colours.palette.m3primary
        property real animatedPercentage: 0

        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.large
        Component.onCompleted: animatedPercentage = percentage
        onPercentageChanged: animatedPercentage = percentage

        // Background Fill
        StyledRect {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * batteryTank.animatedPercentage
            color: Qt.alpha(batteryTank.accentColor, 0.15)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.small

            // Header Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: {
                        if (!UPower.displayDevice.isLaptopBattery) {
                            if (PowerProfiles.profile === PowerProfile.PowerSaver)
                                return "energy_savings_leaf";

                            if (PowerProfiles.profile === PowerProfile.Performance)
                                return "rocket_launch";

                            return "balance";
                        }
                        if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
                            return "battery_full";

                        const perc = UPower.displayDevice.percentage;
                        const charging = [UPowerDeviceState.Charging, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state);
                        if (perc >= 0.99)
                            return "battery_full";

                        let level = Math.floor(perc * 7);
                        if (charging && (level === 4 || level === 1))
                            level--;

                        return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
                    }
                    font.pointSize: Tokens.font.size.large
                    color: batteryTank.accentColor
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Battery")
                    font.pointSize: Tokens.font.size.normal
                    color: Colours.palette.m3onSurface
                }
            }

            Item {
                Layout.fillHeight: true
            }

            // Bottom Info Section
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -4

                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: `${Math.round(batteryTank.percentage * 100)}%`
                    font.pointSize: Tokens.font.size.extraLarge
                    font.weight: Font.Medium
                    color: batteryTank.accentColor
                }

                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: {
                        if (UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
                            return qsTr("Full");

                        if (batteryTank.isCharging)
                            return qsTr("Charging");

                        const s = UPower.displayDevice.timeToEmpty;
                        if (s === 0)
                            return qsTr("...");

                        const hr = Math.floor(s / 3600);
                        const min = Math.floor((s % 3600) / 60);
                        if (hr > 0)
                            return `${hr}h ${min}m`;

                        return `${min}m`;
                    }
                    font.pointSize: Tokens.font.size.smaller
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        Behavior on animatedPercentage {
            Anim {
                type: Anim.StandardLarge
            }
        }
    }
