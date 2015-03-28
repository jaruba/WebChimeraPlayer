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
    webchimeraSrc = wjsScripts[wjsScripts.length-1].src;
var isNode = (typeof process !== "undefined" && typeof require !== "undefined");
var isNodeWebkit = false;
	
//Is this Node.js?
if(isNode) {
  //If so, test for Node-Webkit
  try {
    isNodeWebkit = (typeof require('nw.gui') !== "undefined");
  } catch(e) {
    isNodeWebkit = false;
  }
}

if (isNodeWebkit) {
	var webchimeraFolder = "file:///"+ process.cwd() +"/player";
} else {
	var webchimeraFolder = webchimeraSrc.substring(0, webchimeraSrc.lastIndexOf("/"));
}

switch(window.location.protocol) {
   case 'http:': break;
   case 'https:': break;
   case 'app:': break;
   case 'file:':
	 if (isNodeWebkit === false) document.body.innerHTML += localwarning;
	 break;
   default: 
	 if (isNodeWebkit === false) document.body.innerHTML += localwarning;
}
// end if page on local machine, add warning

var pitem = [];
var ploaded = [];

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

// hacks to remember variables in setTimeout()
function delayLoadM3U(context,tempV) {
    return function(){
		wjs(context).qmlLoaded(function() {
			wjs(context).loadM3U(tempV);
		});
    }
}
function delayAdvance(plItem,swapFirst,swapDifference) {
    return function() {
        newDifference = plItem.plugin.playlist.itemCount-1;
        plItem.plugin.emitJsMessage("[swap-items]"+newDifference+"|"+(-1)*swapDifference);
        plItem.plugin.emitJsMessage("[refresh-playlist]");
    }
}
function delaySwap(plItem,swapFirst) {
    return function() {
        newSwap = parseInt(swapFirst)+1;
        plItem.plugin.playlist.playItem(swapFirst);
    }
}
function delayRemove(plItem,rmItem) {
    return function() {
        plItem.plugin.playlist.removeItem(rmItem);
    	plItem.plugin.emitJsMessage("[refresh-playlist]");
    }
}
// end hacks to remember variables in setTimeout()

var wjs = function(context) {
    // Call the constructor
    return new wjs.init(context);
};

// Static methods
wjs.init = function(context) {

    // Save the context
    this.context = (typeof context === "undefined") ? "#webchimera" : context;  // if no playerid set, default to "webchimera"

	// Save player parameters
	this.basicParams = ["allowfullscreen","multiscreen","mouseevents","autoplay","autostart","autoloop","loop","mute","titleBar","progressCache","toolbar","debugPlaylist"];
	
	if (this.context.substring(0,1) == "#") {
		this.plugin = document.getElementById(this.context.substring(1));
	} else if (this.context.substring(0,1) == ".") {
		this.plugin = document.getElementsByClassName(this.context.substring(1));
	} else {
		this.plugin = document.getElementsByTagName(this.context);
	}
};

// catch event function
wjs.init.prototype.catchEvent = function(wjs_event,wjs_function) {
	var saveContext = wjs(this.context);
	if (this.plugin.attachEvent) {
		// Microsoft
		this.plugin.attachEvent("on"+wjs_event, function(event) {
			return wjs_function.call(saveContext,event);
		});
	} else if (this.plugin.addEventListener) {
		// Mozilla: DOM level 2
		this.plugin.addEventListener(wjs_event, function(event) {
			return wjs_function.call(saveContext,event);
		}, false);
	} else {
		// DOM level 0
		this.plugin["on"+wjs_event] = function(event) {
			return wjs_function.call(saveContext,event);
		};
	}
	
	return wjs(this.context);
};
// end catch event function

// function that loads webchimera player settings after qml has loaded
wjs.init.prototype.loadSettings = function(wjs_localsettings) {
	this.plugin.emitJsMessage(JSON.stringify(wjs_localsettings));
};
// end function that loads webchimera player settings after qml has loaded

// functions to hide/show toolbar
wjs.init.prototype.hideToolbar = function() {
	this.plugin.emitJsMessage("[hide-toolbar]");
	return wjs(this.context);
};
wjs.init.prototype.showToolbar = function() {
	this.plugin.emitJsMessage("[show-toolbar]");
	return wjs(this.context);
};
// end functions to hide/show toolbar

