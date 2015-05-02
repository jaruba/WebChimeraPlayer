import QtQuick 2.1
import QmlVlc 0.1

// Picture in Picture Feature
VlcVideoSurface {
	property alias vSource: vlcPlayer2;
	property alias hover: pipHover;
	property alias closeBut: pipCloseBut;

	property var pipTop: 0;
	property var pipRight: 0;
	property var pipHeight: 0;
	property var pipWidth: 0;
	property var pipVisible: false;
	property var hasMediaChanged: 1;
	property var instantPipButEffect: 0; // for settings button
	
	function keepMuted() {
		if (!vlcPlayer2.audio.mute) vlcPlayer2.audio.mute = true;
	}
	
	function playPip(pipItem) {
		vlcPlayer2.playlist.clear();
		for (var i = 0; i < vlcPlayer.playlist.itemCount; i++) vlcPlayer2.playlist.add(vlcPlayer.playlist.items[i].mrl);
		vlcPlayer2.playlist.playItem(pipItem);
		settings.pipClosed = false;
	}
	
	function pipResetPosition() {
		if (vlcPlayer.video.width > 0 && vlcPlayer.video.height > 0) {
			var iW = vlcPlayer2.video.width,
				iH = vlcPlayer2.video.height,
				iWc = vlcPlayer.video.width,
				iHc = vlcPlayer.video.height,
				oW = theview.width,
				oH = theview.height;
		
			if (fullscreen) var pipDiff = 4; else { if (theview.width < 700) var pipDiff = 3; else var pipDiff = 3.5; }
			
			if(oH/iHc > oW/iWc){
				pipTop = (oH - iHc*(oW/iWc)) /2;
				pipRight = 0;
			} else {
				pipTop = 0;
				pipRight = (oW - iWc*(oH/iHc)) /2;
			}
			if(oH/iH > oW/iW){
				pipHeight = iH*(oW/iW) / pipDiff;
				pipWidth = oW / pipDiff;
			} else {
				pipHeight = oH / pipDiff;
				pipWidth = iW*(oH/iH) / pipDiff;
			}
			pipVisible = true;
		}
	}
	
	function pipNewPosition() {
	
		if (settings.pip > 0) {
			var lastPipWidth = pipWidth;
			var lastPipHeight = pipHeight;
	
			if (vlcPlayer.video.width > 0 && vlcPlayer.video.height > 0) {
				var iW = vlcPlayer2.video.width,
					iH = vlcPlayer2.video.height,
					iWc = vlcPlayer.video.width,
					iHc = vlcPlayer.video.height,
					oW = theview.width,
					oH = theview.height;
			
				if (fullscreen) var pipDiff = 4; else { if (theview.width < 700) var pipDiff = 3; else var pipDiff = 3.5; }
				if(oH/iHc > oW/iWc){
					pipTop = (oH - iHc*(oW/iWc)) /2;
					pipRight = 0;
				} else {
					pipTop = 0;
					pipRight = (oW - iWc*(oH/iHc)) /2;
				}
				if(oH/iH > oW/iW){
					pipHeight = iH*(oW/iW) / pipDiff;
					pipWidth = oW / pipDiff;
				} else {
					pipHeight = oH / pipDiff;
					pipWidth = iW*(oH/iH) / pipDiff;
				}
	
				pipVisible = true;
			}
		}
	}
	
	function pipClicked() {
//		vlcPlayer.playlist.stop();
		vlcPlayer.swap(vlcPlayer2);
		vlcPlayer.audio.mute = false;
//		settings.pipClosed = true;
		if (videoSource.source == vlcPlayer) {
			videoSource.source = vlcPlayer2;
			root.source = vlcPlayer;
			if (settings.digitalzoom > 0) digiZoom.source = vlcPlayer2;
		} else {
			videoSource.source = vlcPlayer;
			root.source = vlcPlayer2;
			if (settings.digitalzoom > 0) digiZoom.source = vlcPlayer;
		}
		wjs.onMediaChanged();
		wjs.onState();
		
		if (settings.refreshTime) settings.refreshTime = false;
		else settings.refreshTime = true;
		
		if (settings.refreshPlaylistItems) settings.refreshPlaylistItems = false;
		else settings.refreshPlaylistItems = true;
		
		settings = settings;
		if (settings.digitalzoom > 0) {
			settings.digitalzoom = 1;
			digiZoom.zoomResetPosition();
			digiZoom.zoomNewPosition();
		}
		pipResetPosition();
		wjs.refreshMuteIcon();
	}
	
	function pipClose() {
		vlcPlayer2.playlist.stop();
		settings.pipClosed = true;
	}
	
    VlcPlayer {
        id: vlcPlayer2;
    }
	
	id: root;
	visible: settings.pipClosed ? false : settings.pip > 0 ? pipVisible : false;
	source: vlcPlayer2;
	anchors.top: parent.top;
	anchors.topMargin: pipTop;
	anchors.right: parent.right;
	anchors.rightMargin: pipRight;
	width: pipWidth;
	height: pipHeight;
	fillMode: VlcVideoSurface.PreserveAspectFit;
	
	Rectangle {
		color: "transparent"
		anchors.fill: parent
		Connections {
			target: vlcPlayer2
			onMediaPlayerMediaChanged: {
				if (settings.pip == 1) {
					pipVisible = false;
					hasMediaChanged = 1;
				}
			}
			onMediaPlayerPlaying: {
				if (hasMediaChanged == 1 && settings.pip == 1) {
					hasMediaChanged = 0;
					pipResetPosition();
				}
			}
		}
	}
	
	MouseArea {
		id: pipHover
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		anchors.fill: parent
		focus: true
		acceptedButtons: Qt.LeftButton
		onPressed: { pipClicked(); }
	}
	
	Rectangle {
		visible: pipHover.containsMouse ? true : pipCloseBut.containsMouse ? true : false
		
		opacity: pipHover.containsMouse ? pipCloseBut.containsMouse ? 1 : 0.6 : pipCloseBut.containsMouse ? 1 : 0
		
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.topMargin: 5
		anchors.rightMargin: 5
		color: "transparent"
		width: 20
		height: 20
		
		Behavior on visible { PropertyAnimation { duration: instantPipButEffect == 1 ? 0 : fullscreen ? 0: mousesurface.containsMouse ? 100 : 0 } }
		Behavior on opacity { PropertyAnimation { duration: instantPipButEffect == 1 ? 0 : fullscreen ? 0: 100 } }
		
		Text {
			anchors.centerIn: parent
			color: "#ffffff"
			text: settings.glyphsLoaded ? ui.icon.closePlaylist : ""
			font.family: fonts.icons.name
			font.pointSize: 14
			style: Text.Outline
			styleColor: "#000000"
		}
		MouseArea {
			id: pipCloseBut
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true
			anchors.fill: parent
			onClicked: pipClose();
		}

		Timer {
			interval: 50; running: instantPipButEffect == 1 ? true : false; repeat: false
			onTriggered: { instantPipButEffect = 0; }
		}
	}
}
// End Picture in Picture Feature
