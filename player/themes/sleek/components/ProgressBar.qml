import QtQuick 2.1
import QtQuick.Layouts 1.0
import QmlVlc 0.1

Rectangle {
	property alias backgroundColor: progressBackground.color
	property alias viewedColor: movepos.color
	property alias positionColor: curpos.color
	property alias dragpos: dragpos
	property alias effectDuration: effect.duration
	signal pressed(string mouseX, string mouseY)
	signal changed(string mouseX, string mouseY)
	signal released(string mouseX, string mouseY)
	
	id: root
	anchors.fill: parent
	color: "transparent"
	
	RowLayout {
		id: rowLayer
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.bottomMargin: multiscreen == 1 ? fullscreen ? 32 : -8 : fullscreen ? 32 : mousesurface.containsMouse ? 30 : 0 // Multiscreen - Edit
		opacity: multiscreen == 1 ? fullscreen ? vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1 : 0 : vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1 // Multiscreen - Edit
		Behavior on anchors.bottomMargin {
			PropertyAnimation {
				id: effect
				duration: multiscreen == 0 ? 250 : 0				
			}
		}
		Behavior on opacity { PropertyAnimation { duration: 250} }
		
		// Start Progress Bar Functionality (Time Chat Bubble, Seek)
		MouseArea {
			id: dragpos
			cursorShape: toolbar.opacity == 1 ? Qt.PointingHandCursor : mousesurface.cursorShape
			hoverEnabled: true
			anchors.fill: parent
			onPressed: root.pressed(mouse.x,mouse.y);
			onPositionChanged: root.changed(mouse.x,mouse.y);
			onReleased: root.released(mouse.x,mouse.y);
		}
		Rectangle {
			id: progressBackground
			Layout.fillWidth: true
			height: 8
			anchors.verticalCenter: parent.verticalCenter
			Rectangle {
				id: movepos
				width: dragging ? dragpos.mouseX -4 : (parent.width - anchors.leftMargin - anchors.rightMargin) * vlcPlayer.position
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.bottom: parent.bottom
			}
		}
		// End Progress Bar Functionality (Time Chat Bubble, Seek)
	}
	RowLayout {
		id: movecur
		spacing: 0
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.leftMargin: dragging ? dragpos.mouseX -4 > 0 ? dragpos.mouseX < parent.width -4 ? dragpos.mouseX -4 : parent.width -8 : 0 : (parent.width - anchors.rightMargin) * vlcPlayer.position > 0 ? (parent.width - anchors.rightMargin) * vlcPlayer.position < parent.width -8 ? (parent.width - anchors.rightMargin) * vlcPlayer.position : parent.width -8 : 0
		
		// Start Multiscreen - Edit
		anchors.bottomMargin: multiscreen == 1 ? fullscreen ? toolbar.height : -8 : fullscreen ? toolbar.height : mousesurface.containsMouse ? toolbar.height : 0
		opacity: multiscreen == 1 ? fullscreen ? vlcPlayer.time == 0 ? 0 : ismoving > 5 ? 0 : 1 : 0 : vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
		// End Multiscreen - Edit

		Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
		Behavior on opacity { PropertyAnimation { duration: 250} }
		Rectangle {
			Layout.fillWidth: true
			height: 8
			color: 'transparent'
			anchors.verticalCenter: parent.verticalCenter
			Rectangle {
				id: curpos
				height: 8
				width: 8
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.left: parent.left
			}
		}
	}
}