wjs.init.prototype.qmlLoaded = function(action) {
	var saveContext = wjs(this.context);
	if (isNodeWebkit) {
		action.call(saveContext);
	} else {
		function wjs_function(event) {
			if (event == "[qml-loaded]") {
				var saveContext = wjs(this.context);
				action.call(saveContext);
			}
		}
		
		if (this.plugin.attachEvent) {
			// Microsoft
			this.plugin.attachEvent("onQmlMessage", function(event) {
				return wjs_function.call(saveContext,event);
			});
		} else if (this.plugin.addEventListener) {
			// Mozilla: DOM level 2
			this.plugin.addEventListener("QmlMessage", function(event) {
				return wjs_function.call(saveContext,event);
			}, false);
		} else {
			// DOM level 0
			this.plugin["onQmlMessage"] = function(event) {
				return wjs_function.call(saveContext,event);
			};
		}
	}
	
	return wjs(this.context);
};

wjs.init.prototype.onClicked = function(target, action) {
	function wjs_function(event) {
		if (event == "[clicked]"+target) {
			var saveContext = wjs(this.context);
			action.call(saveContext);
		}
	}
	
	var saveContext = wjs(this.context);

	if (this.plugin.attachEvent) {
		// Microsoft
		this.plugin.attachEvent("onQmlMessage", function(event) {
			return wjs_function.call(saveContext,event);
		});
	} else if (this.plugin.addEventListener) {
		// Mozilla: DOM level 2
		this.plugin.addEventListener("QmlMessage", function(event) {
			return wjs_function.call(saveContext,event);
		}, false);
	} else {
		// DOM level 0
		this.plugin["onQmlMessage"] = function(event) {
			return wjs_function.call(saveContext,event);
		};
	}
	
	return wjs(this.context);
};

wjs.init.prototype.onKeyPressed = function(target, action) {

	var saveContext = wjs(this.context);

	var keyMap = { 0:48, 1:49, 2:50, 3:51, 4:52, 5:53, 6:54, 7:55, 8:56, 9:57, a:65, b:66, c:67, d:68, e:69, f:70, g:71, h:72, i:73, j:74, k:75, l:76, m:77, n:78, o:79, p:80, q:81, r:82, s:83, t:84, u:85, v:86, w:87, x:88, y:89, z:90, space:32, f1:16777264, f2:16777265, f3:16777266, f4:16777267, f5:16777268, f6:16777269, f7:16777270, f8:16777271, f9:16777272, f10:16777273, f11:16777274, f12:16777275, left:16777234, up:16777235, right:16777236, down:16777237, plus:43, minus:45, equal:61, bracketleft:91, bracketright:93, esc:16777216, "shift":16777248, ctrl:16777249, meta:16777250, alt:16777251, "ctrl+":67108864, "alt+":134217728, "shift+":33554432, "meta+":268435456 };
	
	var reverseKeyMap = {};
	
	for (var prop in keyMap) if(keyMap.hasOwnProperty(prop)) reverseKeyMap[keyMap[prop]] = prop;

	if (typeof target === 'function') {
		
		function wjs_function_reverse(event) {
			var saveContext = wjs(this.context);
			if (event.substr(0,9) == "[pressed-") {
				qmlTarget = event.replace("[pressed-","").replace("]","");
				if (qmlTarget.indexOf("+") > -1) {
					qmlButtons = qmlTarget.split("+");
					target.call(saveContext,reverseKeyMap[qmlButtons[0]]+reverseKeyMap[qmlButtons[1]]);
				} else {
					target.call(saveContext,reverseKeyMap[qmlTarget]);
				}
			}
			
		}
		
		if (this.plugin.attachEvent) {
			// Microsoft
			this.plugin.attachEvent("onQmlMessage", function(event) {
				return wjs_function_reverse.call(saveContext,event);
			});
		} else if (this.plugin.addEventListener) {
			// Mozilla: DOM level 2
			this.plugin.addEventListener("QmlMessage", function(event) {
				return wjs_function_reverse.call(saveContext,event);
			}, false);
		} else {
			// DOM level 0
			this.plugin["onQmlMessage"] = function(event) {
				return wjs_function_reverse.call(saveContext,event);
			};
		}
		
	} else {
	
		function wjs_function(event) {
			var saveContext = wjs(this.context);
			if (target.toLowerCase().indexOf("ctrl+") > -1 || target.toLowerCase().indexOf("alt+") > -1 || target.toLowerCase().indexOf("shift+") > -1 || target.toLowerCase().indexOf("meta+") > -1) {
				var res = target.split("+");
				var newtarget = keyMap[res[0].toLowerCase() +"+"].toString() +"+"+ keyMap[res[1].toLowerCase()].toString();
				if (event == "[pressed-"+newtarget+"]") action.call(saveContext);
			} else {
				if (event == "[pressed-"+keyMap[target.toLowerCase()]+"]") action.call(saveContext);
			}
		}
		
		if (this.plugin.attachEvent) {
			// Microsoft
			this.plugin.attachEvent("onQmlMessage", function(event) {
				return wjs_function.call(saveContext,event);
			});
		} else if (this.plugin.addEventListener) {
			// Mozilla: DOM level 2
			this.plugin.addEventListener("QmlMessage", function(event) {
				return wjs_function.call(saveContext,event);
			}, false);
		} else {
			// DOM level 0
			this.plugin["onQmlMessage"] = function(event) {
				return wjs_function.call(saveContext,event);
			};
		}
		
	}
	
	return wjs(this.context);
};

