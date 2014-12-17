// if page on local machine, add warning
var websiteishttps = 0;
var globalurlstring = " ";
var localwarning = '<div id="warning-wrapper"><div id="lwarning" class="btn">QML File cannot be loaded from your Local Machine! Upload the Demo on a Web server to see it working correctly!</div></div>';
switch(window.location.protocol) {
   case 'http:': break;
   case 'https:': 
	 websiteishttps = 1;
	 break;
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
    
	// function to Load QML File in Javascript and send the QML String to WebChimera
	this.getFromUrl = function(urlstring) {
		globalurlstring = urlstring;
	
		var xmlhttp;
		if (window.XMLHttpRequest) { // code for IE7+, Firefox, Chrome, Opera, Safari
			xmlhttp = new XMLHttpRequest();
		}
		else { // code for IE6, IE5
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); 
		}
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var responsedata = xmlhttp.responseText;
				
				// get direct path to qml file
				var currenturl = window.location.href;
				currenturl = currenturl.substring(0,currenturl.lastIndexOf("/") +1);
				if (globalurlstring.substring(0, 4) != "http") {
					if (globalurlstring.substring(0, 1) == "/") globalurlstring = globalurlstring.substring(1);
					if (globalurlstring.substring(0, 2) == "./") globalurlstring = globalurlstring.substring(2);
					while (globalurlstring.substring(0, 3) == "../") {
						globalurlstring = globalurlstring.substring(3);
						currenturl = currenturl.substring(0,currenturl.length -1);
						currenturl = currenturl.substring(0,currenturl.lastIndexOf("/") +1);
					}
					if (globalurlstring.indexOf("/") > -1) {
						globalurlstring = globalurlstring.substring(0,globalurlstring.lastIndexOf("/") +1);
					} else {
						globalurlstring = "";
					}
					currenturl = currenturl + globalurlstring;
					if (currenturl.indexOf("https://") > -1) currenturl = currenturl.replace("https://","http://"); // Remove this once webchimera handles ssl links
				}
				// end get direct path to qml file
				
				// parse qml source and change all image sources to their direct http path (if required)
	
				var findsource = " ";
				var remainingdata = responsedata;
				var newdata = "";
				
				while (remainingdata.indexOf('source:') > -1 || remainingdata.indexOf('.source') > -1) {
					var sourcevar1 = remainingdata.indexOf('source:');
					var sourcevar2 = remainingdata.indexOf('.source');
					var checkvlc = 0;
					
					if (sourcevar1 > -1 && sourcevar2 > -1) {
						if (sourcevar1 < sourcevar2) {
							newdata += remainingdata.substring(0,remainingdata.indexOf('source:'));
							remainingdata = remainingdata.substring(remainingdata.indexOf('source:'));
						} else {
							newdata += remainingdata.substring(0,remainingdata.indexOf('.source'));
							remainingdata = remainingdata.substring(remainingdata.indexOf('.source'));
						}
					} else {
						if (sourcevar1 > -1) {
							newdata += remainingdata.substring(0,remainingdata.indexOf('source:'));
							remainingdata = remainingdata.substring(remainingdata.indexOf('source:'));
						}
						if (sourcevar2 > -1) {
							newdata += remainingdata.substring(0,remainingdata.indexOf('.source'));
							remainingdata = remainingdata.substring(remainingdata.indexOf('.source'));
						}
					}
					var thisline = remainingdata.substring(0,remainingdata.indexOf('\n'));
					if (thisline.indexOf("vlcPlayer") == -1) checkvlc = 1;
					if (thisline.indexOf("vlcPlayer.") == -1) checkvlc = 0;
					if (checkvlc == 0) {
						while (thisline.indexOf('"') > -1) {
							var thisimage = thisline.substring(thisline.indexOf('"'));
							newdata += thisline.substring(0,thisline.indexOf('"') +1);
							var newimage = thisimage.substring(1);
							thisline = newimage.substring(newimage.indexOf('"') +1);
							newimage = newimage.substring(0,newimage.indexOf('"'));
							if (newimage.substring(0, 1) == "/") newimage = newimage.substring(1);
							if (newimage.substring(0, 2) == "./") newimage = newimage.substring(2);
							var tempcurrenturl = currenturl;
							while (newimage.substring(0, 3) == "../") {
								newimage = newimage.substring(3);
								tempcurrenturl = tempcurrenturl.substring(0,tempcurrenturl.lastIndexOf("/"));
								tempcurrenturl = tempcurrenturl.substring(0,tempcurrenturl.lastIndexOf("/") +1);
							}
							newimage = tempcurrenturl + newimage;
							newdata += newimage + '"';
						}
						newdata += thisline;
					} else {
						newdata += thisline;
					}
					remainingdata = remainingdata.substring(remainingdata.indexOf('\n'));
				}
				newdata += remainingdata;
	
				// end parse qml source and change all image sources to their direct http path (if required)
	
				
				this.videoelem.qml = newdata;
			}
		}
		
		if (urlstring.indexOf("https://") > -1) urlstring = urlstring.replace("https://","http://");  // Remove this once webchimera handles ssl links
		xmlhttp.open("GET", urlstring, true);
		xmlhttp.send();
	}
	// End function to Load QML File in Javascript and send the QML String to WebChimera

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
		for (wjs_i = 0; wjs_setting[wjs_i]; wjs_i++) {
			if (wjs_setting[wjs_i] == "multiscreen") {
				this.videoelem.emitJsMessage("[set-multiscreen]");
			} else if (wjs_setting[wjs_i] == "mouseevents") {
				this.videoelem.emitJsMessage("[set-mouse-events]");
			} else if (wjs_setting[wjs_i] == "autoplay" || wjs_setting[wjs_i] == "autostart") {
				this.videoelem.emitJsMessage("[autoplay]");
			}
		}
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
			qmlsource = "http://www.webchimera.org/qml/default.qml";
		} else {
			if (qmlsource.replace(".qml","") == qmlsource) {
				newid = qmlsource;
			}
		}
		qmlsource = (typeof qmlsource === "undefined") ? "http://www.webchimera.org/qml/default.qml" : qmlsource; // if no qmlsource set, default to latest Webchimera Player Default QML
		
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
	
		if (websiteishttps == 1) {  // Remove this once webchimera handles ssl links
			// if QML Source is using SSL
			setTimeout(this.getFromUrl(qmlsource),10); // Load QML File as String with JavaScript
			playerbody += '<param name="qmlsrc" value="" />';
			// End if QML Source is using SSL
		} else {
			if (qmlsource.substring(0, 7) == "https://") {  // Remove this once webchimera handles ssl links
				// if QML Source is using SSL
				setTimeout(this.getFromUrl(qmlsource),10); // Load QML File as String with JavaScript
				playerbody += '<param name="qmlsrc" value="" />';
				// End if QML Source is using SSL
			} else {
				playerbody += '<param name="qmlsrc" value="' + qmlsource + '" />'; // if QML Source is not using SSL
			}
		}
		
		var onloadsettings = "";
		
		for (key in qmlsettings) {
			if (qmlsettings.hasOwnProperty(key)) {
				if (key == "multiscreen" || key == "mouseevents" || key == "autoplay" || key == "autostart") {
					if (qmlsettings[key] == 1 || qmlsettings[key] === true) {
						if (onloadsettings.length > 0) onloadsettings += "|";
						onloadsettings += key;
					}
				} else {
					playerbody += '<param name="' + key + '" value="' + qmlsettings[key] + '" />';
				}
			}
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
			 if (Array.isArray(playlist) === true && Array.isArray(playlist[0]) === true) {
				 // if Playlist has Custom Titles
				 var item = 0;
				 for (item = 0; item < playlist.length; item++) {
					  this.videoelem.playlist.add(playlist[item][0]);
					  if (typeof playlist[item][1] !== 'undefined' && typeof playlist[item][1] === 'string') this.videoelem.playlist.items[item].title = "[custom]"+playlist[item][1];
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