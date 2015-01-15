/*****************************************************************************
* Copyright (c) 2014 Branza Victor-Alexandru <branza.alex[at]gmail.com>
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation; either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this program; if not, write to the Free Software Foundation,
* Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
*****************************************************************************/


// if page on local machine, add warning
var globalurlstring = " ";
var localwarning = '<div id="warning-wrapper"><div id="lwarning" class="btn">QML File cannot be loaded from your Local Machine! Upload the Demo on a Web server to see it working correctly!</div></div>';
var wjsScripts = document.getElementsByTagName("script"),
    webchimeraSrc = wjsScripts[wjsScripts.length-1].src,
	webchimeraFolder = webchimeraSrc.substring(0, webchimeraSrc.lastIndexOf("/"));
switch(window.location.protocol) {
   case 'http:': break;
   case 'https:': break
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

// function to check if a string is json
function IsJsonString(str) {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
}
// end function to check if a string is json

var wjs = function(context) {
    // if the function is called without being called as a constructor,
    // then call as a constructor for us.
    if (this.__proto__.constructor !== wjs) {
        return new wjs(context);
    }
    
    // Save the context
	this.context = (typeof context === "undefined") ? "#webchimera" : context;  // if no playerid set, default to "webchimera"
	
	if (this.context.substring(0,1) == "#") {
		this.videoelem = document.getElementById(this.context.substring(1));
	} else if (this.context.substring(0,1) == ".") {
		this.videoelem = document.getElementsByClassName(this.context.substring(1));
	} else {
		this.videoelem = document.getElementsByTagName(this.context);
	}

	// catch event function
	this.catchEvent = function(wjs_event,wjs_function) {
		if (this.videoelem.attachEvent) {
			// Microsoft
			this.videoelem.attachEvent("on"+wjs_event, wjs_function);
		} else if (this.videoelem.addEventListener) {
			// Mozilla: DOM level 2
			this.videoelem.addEventListener(wjs_event, wjs_function, false);
		} else {
			// DOM level 0
			this.videoelem["on"+wjs_event] = wjs_function;
		}
	}
	// end catch event function
	
	// function that loads webchimera player settings after qml has loaded
	this.loadSettings = function(wjs_localsettings) {
		var wjs_setting = [];
		if (wjs_localsettings.indexOf("|") > -1) {
			wjs_setting = wjs_localsettings.split("|");
		} else {
			wjs_setting[0] = wjs_localsettings;
		}
		for (wjs_i = 0; wjs_setting[wjs_i]; wjs_i++) this.videoelem.emitJsMessage("["+wjs_setting[wjs_i]+"]");
	}
	// end function that loads webchimera player settings after qml has loaded

	this.qmlLoaded = function(action) {
		function wjs_function(event) {
			if (event == "[qml-loaded]") action();
		}
		
		if (this.videoelem.attachEvent) {
			// Microsoft
			this.videoelem.attachEvent("onQmlMessage", wjs_function);
		} else if (this.videoelem.addEventListener) {
			// Mozilla: DOM level 2
			this.videoelem.addEventListener("QmlMessage", wjs_function, false);
		} else {
			// DOM level 0
			this.videoelem["onQmlMessage"] = wjs_function;
		}
		
	}

	this.addPlayer = function(qmlsource,newid,qmlsettings) {
		if (IsJsonString(newid) === true) {
			qmlsettings = newid;
		}
		if (IsJsonString(qmlsource) === true) {
			qmlsettings = qmlsource;
			qmlsource = "http://www.webchimera.org/player/themes/retro/main.qml";
		}
		qmlsource = (typeof qmlsource === "undefined") ? "http://www.webchimera.org/player/themes/retro/main.qml" : qmlsource; // if no qmlsource set, default to latest Webchimera Player Default QML
		
		var playerbody = "";
		if (typeof newid === 'string') {
			if (newid.substring(0,1) == "#") {
				var targetid = ' id="'+newid.substring(1)+'"';
				var webchimeraid = newid.substring(1);
			} else if (newid.substring(0,1) == ".") {
				var targetid = ' class="'+newid.substring(1)+'"';
				var webchimeraclass = newid.substring(1);
			} else {
				var targetid = ' id="'+newid+'"';
				var webchimeraid = newid;
			}
		} else {
			var targetid = ' id="webchimera"';
			var webchimeraid = "webchimera";
		}
		playerbody += '<object' + targetid + ' type="application/x-chimera-plugin" width="100%" height="100%">';
	
		suffix = ".qml";
		if (qmlsource.indexOf(suffix, qmlsource.length - suffix.length) === -1) qmlsource = webchimeraFolder+"/themes/"+qmlsource+"/main.qml";
		playerbody += '<param name="qmlsrc" value="' + qmlsource.replace("https://","http://") + '" />'; // if QML Source is using SSL, replace protocol
		
		var onloadsettings = "";
		
		var didbuffer = 0;
		for (key in qmlsettings) {
			if (qmlsettings.hasOwnProperty(key)) {
				if (key == "multiscreen" || key == "mouseevents" || key == "autoplay" || key == "autostart" || key == "autoloop" || key == "loop" || key == "mute") {
					if (qmlsettings[key] == 1 || qmlsettings[key] === true) {
						if (onloadsettings.length > 0) onloadsettings += "|";
						onloadsettings += key;
					}
				} else if (key == "allowfullscreen") {
					if (qmlsettings[key] == 0 || qmlsettings[key] === false) {
						if (onloadsettings.length > 0) onloadsettings += "|";
						onloadsettings += key;
					}
				} else if (key == "buffer") {
					if (onloadsettings.length > 0) onloadsettings += "|";
					onloadsettings += "[caching]" + qmlsettings[key];
					didbuffer = 1;
					playerbody += '<param name="network-caching" value="' + qmlsettings[key] + '" />';
				} else {
					if (key == "network-caching") {
						var didbuffer = 1;
						if (onloadsettings.length > 0) onloadsettings += "|";
						onloadsettings += "[caching]" + qmlsettings[key];
					}
					playerbody += '<param name="' + key + '" value="' + qmlsettings[key] + '" />';
				}
			}
		}
		
		// default buffer is 10 seconds (10000 milliseconds)
		if (didbuffer == 0) {
			if (onloadsettings.length > 0) onloadsettings += "|";
			onloadsettings += "[caching]10000";
			playerbody += '<param name="network-caching" value="10000" />';
		}

			
		playerbody += '</object>';
		
		this.videoelem.innerHTML = playerbody;
		
		
		if (typeof onloadsettings !== "undefined") {
			if (onloadsettings.length > 0) {
				if (typeof webchimeraid !== "undefined") {
					wjs("#" + webchimeraid).catchEvent('QmlMessage', function(event) { if (event == "[qml-loaded]") wjs("#" + webchimeraid).loadSettings(onloadsettings); });
				}
				if (typeof webchimeraclass !== "undefined") {
					wjs("." + webchimeraclass).catchEvent('QmlMessage', function(event) { if (event == "[qml-loaded]") wjs("." + webchimeraclass).loadSettings(onloadsettings); });
				}
			}
		}
		
	}
	
	// function to add playlist items
	this.addPlaylist = function(playlist) {
		 if (typeof playlist === 'string') {
			 this.videoelem.playlist.add(playlist); // if Playlist has one Element
		 } else {
			 if (Array.isArray(playlist) === true && typeof playlist[0] === 'object') {
				 // if Playlist has Custom Titles
				 var item = 0;
				 for (item = 0; item < playlist.length; item++) {
					  this.videoelem.playlist.add(playlist[item].url);
					  if (typeof playlist[item].title !== 'undefined' && typeof playlist[item].title === 'string') this.videoelem.playlist.items[item].title = "[custom]"+playlist[item].title;
					  if (typeof playlist[item].art !== 'undefined' && typeof playlist[item].art === 'string') this.videoelem.playlist.items[item].setting = "[art]"+playlist[item].art;
				 }
				 // end if Playlist has Custom Titles
			 } else if (Array.isArray(playlist) === true) {
				 var item = 0;
				 for (item = 0; typeof playlist[item] !== 'undefined'; item++) this.videoelem.playlist.add(playlist[item]); // if Playlist is Array
			 }
		 }
	}
	// end function to add playlist items
	
	// function to Start Playback
	this.startPlayer = function() {
		this.videoelem.playlist.playItem(0); // Play Current Item
		this.videoelem.playlist.Normal; // Set Normal Playback (options: Normal, Loop, Single)
	}
	// end function to Start Playback
	
	// function to Start External Subtitle
	this.startSubtitle = function(suburl) {
		if (typeof suburl !== "undefined") this.videoelem.emitJsMessage("[start-subtitle]"+suburl);
	}
	// end function to Start External Subtitle
	
	// functon to load m3u files
	this.loadM3U = function(M3Uurl) {
		if (typeof M3Uurl !== "undefined") this.videoelem.emitJsMessage("[load-m3u]"+M3Uurl);
	}
	// end function to load m3u files
	
}