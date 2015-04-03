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

// WebChimera Player v1.11


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

// a function to detect IE (we can't check if the plugin is installed in IE, so we will remove the check if it's IE)
function isIE() { return ((navigator.appName == 'Microsoft Internet Explorer') || ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null))); }

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
function delayNode(action,saveContext) {
	return function() {
		action.call(saveContext);
	}
}
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
		this.allElements = [this.plugin];
	} else if (this.context.substring(0,1) == ".") {
		this.allElements = document.getElementsByClassName(this.context.substring(1));
		this.plugin = this.allElements[0];
	} else {
		this.allElements = document.getElementsByTagName(this.context);
		this.plugin = this.allElements[0];
	}
};

// catch event function
wjs.init.prototype.catchEvent = function(wjs_event,wjs_function) {
	if (this.allElements.length == 1) {
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
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).catchEvent(wjs_event,wjs_function);
	return this;
};
// end catch event function

// function that loads webchimera player settings after qml has loaded
wjs.init.prototype.loadSettings = function(wjs_localsettings) {
	if (this.allElements.length == 1) this.plugin.emitJsMessage(JSON.stringify(wjs_localsettings));
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).loadSettings(wjs_localsettings);
	return this;
};
// end function that loads webchimera player settings after qml has loaded

// functions to hide/show toolbar
wjs.init.prototype.hideToolbar = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[hide-toolbar]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).hideToolbar();
	return this;
};
wjs.init.prototype.showToolbar = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[show-toolbar]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).showToolbar();
	return this;
};
wjs.init.prototype.toggleToolbar = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[toggle-toolbar]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).toggleToolbar();
	return this;
};
// end functions to hide/show toolbar

// functions to hide/show user interface
wjs.init.prototype.hideUI = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[hide-ui]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).hideUI();
	return this;
};
wjs.init.prototype.showUI = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[show-ui]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).showUI();
	return this;
};
wjs.init.prototype.toggleUI = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[toggle-ui]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).toggleUI();
	return this;
};
// end functions to hide/show user interface

