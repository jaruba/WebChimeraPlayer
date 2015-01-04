import QtQuick 2.1
import QmlVlc 0.1

// Draw Pause Icon (appears in center of screen when Toggle Pause)
Rectangle {
	property alias icon: icon.text
	property alias iconColor: icon.color

	anchors.centerIn: parent
	visible: false
	height: fullscreen ? gobigpause ? 170 : 85 : gobigpause ? 150 : 75
	width: fullscreen ? gobigpause ? 170 : 85 : gobigpause ? 150 : 75
	opacity: gobigpause ? 0 : 1
	radius: 10
	smooth: true
	
	// Start Play Icon Effect when Visible
	Behavior on height { PropertyAnimation { duration: 300 } }
	Behavior on width { PropertyAnimation { duration: 300 } }
	Behavior on opacity { PropertyAnimation { duration: 300 } }
	// End Play Icon Effect when Visible

	Text {
		id: icon
		anchors.centerIn: parent
		font.family: fonts.icons.name
		text: UI.icon.bigPause
		font.pointSize: fullscreen ? gobigpause ? 92 : 46 : gobigpause ? 72 : 36
		opacity: gobigplay ? 0 : 1

		// Start Play Icon Effect when Visible
		Behavior on font.pointSize { PropertyAnimation { duration: 300 } }
		Behavior on opacity { PropertyAnimation { duration: 300 } }
		// End Play Icon Effect when Visible
	}
	
	// Start Timer to Hide Big Pause Icon after 300ms
	Timer  {
		interval: 300; running: gobigpause ? true : false; repeat: false
		onTriggered: {
			pausetog.visible = false;
			gobigpause = false;
		}
	}
	// End Timer to Hide Big Pause Icon after 300ms
}
// End Draw Pause Icon (appears in center of screen when Toggle Pause)