// if page on local machine, add warning
var localwarning = '<div id="warning-wrapper"><div id="lwarning" class="btn">QML File cannot be loaded from your Local Machine! Upload the Demo on a Web server to see it working correctly!</div></div>';
switch(window.location.protocol) {
   case 'http:': break;
   case 'https:': break;
   case 'file:':
     document.body.innerHTML += localwarning;
     break;
   default: 
     document.body.innerHTML += localwarning;
}
// end if page on local machine, add warning

// only implement if no native isArray implementation is available (for backward compatibility with old browsers)
if (typeof Array.isArray === 'undefined') {
  Array.isArray = function(obj) {
    return Object.toString.call(obj) === '[object Array]';
  }
};
// end backward compatibility isArray

function addPlayer(targetdiv,qmlsource,playerid) {
	qmlsource = (typeof qmlsource === "undefined") ? "http://jaruba.github.io/WebchimeraGUI/qml/default.qml" : qmlsource; // if no qmlsource set, default to latest Webchimera Player Default QML
	playerid = (typeof playerid === "undefined") ? "webchimera" : playerid; // if no playerid set, default to "webchimera"

	var playerbody = "";
	playerbody += '<object id="' + playerid + '" type="application/x-chimera-plugin" width="100%" height="100%">';
	playerbody += '<param name="qmlsrc" value="' + qmlsource + '" />';
	playerbody += '</object>';
	document.getElementById(targetdiv).innerHTML = playerbody;
//	container.appendChild(embed);
	
}

// function to add playlist items
function addPlaylist(playlist, playerid) {
	 playerid = (typeof playerid === "undefined") ? "webchimera" : playerid; // if no playerid set, default to "webchimera"
     var videoelem = document.getElementById(playerid);
	 if (typeof playlist === 'string') {
		 videoelem.playlist.add(playlist); // if Playlist has one Element
	 } else {
		 if (Array.isArray(playlist) === true && Array.isArray(playlist[0]) === true) {
			 // if Playlist has Custom Titles
			 for (item = 0; item < playlist.length; item++) {
				  videoelem.playlist.items[item].mrl = playlist[item][0];
				  if (typeof playlist[item][1] !== 'undefined' && typeof playlist[item][1] === 'string') videoelem.playlist.items[item].title = playlist[item][1];
			 }
			 // end if Playlist has Custom Titles
		 } else if (Array.isArray(playlist) === true) {
			 for (item = 0; typeof playlist[item] !== 'undefined'; item++) videoelem.playlist.items[item].mrl = playlist[item]; // if Playlist is Array
		 }
	 }
}
// end function to add playlist items

// function to Start Playback
function startPlayer(playerid) {
	playerid = (typeof playerid === "undefined") ? "webchimera" : playerid;  // if no playerid set, default to "webchimera"
    var videoelem = document.getElementById(playerid);
    videoelem.playlist.setCurrentItem(0); // Set Current Item to first
    videoelem.playlist.play(); // Play Current Item
    videoelem.playlist.Normal; // Set Normal Playback (options: Normal, Loop, Single)
}
// end function to Start Playback