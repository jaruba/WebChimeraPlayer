import QtQuick 2.1

Rectangle {
	clip: true
	height: parent.height
	width: mutebut.hover.containsMouse ? 120 : volumeMouse.dragger.containsMouse ? 120 : 0
	anchors.verticalCenter: parent.verticalCenter
	color: 'transparent'
	Behavior on width { PropertyAnimation { duration: 250} }
}
