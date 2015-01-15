import QtQuick 2.1

Rectangle {
	property alias volColor: vol.color
	
	height: 8
	width: 116
	Rectangle {
		id: vol
		height: parent.height
		width: parent.width
		anchors.left: parent.left
	}
}
