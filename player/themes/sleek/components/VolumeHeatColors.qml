import QtQuick 2.1

Rectangle {
	property alias volLow: volLow.color
	property alias volMed: volMed.color
	property alias volHigh: volHigh.color
	
	height: 8
	width: 116
	color: "transparent"
	
	Rectangle {
		height: parent.width
		width: parent.height
		anchors.centerIn: parent
		rotation: 90
		gradient: Gradient {
			GradientStop { id: volHigh; position: 0.0; color: "transparent" }
			GradientStop { id: volMed; position: 0.5; color: "transparent" }
			GradientStop { id: volLow; position: 1.0; color: "transparent" }
		}
	}
}