wjs.init.prototype.preventDefault = function(type, target, action) {
	
	if (type.toLowerCase() == "key") {
		var keyMap = { 0:48, 1:49, 2:50, 3:51, 4:52, 5:53, 6:54, 7:55, 8:56, 9:57, a:65, b:66, c:67, d:68, e:69, f:70, g:71, h:72, i:73, j:74, k:75, l:76, m:77, n:78, o:79, p:80, q:81, r:82, s:83, t:84, u:85, v:86, w:87, x:88, y:89, z:90, space:32, f1:16777264, f2:16777265, f3:16777266, f4:16777267, f5:16777268, f6:16777269, f7:16777270, f8:16777271, f9:16777272, f10:16777273, f11:16777274, f12:16777275, left:16777234, up:16777235, right:16777236, down:16777237, plus:43, minus:45, equal:61, bracketleft:91, bracketright:93, esc:16777216, "shift":16777248, ctrl:16777249, meta:16777250, alt:16777251, "ctrl+":67108864, "alt+":134217728, "shift+":33554432, "meta+":268435456 };
		
		if (action === true) {
			if (target.toLowerCase().indexOf("ctrl+") > -1 || target.toLowerCase().indexOf("alt+") > -1 || target.toLowerCase().indexOf("shift+") > -1 || target.toLowerCase().indexOf("meta+") > -1) {
				var res = target.split("+");
				var newtarget = keyMap[res[0].toLowerCase() +"+"].toString() +"+"+ keyMap[res[1].toLowerCase()].toString();
				this.plugin.emitJsMessage("[stop-pressed]"+newtarget);
			} else {
				this.plugin.emitJsMessage("[stop-pressed]"+keyMap[target.toLowerCase()]);
			}
		} else if (action === false) {
			if (target.toLowerCase().indexOf("ctrl+") > -1 || target.toLowerCase().indexOf("alt+") > -1 || target.toLowerCase().indexOf("shift+") > -1 || target.toLowerCase().indexOf("meta+") > -1) {
				var res = target.split("+");
				var newtarget = keyMap[res[0].toLowerCase() +"+"].toString() +"+"+ keyMap[res[1].toLowerCase()].toString();
				this.plugin.emitJsMessage("[start-pressed]"+newtarget);
			} else {
				this.plugin.emitJsMessage("[start-pressed]"+keyMap[target.toLowerCase()]);
			}
		}
	} else if (type.toLowerCase() == "click") {
		if (action === true) {
			this.plugin.emitJsMessage("[stop-clicked]"+target.toLowerCase());
		} else if (action === false) {
			this.plugin.emitJsMessage("[start-clicked]"+target.toLowerCase());
		}
	}
	
	return wjs(this.context);
	
};

