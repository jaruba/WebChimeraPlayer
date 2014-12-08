// if page on local machine, add warning
var websiteishttps = 0;
var localwarning = '<div id="warning-wrapper"><div id="lwarning" class="btn">QML File cannot be loaded from your Local Machine! Upload the Demo on a Web server to see it working correctly.</div></div>';
switch(window.location.protocol) {
   case 'http:': break;
   case 'https:':
     websiteishttps = 0;
	 break;
   case 'file:':
     document.body.innerHTML += localwarning;
     break;
   default: 
     document.body.innerHTML += localwarning;
}
// end if page on local machine, add warning

// function to Load QML File in Javascript and send the QML String to WebChimera
function getFromUrl(urlstring, playerid) {
	playerid = (typeof playerid === "undefined") ? "webchimera" : playerid; // if no playerid set, default to "webchimera"
	var videoelem = document.getElementById(playerid);

	var xmlhttp;
	if (window.XMLHttpRequest) { // code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp = new XMLHttpRequest();
	}
	else { // code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			videoelem.qml = xmlhttp.responseText;
		}
	}
	xmlhttp.open("GET", urlstring, true);
	xmlhttp.send();
}
// End function to Load QML File in Javascript and send the QML String to WebChimera

// only implement if no native isArray implementation is available (for backward compatibility with old browsers)
if (typeof Array.isArray === 'undefined') {
  Array.isArray = function(obj) {
    return Object.toString.call(obj) === '[object Array]';
  }
};
// end backward compatibility isArray

function addPlayer(targetdiv,qmlsource,playerid) {
	qmlsource = (typeof qmlsource === "undefined") ? "http://www.webchimera.org/qml/default.qml" : qmlsource; // if no qmlsource set, default to latest Webchimera Player Default QML
	playerid = (typeof playerid === "undefined") ? "webchimera" : playerid; // if no playerid set, default to "webchimera"

	var playerbody = "";
	playerbody += '<object id="' + playerid + '" type="application/x-chimera-plugin" width="100%" height="100%">';
	if (websiteishttps == 1) {
		// if QML Source is using SSL
		setTimeout(getFromUrl(qmlsource,playerid),10); // Load QML File as String with JavaScript
		playerbody += '<param name="qmlsrc" value="" />';
		// End if QML Source is using SSL
	} else {
		if (playlist.substring(0, 7) != "http://") {
			// if QML Source is using SSL
			setTimeout(getFromUrl(qmlsource,playerid),10); // Load QML File as String with JavaScript
			playerbody += '<param name="qmlsrc" value="" />';
			// End if QML Source is using SSL
		} else {
			playerbody += '<param name="qmlsrc" value="' + qmlsource + '" />'; // if QML Source is not using SSL
		}
	}
	playerbody += '</object>';
	document.getElementById(targetdiv).innerHTML = playerbody;
	
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
				  videoelem.playlist.add(playlist[item][0]);
				  if (typeof playlist[item][1] !== 'undefined' && typeof playlist[item][1] === 'string') videoelem.playlist.items[item].title = "[custom]"+playlist[item][1];
			 }
			 // end if Playlist has Custom Titles
		 } else if (Array.isArray(playlist) === true) {
			 for (item = 0; typeof playlist[item] !== 'undefined'; item++) videoelem.playlist.add(playlist[item]); // if Playlist is Array
		 }
	 }
}
// end function to add playlist items

// function to Start Playback
function startPlayer(playerid) {
	playerid = (typeof playerid === "undefined") ? "webchimera" : playerid;  // if no playerid set, default to "webchimera"
    var videoelem = document.getElementById(playerid);
    videoelem.playlist.playItem(0); // Play Current Item
    videoelem.playlist.Normal; // Set Normal Playback (options: Normal, Loop, Single)
}
// end function to Start Playback

// function to Start Playback
function startSubtitle(suburl) {
	var videoelem = document.getElementById("webchimera");
	videoelem.emitJsMessage("[start-subtitle]"+suburl);
}
// end function to Start Playback