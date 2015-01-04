import QtQuick 2.1
import QmlVlc 0.1

Rectangle {
	property alias icon: icon.text
	property alias iconSize: icon.font.pointSize
	property alias iconElem: icon
	property alias hover: mouseAreaButton
	signal buttonClicked
	signal buttonEntered
	signal buttonExited
	
	id: root
	height: parent.height
	width: 59
	color: 'transparent'
	Text {
		id: icon
		anchors.centerIn: parent
		font.family: fonts.icons.name
		color: mouseAreaButton.containsMouse ? buttonHoverColor : buttonNormalColor
	}
	MouseArea {
		id: mouseAreaButton
		cursorShape: toolbar.opacity == 1 ? Qt.PointingHandCursor : mousesurface.cursorShape
		anchors.fill: parent
		hoverEnabled: true
		onClicked: root.buttonClicked()
		onEntered: root.buttonEntered()
		onExited: root.buttonExited()
	}
}