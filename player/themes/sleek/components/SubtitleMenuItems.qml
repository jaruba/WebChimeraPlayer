import QtQuick 2.1
import QmlVlc 0.1

Rectangle {
	id: root
	anchors.top: parent.top
	anchors.topMargin: 0
	width: subMenublock.width < 694 ? (subMenublock.width -12) : 682
	height: 272
	color: "transparent"
	property var subPlaying: 0;

	// Start External Subtitles (SRT, SUB)
	function strip(s) {
		return s.replace(/^\s+|\s+$/g,"");
	}
	function playSubtitles(subtitleElement) {
		if (typeof(currentSubtitle) != "undefined") currentSubtitle = -1;
		if (typeof(subtitles) != "undefined") if (subtitles.length) subtitles = {};
		var xhr = new XMLHttpRequest;
		xhr.onreadystatechange = function() {
			if (xhr.readyState == 4) {
	
				var srt = xhr.responseText;
				subtitles = {};
				
				var extension = subtitleElement.split('.').pop();
				if (extension.toLowerCase() == "srt") {
					srt = srt.replace(/\r\n|\r|\n/g, '\n');
					
					srt = strip(srt);
					var srty = srt.split('\n\n');
	
					var s = 0;
					for (s = 0; s < srty.length; s++) {
						var st = srty[s].split('\n');
						if (st.length >=2) {
					
						  var n = st[0];
						  var is = Math.round(toSeconds(strip(st[1].split(' --> ')[0])));
						  var os = Math.round(toSeconds(strip(st[1].split(' --> ')[1])));
						  var t = st[2];
						  
						  if( st.length > 2) {
							var j = 3;
							for (j=3; j<st.length; j++) {
								t = t + '\n'+st[j];
							}
	
						  }
						  subtitles[is] = {i:is, o: os, t: t};
						}
					}
				} else if (extension.toLowerCase() == "sub") {
					srt = srt.replace(/\r\n|\r|\n/g, '\n');
					
					srt = strip(srt);
					var srty = srt.split('\n');
	
					var s = 0;
					for (s = 0; s < srty.length; s++) {
						var st = srty[s].split('}{');
						if (st.length >=2) {
						  var is = Math.round(st[0].substr(1) /10);
						  var os = Math.round(st[1].split('}')[0] /10);
						  var t = st[1].split('}')[1].replace('|', '\n');
						  if (is != 1 && os != 1) subtitles[is] = {i:is, o: os, t: t};
						}
					}
				}
				currentSubtitle = -1;
			}
		}
		xhr.open("get", subtitleElement);
		xhr.setRequestHeader("Content-Encoding", "UTF-8");
		xhr.send();
	}
	// End External Subtitles (SRT, SUB)
	
	
	// Start Clear External Subtitles (SRT, SUB)
	function clearSubtitles() {
		subtitlebox.changeText = "";
		currentSubtitle = -2;
		subtitles = [];
	}
	// End Clear External Subtitles (SRT, SUB)

	function addSubtitleItems(target) {
		// Adding Subtitle Menu Items
		var plstring = "None";
		var pli = 0;
		
		Qt.createQmlObject('import QtQuick 2.1; import QtQuick.Layouts 1.0; import QmlVlc 0.1; Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.topMargin: 32 + ('+ pli +' *40); color: "transparent"; width: subMenublock.width < 694 ? (subMenublock.width -56) : 638; height: 40; MouseArea { id: sitem'+ pli +'; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; anchors.fill: parent; onClicked: { clearSubtitles(); subPlaying = '+ pli +'; } } Rectangle { width: subMenublock.width < 694 ? (subMenublock.width -56) : 638; clip: true; height: 40; color: vlcPlayer.state == 1 ? subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#3D3D3D" : "#e5e5e5" : sitem'+ pli +'.containsMouse ? "#3D3D3D" : "transparent" : subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#3D3D3D" : "#e5e5e5" : sitem'+ pli +'.containsMouse ? "#3D3D3D" : "transparent"; Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "'+ plstring +'"; font.pointSize: 10; color: vlcPlayer.state == 1 ? subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5" : subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5"; } } }', root, 'smenustr' +pli);

		for (var k in target) if (target.hasOwnProperty(k)) {
			pli++;
			var plstring = k;
			if (plstring.length > 85) plstring = plstring.substr(0,85) +'...';
			var slink = target[k];
			
 			Qt.createQmlObject('import QtQuick 2.1; import QtQuick.Layouts 1.0; import QmlVlc 0.1; Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.topMargin: 32 + ('+ pli +' *40); color: "transparent"; width: subMenublock.width < 694 ? (subMenublock.width -56) : 638; height: 40; MouseArea { id: sitem'+ pli +'; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; anchors.fill: parent; onClicked: { playSubtitles("'+ slink +'"); subPlaying = '+ pli +'; } } Rectangle { width: subMenublock.width < 694 ? (subMenublock.width -56) : 638; clip: true; height: 40; color: vlcPlayer.state == 1 ? subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#3D3D3D" : "#e5e5e5" : sitem'+ pli +'.containsMouse ? "#3D3D3D" : "transparent" : subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#3D3D3D" : "#e5e5e5" : sitem'+ pli +'.containsMouse ? "#3D3D3D" : "transparent"; Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "'+ plstring +'"; font.pointSize: 10; color: vlcPlayer.state == 1 ? subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5" : subPlaying == '+ pli +' ? sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : sitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5"; } } }', root, 'smenustr' +pli);
			
		}
		pli++;
		totalSubs = pli;
		// End Adding Subtitle Menu Items
	}
	// This is where the Subtitle Items will be loaded
}
