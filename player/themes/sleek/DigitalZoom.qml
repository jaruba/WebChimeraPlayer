import QtQuick 2.1
import QmlVlc 0.1

// Digital Zoom Feature
VlcVideoSurface {
	property alias preview: zoomPreview
	property alias mousepos: zoomArea

	property var zoomTop: 0;
	property var zoomLeft: 0;
	property var zoomHeight: 0;
	property var zoomWidth: 0;
	property var zoomVisible: false;
	property var hasMediaChanged: 1;
	property var zoomIsPressed: 0;
	property var lastMouseX: 0;
	property var lastMouseY: 0;
	
	function isFloat(n){
		return n===Number(n) && n%1!==0
	}
	
	function zoomResetPosition() {
		if (vlcPlayer.video.width > 0 && vlcPlayer.video.height > 0) {
			var iW = vlcPlayer.video.width,
				iH = vlcPlayer.video.height,
				oW = theview.width,
				oH = theview.height;
		
			if (fullscreen) var zoomDiff = 4; else { if (theview.width < 700) var zoomDiff = 3; else var zoomDiff = 3.5; }
			if(oH/iH > oW/iW){
				zoomTop = (oH - iH*(oW/iW)) /2;
				zoomLeft = 0;
				zoomHeight = iH*(oW/iW) / zoomDiff;
				zoomWidth = oW / zoomDiff;
			} else {
				zoomTop = 0;
				zoomLeft = (oW - iW*(oH/iH)) /2;
				zoomHeight = oH / zoomDiff;
				zoomWidth = iW*(oH/iH) / zoomDiff;
			}
			zoomVisible = true;
		}
		zoomPreview.width = root.width;
		zoomPreview.height = root.height;
		zoomPreview.anchors.leftMargin = 0;
		zoomPreview.anchors.topMargin = 0;
	}
	
	function zoomNewPosition() {
		if (settings.digitalzoom > 0) {
			var lastZoomWidth = zoomWidth;
			var lastZoomHeight = zoomHeight;
	
			if (vlcPlayer.video.width > 0 && vlcPlayer.video.height > 0) {
				var iW = vlcPlayer.video.width,
					iH = vlcPlayer.video.height,
					oW = theview.width,
					oH = theview.height;
			
				if (fullscreen) var zoomDiff = 4; else { if (theview.width < 700) var zoomDiff = 3; else var zoomDiff = 3.5; }
				if(oH/iH > oW/iW){
					zoomTop = (oH - iH*(oW/iW)) /2;
					zoomLeft = 0;
					zoomHeight = iH*(oW/iW) / zoomDiff;
					zoomWidth = oW / zoomDiff;
				} else {
					zoomTop = 0;
					zoomLeft = (oW - iW*(oH/iH)) /2;
					zoomHeight = oH / zoomDiff;
					zoomWidth = iW*(oH/iH) / zoomDiff;
				}
				zoomPreview.width = zoomPreview.width / (lastZoomWidth / zoomWidth);
				zoomPreview.height = zoomPreview.height / (lastZoomHeight / zoomHeight);
				zoomPreview.anchors.leftMargin = zoomPreview.anchors.leftMargin / (lastZoomWidth / zoomWidth);
				zoomPreview.anchors.topMargin = zoomPreview.anchors.topMargin / (lastZoomHeight / zoomHeight);
				
				lastMouseX = zoomPreview.anchors.leftMargin + (zoomPreview.width /2);
				lastMouseY = zoomPreview.anchors.topMargin + (zoomPreview.height /2);
				
				videoSource.scale.origin.x = ((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) * (videoSource.width / root.width)) + ((videoSource.width * (((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) - (root.width /2)) / root.width))/settings.digitalzoom);
				videoSource.scale.origin.y = ((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) * (videoSource.height / root.height)) + ((videoSource.height * (((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) - (root.height /2)) / root.height))/settings.digitalzoom);
				
				if (videoSource.scale.origin.x > videoSource.width) videoSource.scale.origin.x = videoSource.width;
				if (videoSource.scale.origin.y > videoSource.height) videoSource.scale.origin.y = videoSource.height;
		
				if (videoSource.scale.origin.x < 0) videoSource.scale.origin.x = 0;
				if (videoSource.scale.origin.y < 0) videoSource.scale.origin.y = 0;
	
				zoomVisible = true;
			}
		}
	}
	
	function zoomClicked(clicked) {
		if (zoomIsPressed == 1) {
			if ((zoomPreview.width < root.width && zoomPreview.height < root.height) || (zoomPreview.height < root.height || zoomPreview.height < root.height)) {
			
				lastMouseX = zoomArea.mouseX;
				lastMouseY = zoomArea.mouseY;

				if (fullscreen) var zoomDiff = 4; else { if (theview.width < 700) var zoomDiff = 3; else var zoomDiff = 3.5; }
				
				var iW = vlcPlayer.video.width,
					iH = vlcPlayer.video.height,
					oW = theview.width,
					oH = theview.height;
			
				if(oH/iH > oW/iW){
					var resizedHeight = iH*(oW/iW);
					var resizedWidth = oW;
				} else {
					var resizedHeight = oH;
					var resizedWidth = iW*(oH/iH);
				}
			
				if ((zoomArea.mouseX - (zoomPreview.width /2)) < 0) {
					zoomPreview.anchors.leftMargin = 0;
				} else if ((zoomArea.mouseX - (zoomPreview.width /2)) > (root.width - zoomPreview.width)) {
					zoomPreview.anchors.leftMargin = root.width - zoomPreview.width;
				} else {
					zoomPreview.anchors.leftMargin = zoomArea.mouseX - (zoomPreview.width /2);
				}
				if ((zoomArea.mouseY - (zoomPreview.height /2)) < 0) {
					zoomPreview.anchors.topMargin = 0;
				} else if ((zoomArea.mouseY - (zoomPreview.height /2)) > (root.height - zoomPreview.height)) {
					zoomPreview.anchors.topMargin = root.height - zoomPreview.height;
				} else {
					zoomPreview.anchors.topMargin = zoomArea.mouseY - (zoomPreview.height /2);
				}
				
				videoSource.scale.origin.x = ((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) * (videoSource.width / root.width)) + ((videoSource.width * (((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) - (root.width /2)) / root.width))/settings.digitalzoom);
				videoSource.scale.origin.y = ((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) * (videoSource.height / root.height)) + ((videoSource.height * (((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) - (root.height /2)) / root.height))/settings.digitalzoom);
				
				if (videoSource.scale.origin.x > videoSource.width) videoSource.scale.origin.x = videoSource.width;
				if (videoSource.scale.origin.y > videoSource.height) videoSource.scale.origin.y = videoSource.height;
		
				if (videoSource.scale.origin.x < 0) videoSource.scale.origin.x = 0;
				if (videoSource.scale.origin.y < 0) videoSource.scale.origin.y = 0;

			}
		}
	}
	
	function zoomScroll(mouseX,mouseY) {
	
		// Change Zoom on Mouse Scroll

		wjs.resetAspect();

		var lastZoomWidth = zoomPreview.width;
		var lastZoomHeight = zoomPreview.height;
		var moveZoom = 0;

		if (mouseY > 0) {
			if (settings.digitalzoom >= 1 && settings.digitalzoom < 10) settings.digitalzoom = settings.digitalzoom + 0.5;
			if (settings.digitalzoom == 1.5) {
			
				videoSource.scale.origin.x = (zoomArea.mouseX * (videoSource.width / root.width)) + ((videoSource.width * ((zoomArea.mouseX - (root.width /2)) / root.width))/settings.digitalzoom);
				videoSource.scale.origin.y = (zoomArea.mouseY * (videoSource.height / root.height)) + ((videoSource.height * ((zoomArea.mouseY - (root.height /2)) / root.height))/settings.digitalzoom);
				
				lastMouseX = zoomArea.mouseX;
				lastMouseY = zoomArea.mouseY;

				moveZoom = 1;

			} else {
				videoSource.scale.origin.x = ((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) * (videoSource.width / root.width)) + ((videoSource.width * (((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) - (root.width /2)) / root.width))/settings.digitalzoom);
				videoSource.scale.origin.y = ((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) * (videoSource.height / root.height)) + ((videoSource.height * (((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) - (root.height /2)) / root.height))/settings.digitalzoom);
			}

		} else if (mouseY < 0) {
			if (settings.digitalzoom > 1 && settings.digitalzoom <= 10) {
				settings.digitalzoom = settings.digitalzoom - 0.5;
				videoSource.scale.origin.x = ((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) * (videoSource.width / root.width)) + ((videoSource.width * (((zoomPreview.anchors.leftMargin + (zoomPreview.width/2)) - (root.width /2)) / root.width))/settings.digitalzoom);
				videoSource.scale.origin.y = ((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) * (videoSource.height / root.height)) + ((videoSource.height * (((zoomPreview.anchors.topMargin + (zoomPreview.height/2)) - (root.height /2)) / root.height))/settings.digitalzoom);
			}
		}

		if (settings.digitalzoom > 1 && settings.digitalzoom < 10) {
		
			if (theview.height/root.height > theview.width/root.width) {
				zoomPreview.width = root.width;
				zoomPreview.height = theview.height*(root.width/theview.width);
			} else {
				zoomPreview.height = root.height;
				zoomPreview.width = theview.width*(root.height/theview.height);
			}
				
			zoomPreview.width = zoomPreview.width / settings.digitalzoom;
			zoomPreview.height = zoomPreview.height / settings.digitalzoom;

		}
		
		if (settings.digitalzoom == 1) {
			videoSource.scale.origin.x = 1;
			videoSource.scale.origin.y = 1;
			zoomPreview.width = root.width;
			zoomPreview.height = root.height;
			zoomPreview.anchors.topMargin = 0;
			zoomPreview.anchors.leftMargin = 0;
		}

		if ((lastMouseX - (zoomPreview.width /2)) < 0) {
			zoomPreview.anchors.leftMargin = 0;
		} else if ((lastMouseX - (zoomPreview.width /2)) > (root.width - zoomPreview.width)) {
			zoomPreview.anchors.leftMargin = root.width - zoomPreview.width;
		} else {
			zoomPreview.anchors.leftMargin = lastMouseX - (zoomPreview.width /2);
		}
		if ((lastMouseY - (zoomPreview.height /2)) < 0) {
			zoomPreview.anchors.topMargin = 0;
		} else if ((lastMouseY - (zoomPreview.height /2)) > (root.height - zoomPreview.height)) {
			zoomPreview.anchors.topMargin = root.height - zoomPreview.height;
		} else {
			zoomPreview.anchors.topMargin = lastMouseY - (zoomPreview.height /2);
		}

		if (videoSource.scale.origin.x > videoSource.width) videoSource.scale.origin.x = videoSource.width;
		if (videoSource.scale.origin.y > videoSource.height) videoSource.scale.origin.y = videoSource.height;

		if (videoSource.scale.origin.x < 0) videoSource.scale.origin.x = 0;
		if (videoSource.scale.origin.y < 0) videoSource.scale.origin.y = 0;
					
		settings = settings;

		if (!isFloat(settings.digitalzoom)) wjs.setText("Digital Zoom: "+settings.digitalzoom+".0x");
		else wjs.setText("Digital Zoom: "+settings.digitalzoom+"x");

		// End Change Zoom on Mouse Scroll
	}
	
	id: root;
	visible: settings.digiZoomClosed ? false : settings.digitalzoom > 0 ? zoomVisible : false;
	source: vlcPlayer;
	anchors.top: parent.top;
	anchors.topMargin: zoomTop;
	anchors.left: parent.left;
	anchors.leftMargin: zoomLeft;
	width: zoomWidth;
	height: zoomHeight;
	fillMode: VlcVideoSurface.PreserveAspectFit
	
	Rectangle {
		id: zoomPreview
		color: "transparent"
		width: parent.width
		height: parent.height
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.topMargin: 0
		anchors.leftMargin: 0
		border.width: 1
		border.color: "#ffffff"
		Connections {
			target: vlcPlayer
			onMediaPlayerMediaChanged: {
				if (settings.digitalzoom >= 1) {
					lastMouseX = 0;
					lastMouseY = 0;
					settings.digitalzoom = 1;
					zoomVisible = false;
					hasMediaChanged = 1;
				}
			}
			onMediaPlayerPlaying: {
				if (hasMediaChanged == 1 && settings.digitalzoom >= 1) {
					settings.digitalzoom = 1;
					settings = settings;
					hasMediaChanged = 0;
					digiZoom.zoomResetPosition();
				}
			}
		}
	}
	
	MouseArea {
		id: zoomArea
		cursorShape: Qt.CrossCursor
		hoverEnabled: true
		anchors.fill: parent
		focus: true
		acceptedButtons: Qt.LeftButton
		onPressed: { zoomIsPressed = 1; zoomClicked(mouse.button); }
		onReleased: { zoomIsPressed = 0; zoomClicked(mouse.button); }
		onPositionChanged: zoomClicked(mouse.button);
		onWheel: zoomScroll(wheel.angleDelta.x,wheel.angleDelta.y);
	}
}
// End Digital Zoom Feature