wjs.init.prototype.addPlayer = function(qmlsettings) {
	
	// check if plugin is installed
	var isInstalled = false;
	if (typeof navigator.plugins["WebChimera Plugin"] !== 'undefined') isInstalled = true;
	if (typeof navigator.plugins["WebChimera x86_64"] !== 'undefined') isInstalled = true;

	if (!isInstalled) {
		this.plugin.style.zIndex = 1000;
		this.plugin.innerHTML = '<iframe src="http://www.webchimera.org/no_plugin.php" scrolling="no" width="100%" height="100%" style="border: none"></iframe>';
		return false;
	}
	// end check if plugin is installed

	newid = (typeof qmlsettings["id"] === "undefined") ? "webchimera" : qmlsettings["id"]; // if no id set, default to "webchimera"

	qmlsource = (typeof qmlsettings["theme"] === "undefined") ? "http://www.webchimera.org/player/themes/sleek/main.qml" : qmlsettings["theme"]; // if no qmlsource set, default to latest Webchimera Player Default QML
	
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
	
	var onloadsettings = {};
	
	onloadsettings["settings"] = true;
	
	var didbuffer = 0;
	for (key in qmlsettings) {
		if (qmlsettings.hasOwnProperty(key)) {
			if (this.basicParams.indexOf(key) > -1) {
				if (key == "debugPlaylist") {
					if (qmlsettings[key] == 1 || qmlsettings[key] === true) debugPlaylist = 1;
				}
				onloadsettings[key] = qmlsettings[key];
			} else if (key == "buffer") {
				onloadsettings["caching"] = qmlsettings[key];
				didbuffer = 1;
				playerbody += '<param name="network-caching" value="' + qmlsettings[key] + '" />';
			} else if (key == "hotkeys") {
				if (qmlsettings[key] == 0 || qmlsettings[key] === false) removeHotkeys = 1;
			} else {
				if (key == "network-caching") {
					onloadsettings["caching"] = qmlsettings[key];
					didbuffer = 1;
				}
				if (key != "id" && key != "theme") playerbody += '<param name="' + key + '" value="' + qmlsettings[key] + '" />';
			}
		}
	}
		
	// default buffer is 10 seconds (10000 milliseconds)
	if (didbuffer == 0) {
		onloadsettings["caching"] = 10000;
		playerbody += '<param name="network-caching" value="10000" />';
	}

		
	playerbody += '</object>';
	
	this.plugin.innerHTML = playerbody;

	if (typeof debugPlaylist !== "undefined") {
		if (typeof webchimeraid !== "undefined") {
			wjs("#" + webchimeraid).catchEvent("QmlMessage",function(event) {
				if (event.substr(0,9) == "[replace]") {
					swapFirst = event.replace("[replace]","").split("[-|-]")[0];
					swapMRL = event.replace("[replace]","").split("[-|-]")[1];
					this.addPlaylist(swapMRL);
					swapDifference = this.plugin.playlist.itemCount - swapFirst -1;
					setTimeout(delayAdvance(this,swapFirst,swapDifference),50);
					setTimeout(delayRemove(this,parseInt(swapFirst)+1),100);
				} else if (event.substr(0,18) == "[replace-and-swap]") {
					swapFirst = event.replace("[replace-and-swap]","").split("[-|-]")[0];
					swapMRL = event.replace("[replace-and-swap]","").split("[-|-]")[1];
					this.addPlaylist(swapMRL);
					swapDifference = this.plugin.playlist.itemCount - swapFirst -1;
					setTimeout(delayAdvance(this,swapFirst,swapDifference),50);
					setTimeout(delaySwap(this,swapFirst),100);
					setTimeout(delayRemove(this,parseInt(swapFirst)+1),150);
				}
			});
		} else if (typeof webchimeraclass !== "undefined") {
			wjs("." + webchimeraclass).catchEvent("QmlMessage",function(event) {
				if (event.substr(0,9) == "[replace]") {
					swapFirst = event.replace("[replace]","").split("[-|-]")[0];
					swapMRL = event.replace("[replace]","").split("[-|-]")[1];
					this.addPlaylist(swapMRL);
					swapDifference = this.plugin.playlist.itemCount - swapFirst -1;
					setTimeout(delayAdvance(this,swapFirst,swapDifference),50);
					setTimeout(delayRemove(this,parseInt(swapFirst)+1),100);
				} else if (event.substr(0,18) == "[replace-and-swap]") {
					swapFirst = event.replace("[replace-and-swap]","").split("[-|-]")[0];
					swapMRL = event.replace("[replace-and-swap]","").split("[-|-]")[1];
					this.addPlaylist(swapMRL);
					swapDifference = this.plugin.playlist.itemCount - swapFirst -1;
					setTimeout(delayAdvance(this,swapFirst,swapDifference),50);
					setTimeout(delaySwap(this,swapFirst),100);
					setTimeout(delayRemove(this,parseInt(swapFirst)+1),150);
				}
			});
		}
	}

	if (isNodeWebkit) {
		if (typeof webchimeraid !== "undefined") {
			wjs("#" + webchimeraid).loadSettings(onloadsettings);
			ploaded["#" + webchimeraid] = true;
			wjs("#" + webchimeraid).catchEvent("QmlMessage",function(event) {
				if (event.substr(0,6) == "[href]") window.open(event.replace("[href]",""), '_blank');
			});
			if (typeof removeHotkeys !== "undefined") {
				wjs("#" + webchimeraid).preventDefault("key","f",true).preventDefault("key","F11",true).preventDefault("key","space",true).preventDefault("key","ctrl+up",true).preventDefault("key","ctrl+down",true).preventDefault("key","m",true).preventDefault("key","p",true).preventDefault("key","esc",true).preventDefault("key","plus",true).preventDefault("key","minus",true).preventDefault("key","equal",true).preventDefault("key","bracketLeft",true).preventDefault("key","bracketRight",true).preventDefault("key","a",true).preventDefault("key","c",true).preventDefault("key","z",true).preventDefault("key","t",true).preventDefault("key","e",true).preventDefault("key","shift+left",true).preventDefault("key","shift+right",true).preventDefault("key","alt+left",true).preventDefault("key","alt+right",true).preventDefault("key","ctrl+left",true).preventDefault("key","ctrl+right",true).preventDefault("key","ctrl+l",true).preventDefault("key","n",true);
			}
		}
		if (typeof webchimeraclass !== "undefined") {
			wjs("." + webchimeraclass).loadSettings(onloadsettings);
			ploaded["." + webchimeraclass] = true;
			wjs("." + webchimeraclass).catchEvent("QmlMessage",function(event) {
				if (event.substr(0,6) == "[href]") window.open(event.replace("[href]",""), '_blank');
			});
			if (typeof removeHotkeys !== "undefined") {
				wjs("." + webchimeraclass).preventDefault("key","f",true).preventDefault("key","F11",true).preventDefault("key","space",true).preventDefault("key","ctrl+up",true).preventDefault("key","ctrl+down",true).preventDefault("key","m",true).preventDefault("key","p",true).preventDefault("key","esc",true).preventDefault("key","plus",true).preventDefault("key","minus",true).preventDefault("key","equal",true).preventDefault("key","bracketLeft",true).preventDefault("key","bracketRight",true).preventDefault("key","a",true).preventDefault("key","c",true).preventDefault("key","z",true).preventDefault("key","t",true).preventDefault("key","e",true).preventDefault("key","shift+left",true).preventDefault("key","shift+right",true).preventDefault("key","alt+left",true).preventDefault("key","alt+right",true).preventDefault("key","ctrl+left",true).preventDefault("key","ctrl+right",true).preventDefault("key","ctrl+l",true).preventDefault("key","n",true);
			}
		}
	} else {
		if (typeof webchimeraid !== "undefined") {
			wjs("#" + webchimeraid).catchEvent("QmlMessage",function(event) {
				if (event == "[qml-loaded]" && typeof onloadsettings !== "undefined") {
					wjs("#" + webchimeraid).loadSettings(onloadsettings);
					ploaded["#" + webchimeraid] = true;
				}
				if (event.substr(0,6) == "[href]") window.open(event.replace("[href]",""), '_blank');
			});
			if (typeof removeHotkeys !== "undefined") {
				wjs("#" + webchimeraid).catchEvent("QmlMessage",function(event) {
					if (event == "[qml-loaded]") {
						wjs("#" + webchimeraid).preventDefault("key","f",true).preventDefault("key","F11",true).preventDefault("key","space",true).preventDefault("key","ctrl+up",true).preventDefault("key","ctrl+down",true).preventDefault("key","m",true).preventDefault("key","p",true).preventDefault("key","esc",true).preventDefault("key","plus",true).preventDefault("key","minus",true).preventDefault("key","equal",true).preventDefault("key","bracketLeft",true).preventDefault("key","bracketRight",true).preventDefault("key","a",true).preventDefault("key","c",true).preventDefault("key","z",true).preventDefault("key","t",true).preventDefault("key","e",true).preventDefault("key","shift+left",true).preventDefault("key","shift+right",true).preventDefault("key","alt+left",true).preventDefault("key","alt+right",true).preventDefault("key","ctrl+left",true).preventDefault("key","ctrl+right",true).preventDefault("key","ctrl+l",true).preventDefault("key","n",true);
					}
				});
			}
		}
		if (typeof webchimeraclass !== "undefined") {
			wjs("." + webchimeraclass).catchEvent("QmlMessage",function(event) {
				if (event == "[qml-loaded]" && typeof onloadsettings !== "undefined") {
					wjs("." + webchimeraclass).loadSettings(onloadsettings);
					ploaded["." + webchimeraclass] = true;
				}
				if (event.substr(0,6) == "[href]") window.open(event.replace("[href]",""), '_blank');
			});
			if (typeof removeHotkeys !== "undefined") {
				wjs("." + webchimeraclass).catchEvent("QmlMessage",function(event) {
					if (event == "[qml-loaded]") {
						wjs("." + webchimeraclass).preventDefault("key","f",true).preventDefault("key","F11",true).preventDefault("key","space",true).preventDefault("key","ctrl+up",true).preventDefault("key","ctrl+down",true).preventDefault("key","m",true).preventDefault("key","p",true).preventDefault("key","esc",true).preventDefault("key","plus",true).preventDefault("key","minus",true).preventDefault("key","equal",true).preventDefault("key","bracketLeft",true).preventDefault("key","bracketRight",true).preventDefault("key","a",true).preventDefault("key","c",true).preventDefault("key","z",true).preventDefault("key","t",true).preventDefault("key","e",true).preventDefault("key","shift+left",true).preventDefault("key","shift+right",true).preventDefault("key","alt+left",true).preventDefault("key","alt+right",true).preventDefault("key","ctrl+left",true).preventDefault("key","ctrl+right",true).preventDefault("key","ctrl+l",true).preventDefault("key","n",true);
					}
				});
			}
		}
	}
	return wjs(this.context);
};

