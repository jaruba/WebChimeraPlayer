import QtQuick 2.1

Rectangle {
	anchors.centerIn: parent
	width: playlistblock.width < 694 ? (playlistblock.width -12) : 682
	height: 272
	color: "transparent"
	clip: true
}