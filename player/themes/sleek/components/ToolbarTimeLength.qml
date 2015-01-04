import QtQuick 2.1

Text {
	anchors.left: mutebut.right
	anchors.leftMargin: mutebut.hover.containsMouse ? 131 : volumeMouse.dragger.containsMouse ? 131 : 0
	font.pointSize: 9
	Behavior on anchors.leftMargin { PropertyAnimation { duration: 250} }
}