// function for skinning
wjs.init.prototype.skin = function(skin) {
	skin.skinning = true;
	newid = this.context;
	if (typeof newid === 'string') {
		if (newid.substring(0,1) == "#") {
			var webchimeraid = newid.substring(1);
		} else if (newid.substring(0,1) == ".") {
			var webchimeraclass = newid.substring(1);
		} else var webchimeraid = newid;
	}
	if (typeof webchimeraid !== "undefined") wjs("#" + webchimeraid).qmlLoaded(function() { wjs("#" + webchimeraid).loadSettings(skin); });
	if (typeof webchimeraclass !== "undefined") wjs("." + webchimeraclass).qmlLoaded(function() { wjs("." + webchimeraclass).loadSettings(skin); });
	
	return wjs(this.context);
}
// end function for skinning

// function to toggle playlist
wjs.init.prototype.togglePlaylist = function() {
	 this.plugin.emitJsMessage("[toggle-playlist]"); // send message to QML to toggle the playlist
}
// end function to toggle playlist

// function to add playlist items
wjs.init.prototype.addPlaylist = function(playlist) {

	 // convert all strings to json object
	 if (Array.isArray(playlist) === true) {
		 var item = 0;
		 for (item = 0; typeof playlist[item] !== 'undefined'; item++) {
			 if (typeof playlist[item] === 'string') {
				 var tempPlaylist = playlist[item];
				 delete playlist[item];
				 playlist[item] = {
					url: tempPlaylist
				 };
			 }
		 }
	 } else if (typeof playlist === 'string') {
		 var tempPlaylist = playlist;
		 delete playlist;
		 playlist = [];
		 playlist.push({
			url: tempPlaylist
		 });
		 delete tempPlaylist;
	 } else if (typeof playlist === 'object') {
		 var tempPlaylist = playlist;
		 delete playlist;
		 playlist = [];
		 playlist.push(tempPlaylist);
		 delete tempPlaylist;
	 }
	 // end convert all strings to json object

	 if (Array.isArray(playlist) === true && typeof playlist[0] === 'object') {
		 var item = 0;
		 for (item = 0; item < playlist.length; item++) {
			  var re = /(?:\.([^.]+))?$/;
			  var ext = re.exec(playlist[item].url)[1];
			  if (typeof ext !== 'undefined' && ext == "m3u") {
				  if (typeof ploaded[this.context] !== 'undefined') {
					  wjs(this.context).loadM3U(playlist[item].url); // load m3u playlist
				  } else {
					  var context = this.context;
					  var tempV = playlist[item].url;
					  setTimeout(delayLoadM3U(context,tempV),1);
				  }
			  } else {
				  if (typeof pitem[this.context] === 'undefined') pitem[this.context] = 0;
				  this.plugin.playlist.add(playlist[item].url);
	  			  var playerSettings = {};
				  if (typeof playlist[item].title !== 'undefined' && typeof playlist[item].title === 'string') this.plugin.playlist.items[pitem[this.context]].title = "[custom]"+playlist[item].title;
				  if (typeof playlist[item].art !== 'undefined' && typeof playlist[item].art === 'string') playerSettings.art = playlist[item].art;
				  if (typeof playlist[item].subtitles !== 'undefined') playerSettings.subtitles = playlist[item].subtitles;
				  if (typeof playlist[item].aspectRatio !== 'undefined' && typeof playlist[item].aspectRatio === 'string') playerSettings.aspectRatio = playlist[item].aspectRatio;
				  if (typeof playlist[item].crop !== 'undefined' && typeof playlist[item].crop === 'string') playerSettings.crop = playlist[item].crop;
				  
				  if (Object.keys(playerSettings).length > 0) this.plugin.playlist.items[pitem[this.context]].setting = JSON.stringify(playerSettings);
				  pitem[this.context]++;
			  }
		 }
	 }
	 this.plugin.emitJsMessage("[refresh-playlist]");

	return wjs(this.context);
};
// end function to add playlist items