wjs.init.prototype.qmlLoaded = function(action) {
	if (this.allElements.length == 1) {
		var saveContext = wjs(this.context);
		if (isNodeWebkit) {
			setTimeout(delayNode(action,saveContext),100);
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
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).qmlLoaded(action);
	return this;
};

wjs.init.prototype.onClicked = function(target, action) {
	if (this.allElements.length == 1) {
		var saveContext = wjs(this.context);
		
		if (typeof target === 'function') {
			
			function wjs_function_alt(event) {
				var saveContext = wjs(this.context);
				if (event.substr(0,9) == "[clicked]") target.call(saveContext,event.replace("[clicked]",""));
			}
	
			if (this.plugin.attachEvent) {
				// Microsoft
				this.plugin.attachEvent("onQmlMessage", function(event) {
					return wjs_function_alt.call(saveContext,event);
				});
			} else if (this.plugin.addEventListener) {
				// Mozilla: DOM level 2
				this.plugin.addEventListener("QmlMessage", function(event) {
					return wjs_function_alt.call(saveContext,event);
				}, false);
			} else {
				// DOM level 0
				this.plugin["onQmlMessage"] = function(event) {
					return wjs_function_alt.call(saveContext,event);
				};
			}
	
		} else {
			
			function wjs_function(event) {
				if (event == "[clicked]"+target) {
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
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).onClicked(target, action);
	
	return this;
};

wjs.init.prototype.onKeyPressed = function(target, action) {
	if (this.allElements.length == 1) {
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
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).onKeyPressed(target, action);
	
	return this;
};

wjs.init.prototype.preventDefault = function(type, target, action) {
	if (this.allElements.length == 1) {
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
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).preventDefault(type, target, action);
	
	return this;
	
};

wjs.init.prototype.addPlayer = function(qmlsettings) {
	if (this.allElements.length == 1) {

		// check if plugin is installed
		var isInstalled = false;
		if (typeof navigator.plugins["WebChimera Plugin"] !== 'undefined') isInstalled = true;
		if (typeof navigator.plugins["WebChimera x86_64"] !== 'undefined') isInstalled = true;
		
		// remove the check if it's IE (there's no sure way of checking if the plugin is installed/enabled in IE11)
		if (isIE()) isInstalled = true;
	
		if (!isInstalled) {
			this.plugin.style.zIndex = 1000;
			this.plugin.innerHTML = '<iframe src="http://www.webchimera.org/no_plugin.php" scrolling="no" width="100%" height="100%" style="border: none"></iframe>';
			return false;
		}
		// end check if plugin is installed
	
		newid = (typeof qmlsettings["id"] === "undefined") ? "webchimera" : qmlsettings["id"]; // if no id set, default to "webchimera"
		
		// check id availability
		changeid = newid;
		changeCounter = 0;
		while (!!document.getElementById(changeid)) { changeCounter++; changeid = newid + changeCounter; }
		newid = changeid;
		// end check id availability
		
		newclass = (typeof qmlsettings["class"] === "undefined") ? "webchimeras" : qmlsettings["class"]; // if no class set, default to "webchimeras"
	
		qmlsource = (typeof qmlsettings["theme"] === "undefined") ? "http://www.webchimera.org/player/themes/sleek/main.qml" : qmlsettings["theme"]; // if no qmlsource set, default to latest Webchimera Player Default QML
		
		var playerbody = "";
		if (typeof newid === 'string') {
			if (newid.substring(0,1) == "#") {
				var targetid = ' id="'+newid.substring(1)+'"';
			} else if (newid.substring(0,1) == ".") {
				var targetid = ' class="'+newid.substring(1)+'"';
			} else {
				var targetid = ' id="'+newid+'"';
				newid = "#"+newid;
			}
		} else {
			var targetid = ' id="webchimera"';
			newid = "#webchimera";
		}
		playerbody += '<object' + targetid + ' class="' + newclass + '" type="application/x-chimera-plugin" width="100%" height="100%">';
	
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
			wjs(newid).catchEvent("QmlMessage",function(event) {
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
	
		if (typeof onloadsettings !== "undefined") wjs(newid).qmlLoaded(function() {
			this.loadSettings(onloadsettings);
			ploaded[newid] = true;
		});
		wjs(newid).catchEvent("QmlMessage",function(event) {
			if (event.substr(0,6) == "[href]") window.open(event.replace("[href]",""), '_blank');
		});
		if (typeof removeHotkeys !== "undefined") {
			wjs(newid).qmlLoaded(function() {
				this.preventDefault("key","f",true).preventDefault("key","F11",true).preventDefault("key","space",true).preventDefault("key","ctrl+up",true).preventDefault("key","ctrl+down",true).preventDefault("key","m",true).preventDefault("key","p",true).preventDefault("key","esc",true).preventDefault("key","plus",true).preventDefault("key","minus",true).preventDefault("key","equal",true).preventDefault("key","bracketLeft",true).preventDefault("key","bracketRight",true).preventDefault("key","a",true).preventDefault("key","c",true).preventDefault("key","z",true).preventDefault("key","t",true).preventDefault("key","e",true).preventDefault("key","shift+left",true).preventDefault("key","shift+right",true).preventDefault("key","alt+left",true).preventDefault("key","alt+right",true).preventDefault("key","ctrl+left",true).preventDefault("key","ctrl+right",true).preventDefault("key","ctrl+l",true).preventDefault("key","n",true).preventDefault("key","alt+up",true).preventDefault("key","alt+down",true).preventDefault("key","g",true).preventDefault("key","h",true).preventDefault("key","j",true).preventDefault("key","k",true).preventDefault("key","ctrl+h",true);
			});
		}
	} else {
		for (z = 0; z < this.allElements.length; z++) {
			if (!this.allElements[z].id) {
				// check id availability
				changeid = "wjs_wrappers";
				changeCounter = 0;
				while (!!document.getElementById(changeid)) { changeCounter++; changeid = "wjs_wrappers" + changeCounter; }
				this.allElements[z].setAttribute("id", changeid);
				// end check id availability
			}
			wjs("#"+this.allElements[z].id).addPlayer(qmlsettings);
		}
	}
	
	return this;
};

// function for skinning
wjs.init.prototype.skin = function(skin) {
	if (this.allElements.length == 1) {
		skin.skinning = true;
		this.qmlLoaded(function() { this.loadSettings(skin); });
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).skin(skin);
	return this;
}
// end function for skinning

// function to toggle playlist
wjs.init.prototype.togglePlaylist = function() {
	if (this.allElements.length == 1) {
		this.plugin.emitJsMessage("[toggle-playlist]"); // send message to QML to toggle the playlist
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).togglePlaylist();
	return this;
}
// end function to toggle playlist

// function to add playlist items
wjs.init.prototype.addPlaylist = function(playlist) {
	if (this.allElements.length == 1) {
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
						  this.loadM3U(playlist[item].url); // load m3u playlist
					  } else {
						  var context = this.context;
						  var tempV = playlist[item].url;
						  setTimeout(delayLoadM3U(context,tempV),1);
					  }
				  } else {
					  if (typeof pitem[this.context] === 'undefined') pitem[this.context] = 0;
					  if (playlist[item].vlcArgs) {
						  if (!Array.isArray(playlist[item].vlcArgs)) {
							  if (playlist[item].vlcArgs.indexOf(" ") > -1) {
								  playlist[item].vlcArgs = playlist[item].vlcArgs.split(" ");
							  } else playlist[item].vlcArgs = [playlist[item].vlcArgs];
						  }
						  this.plugin.playlist.addWithOptions(playlist[item].url,playlist[item].vlcArgs);
					  } else this.plugin.playlist.add(playlist[item].url);
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
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).addPlaylist(playlist);

	return this;
};
// end function to add playlist items

// function to Start Playback
wjs.init.prototype.startPlayer = function() {
	if (this.allElements.length == 1) {
		this.plugin.playlist.playItem(0); // Play Current Item
		this.plugin.playlist.Normal; // Set Normal Playback (options: Normal, Loop, Single)
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).startPlayer();

	return this;
};
// end function to Start Playback

// function to Stop Playback
wjs.init.prototype.stopPlayer = function() {
	if (this.allElements.length == 1) {
		this.plugin.playlist.stop(); // Stop Playback
		this.plugin.emitJsMessage("[reset-progress]");
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).stopPlayer();

	return this;
};
// end function to Stop Playback

// function to Clear the Playlist
wjs.init.prototype.clearPlaylist = function() {
	if (this.allElements.length == 1) {
		pitem[this.context] = 0;
		this.plugin.playlist.clear();
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).clearPlaylist();

	return this;
};
// end function to Clear the Playlist

// function to Set Custom Total Length to Current Item
wjs.init.prototype.setTotalLength = function(mseconds) {
	if (this.allElements.length == 1) {
		if (typeof mseconds !== "undefined") this.plugin.emitJsMessage("[set-total-length]"+mseconds);
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).setTotalLength(mseconds);

	return this;
};
// end function to Set Custom Total Length to Current Item

// function to Start External Subtitle
wjs.init.prototype.startSubtitle = function(suburl) {
	if (this.allElements.length == 1) {
		if (typeof suburl !== "undefined") this.plugin.emitJsMessage("[start-subtitle]"+suburl);
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).startSubtitle(suburl);

	return this;
};
// end function to Start External Subtitle

// function to Clear External Subtitle
wjs.init.prototype.clearSubtitle = function() {
	if (this.allElements.length == 1) {
		this.plugin.emitJsMessage("[clear-subtitle]");
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).clearSubtitle();

	return this;
};
// end function to Clear External Subtitle

// function to Set Subtitle Size
wjs.init.prototype.subSize = function(newSize) {
	if (this.allElements.length == 1) {
		// check if it is a number and in scope then send to player
		if (!isNaN(newSize) && parseInt(newSize) > 0 && parseInt(newSize) < 6) this.plugin.emitJsMessage("[sub-size]"+(parseInt(newSize)-1));
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).subSize(newSize);

	return this;
};
// end function to Set Subtitle Size

// function to Set Subtitle Delay
wjs.init.prototype.subDelay = function(newDelay) {
	if (this.allElements.length == 1) {
		// check if it is a number then send to player
		if (!isNaN(newDelay)) this.plugin.emitJsMessage("[sub-delay]"+(parseInt(newDelay)));
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).subDelay(newDelay);

	return this;
};
// end function to Set Subtitle Delay

// function to Set Delay for Audio Tracks
wjs.init.prototype.audioDelay = function(newDelay) {
	if (this.allElements.length == 1) {
		// check if it is a number then send to player
		if (!isNaN(newDelay)) this.plugin.emitJsMessage("[audio-delay]"+(parseInt(newDelay)));
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).audioDelay(newDelay);

	return this;
};
// end function to Set Delay for Audio Tracks

// function to Toggle Mute
wjs.init.prototype.toggleMute = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[toggle-mute]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).toggleMute();
	return this;
};
// end function to Toggle Mute

// function to Notify on Screen
wjs.init.prototype.notify = function(message) {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[notify]"+message);
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).notify(message);
	return this;
};
// end function to Notify on Screen

// function to Toggle Subtitle Menu
wjs.init.prototype.toggleSubtitles = function() {
	if (this.allElements.length == 1) this.plugin.emitJsMessage("[toggle-subtitles]");
	else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).toggleSubtitles();
	return this;
};
// end function to Toggle Subtitle Menu

// functon to load m3u files
wjs.init.prototype.loadM3U = function(M3Uurl) {
	if (this.allElements.length == 1) {
		if (typeof M3Uurl !== "undefined") this.plugin.emitJsMessage("[load-m3u]"+M3Uurl);
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).loadM3U(M3Uurl);

	return this;
};
// end function to load m3u files

// function to Change Opening Text
wjs.init.prototype.setOpeningText = function(openingtext) {
	if (this.allElements.length == 1) {
		if (typeof openingtext !== "undefined") this.plugin.emitJsMessage("[opening-text]"+openingtext);
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).setOpeningText(openingtext);

	return this;
};
// end function to Change Opening Text

// function to Send Download Percent (for buffering bar)
wjs.init.prototype.setDownloaded = function(downloaded) {
	if (this.allElements.length == 1) {
		if (typeof downloaded !== "undefined") this.plugin.emitJsMessage("[downloaded]"+downloaded);
	} else for (z = 0; z < this.allElements.length; z++) wjs("#"+this.allElements[z].id).setDownloaded(downloaded);

	return this;
};
// end function to Send Download Percent (for buffering bar)
