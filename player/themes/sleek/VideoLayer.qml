import QtQuick 2.1
import QmlVlc 0.1

// Declare Video Layer
VlcVideoSurface {
	property alias scale: zoomScale

	source: vlcPlayer;
	anchors.centerIn: parent;
	anchors.top: parent.top;
	anchors.left: parent.left;
	width: parent.width;
	height: parent.height;
	fillMode: VlcVideoSurface.PreserveAspectFit
	onWidthChanged: { digiZoom.zoomNewPosition(); pip.pipNewPosition(); }
	onHeightChanged: { digiZoom.zoomNewPosition(); pip.pipNewPosition(); }
	transform: Scale {
		id: zoomScale
		origin.x: 1;
		origin.y: 1;
		xScale: settings.digitalzoom == 0 ? 1 : settings.digitalzoom;
		yScale: settings.digitalzoom == 0 ? 1 : settings.digitalzoom;
	}
}
// End Video Layer