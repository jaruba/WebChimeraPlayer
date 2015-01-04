import QtQuick 2.1
import QmlVlc 0.1

Rectangle {
	id: root
	anchors.top: parent.top
	anchors.topMargin: 0
	width: playlistblock.width < 694 ? (playlistblock.width -12) : 682
	height: 272
	color: "transparent"

	function setYoutubeTitle(xhr,pli) {
		return function() {
			if (xhr.readyState == 4) {
				var plstring = xhr.responseText;
				plstring = plstring.substr(plstring.indexOf('"title":"')+9);
				plstring = plstring.substr(0,plstring.indexOf('"'));
		
				vlcPlayer.playlist.items[pli].title = "[custom]"+plstring;
								
				addPlaylistItems();
			}
		};
	}
	
	function addPlaylistItems() {
		// Adding Playlist Menu Items
		var pli = 0;
		for (pli = 0; pli < vlcPlayer.playlist.itemCount; pli++) {
			var plstring = vlcPlayer.playlist.items[pli].title.replace("[custom]","");
			plstring = unescape(plstring);
			plstring = plstring.split('_').join(' ');
			plstring = plstring.split('  ').join(' ');
			plstring = plstring.split('  ').join(' ');
			plstring = plstring.split('  ').join(' ');
			if (plstring.indexOf("youtube.com") > 0) {
				var youtubeID =	plstring.substr(plstring.lastIndexOf("/")+1).replace("watch?v=","");
				if (youtubeID.indexOf("&") > 0) youtubeID =	youtubeID.substr(0,youtubeID.IndexOf("&"));
				var xhr = new XMLHttpRequest;
				xhr.onreadystatechange = setYoutubeTitle(xhr,pli);
				xhr.open("get", 'http://gdata.youtube.com/feeds/api/videos/'+youtubeID+'?v=2&alt=jsonc', true);
				xhr.send();
			} else {
		
				if (plstring.indexOf("/") > 0) {
					plstring = unescape(plstring);
					plstring = plstring.substr(plstring.lastIndexOf("/")+1);
				}
				if (plstring.split('.').pop().length == 3) {
					plstring = plstring.slice(0, -4);
					vlcPlayer.playlist.items[pli].title = "[custom]"+plstring;
				}
				if (plstring.length > 85) plstring = plstring.substr(0,85) +'...';
		
				Qt.createQmlObject('import QtQuick 2.1; import QtQuick.Layouts 1.0; import QmlVlc 0.1; Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.topMargin: 32 + ('+ pli +' *40); color: "transparent"; width: playlistblock.width < 694 ? (playlistblock.width -56) : 638; height: 40; MouseArea { id: pitem'+ pli +'; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; anchors.fill: parent; onClicked: vlcPlayer.playlist.playItem('+ pli +'); } Rectangle { width: playlistblock.width < 694 ? (playlistblock.width -56) : 638; clip: true; height: 40; color: vlcPlayer.state == 1 ? vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#3D3D3D" : "#e5e5e5" : pitem'+ pli +'.containsMouse ? "#3D3D3D" : "transparent" : vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#3D3D3D" : "#e5e5e5" : pitem'+ pli +'.containsMouse ? "#3D3D3D" : "transparent"; Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "'+ plstring +'"; font.pointSize: 10; color: vlcPlayer.state == 1 ? vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5" : vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5"; } } }', root, 'plmenustr' +pli);
			}
		}
		// End Adding Playlist Menu Items
	}
	// This is where the Playlist Items will be loaded
}
