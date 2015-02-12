import QtQuick 2.1
import QmlVlc 0.1

Text {
	anchors.left: mutebut.right
	anchors.leftMargin: mutebut.hover.containsMouse ? 131 + timeMargin : volumeMouse.dragger.containsMouse ? 131 + timeMargin : timeMargin
	opacity: vlcPlayer.time == 0 ? 0 : vlcPlayer.state > 1 ? 1 : 0
	font.pointSize: 9
	Behavior on anchors.leftMargin { PropertyAnimation { duration: 250} }
}