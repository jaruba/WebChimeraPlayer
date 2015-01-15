import QtQuick 2.1
import QmlVlc 0.1

Rectangle {
	width: parent.width
	anchors.bottom: parent.bottom
	anchors.bottomMargin: fullscreen ? 0 : parent.containsMouse ? 0 : -height
	color: "transparent"
	visible: multiscreen == 1 ? fullscreen ? true : false : true // Multiscreen - Edit
	opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
	Behavior on anchors.bottomMargin { PropertyAnimation { duration: multiscreen == 0 ? 250 : 0 } }
	Behavior on opacity { PropertyAnimation { duration: 250 } }
}