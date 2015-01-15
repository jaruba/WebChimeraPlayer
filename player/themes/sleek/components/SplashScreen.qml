import QtQuick 2.1
import QmlVlc 0.1

Rectangle {
	property alias fontColor: openingtext.color
	property alias fontShadow: loadingFont.styleColor
	property alias iconOpacity: playerlogo.opacity
	property alias changeText: loadingFont.text
	signal logoEffect

	id: root
	anchors.fill: parent
	visible: vlcPlayer.state < 3 ? true : false
	// If Playlist is Open Show Top Text
	Text {
		id: openingtext
		visible: playlistmenu
		anchors.top: parent.top
		anchors.topMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		text: "Opening"
		font.pointSize: 15
	}
	// End If Playlist is Open Show Top Text

	Rectangle {
		anchors.centerIn: parent
		width: 1
		height: multiscreen == 1 ? fullscreen ? 100 : 76 : 100 // Required for Multiscreen
		color: "transparent"
		Rectangle {
			Image {
				anchors.top: parent.top
				anchors.horizontalCenter: parent.horizontalCenter
				source: "http://webchimera.org/images/player/player_logo_small.png"
			}
			Image {
				id: playerlogo
				anchors.top: parent.top
				anchors.horizontalCenter: parent.horizontalCenter
				opacity: 0
				Behavior on opacity { PropertyAnimation { duration: 600} }
				source: "http://webchimera.org/images/player/player_logo_small_h.png"
			}
			Text {
				id: loadingFont
				visible: multiscreen == 1 ? fullscreen ? vlcPlayer.state == 1 ? true : buffering > 0 && buffering < 100 ? true : false : false : vlcPlayer.state == 1 ? true : buffering > 0 && buffering < 100 ? true : false // Required for Multiscreen
				anchors.top: parent.top
				anchors.topMargin: 80
				anchors.horizontalCenter: parent.horizontalCenter
				text: "Loading Resource"
				font.pointSize: fullscreen ? 14 : 13
				font.weight: Font.DemiBold
				color: openingtext.color
				style: Text.Outline
				styleColor: UI.colors.fontShadow
			}
			// Start Loading Logo Fade Effect
			Timer {
				interval: 700; running: true; repeat: true
				onTriggered: root.logoEffect();
			}
			// End Loading Logo Fade Effect
		}
	}
}