// function to Start Playback
wjs.init.prototype.startPlayer = function() {
	this.plugin.playlist.playItem(0); // Play Current Item
	this.plugin.playlist.Normal; // Set Normal Playback (options: Normal, Loop, Single)

	return wjs(this.context);
};
// end function to Start Playback

// function to Stop Playback
wjs.init.prototype.stopPlayer = function() {
	this.plugin.playlist.stop(); // Stop Playback
	this.plugin.emitJsMessage("[reset-progress]");

	return wjs(this.context);
};
// end function to Stop Playback

// function to Set Custom Total Length to Current Item
wjs.init.prototype.setTotalLength = function(mseconds) {
	if (typeof mseconds !== "undefined") this.plugin.emitJsMessage("[set-total-length]"+mseconds);

	return wjs(this.context);
};
// end function to Set Custom Total Length to Current Item

// function to Start External Subtitle
wjs.init.prototype.startSubtitle = function(suburl) {
	if (typeof suburl !== "undefined") this.plugin.emitJsMessage("[start-subtitle]"+suburl);

	return wjs(this.context);
};
// end function to Start External Subtitle

// function to Clear External Subtitle
wjs.init.prototype.clearSubtitle = function() {
	this.plugin.emitJsMessage("[clear-subtitle]");

	return wjs(this.context);
};
// end function to Clear External Subtitle

// function to Set Subtitle Size
wjs.init.prototype.subSize = function(newSize) {
	
	// check if it is a number and in scope then send to player
	if (!isNaN(newSize) && parseInt(newSize) > 0 && parseInt(newSize) < 6) this.plugin.emitJsMessage("[sub-size]"+(parseInt(newSize)-1));

	return wjs(this.context);
};
// end function to Set Subtitle Size

// functon to load m3u files
wjs.init.prototype.loadM3U = function(M3Uurl) {
	if (typeof M3Uurl !== "undefined") this.plugin.emitJsMessage("[load-m3u]"+M3Uurl);

	return wjs(this.context);
};
// end function to load m3u files

// function to Change Opening Text
wjs.init.prototype.setOpeningText = function(openingtext) {
	if (typeof openingtext !== "undefined") this.plugin.emitJsMessage("[opening-text]"+openingtext);

	return wjs(this.context);
};
// end function to Change Opening Text

// function to Send Download Percent (for buffering bar)
wjs.init.prototype.setDownloaded = function(downloaded) {
	if (typeof downloaded !== "undefined") this.plugin.emitJsMessage("[downloaded]"+downloaded);

	return wjs(this.context);
};
// end function to Send Download Percent (for buffering bar)
