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

// REGISTER GLOBAL VARIABLES

var lastSecond = 0;
var lastState = 0;
var lastPos = 0;
var lastItem = 0;
var tempSecond = 0;
var pli = 0;
var plstring = "";
var oldRatioWidth = 0;
var oldRatioHeight = 0;

// Required for jump to seconds (while paused)
var notmuted = 0;
var pauseAfterBuffer = 0;
var prevtime = 0;
// End Required for jump to seconds (while paused)

// END REGISTER GLOBAL VARIABLES

// add startsWith function to the String prototype
if (typeof String.prototype.startsWith != 'function') {
  String.prototype.startsWith = function (str){
    return this.slice(0, str.length) == str;
  };
}
// End add startsWith function to the String prototype

// add isJson function to the String prototype
if (typeof String.prototype.isJson != 'function') {
	 String.prototype.isJson = function (){
		try {
			JSON.parse(this);
		} catch (e) {
			return false;
		}
		return true;
	}
}
// end add isJson function to the String prototype

// START CORE FUNCTIONS

// START EVENT FUNCTIONS

// Start on Buffering Changed
function onBuffering( percents ) {
	buftext.changeText = "Buffering " + percents +"%"; // Announce Buffering Percent
	buffering = percents; // Set Global Variable "buffering"
	
	if (percents == 100 && pauseAfterBuffer == 1) {
		pauseAfterBuffer = 0;
		if (vlcPlayer.state == 3) vlcPlayer.togglePause();
	}
}
// End on Buffering Changed

// Start on Current Time Changed
function onTime( seconds ) {
	
	lastTime = tempSecond;
	tempSecond = seconds;
		
	if (vlcPlayer.time > 0) lastPos = vlcPlayer.position;
	
	// Solution to jump to time while video is paused
	if (prevtime > 0 && seconds > prevtime) {
		 pauseAfterBuffer = 0;
		 if (notmuted == 1) if (vlcPlayer.audio.mute) {
			 Wjs.toggleMute();
			 notmuted = 0;
			 prevtime = 0;
		 }
	}
	// End Solution to jump to time while video is paused
	
	// If volume is 0%, set to 40%
	if (multiscreen == 0 && firstvolume == 1) {
		if (vlcPlayer.volume == 0) vlcPlayer.volume = 80;
		volheat.volume = (vlcPlayer.volume /200) * (volheat.width -4);
	}
	if (firstvolume == 1) firstvolume = 2;
	// End If volume is 0%, set to 40%

	// if mute parameter set to true, mute on start	
	if (automute == 1) if (vlcPlayer.volume > 0) {
		vlcPlayer.volume = 0;
		volheat.volume = 0;
		automute = 2;
	}

	// Start on Playlist Video Changed
	if (lastItem != vlcPlayer.playlist.currentItem) {
		lastItem = vlcPlayer.playlist.currentItem;
		ismoving = 1;
		lastSecond = 0;
	}
	// End on Playlist Video Changed
	
	if (seconds < 1200) {
		// Show Previous/Next Buttons if Playlist available
		if (vlcPlayer.playlist.itemCount > 1) {
			prevBut.visible = true;
			nextBut.visible = true;
		}
		// End Show Previous/Next Buttons if Playlist available
		
		refreshMuteIcon();
	}
	
	// Start if mouse is moving above the Video Surface increase "ismoving"
	if (Math.floor(seconds /1000) > lastSecond) {
		// Don't Hide Toolbar if it's Hovered
		lastSecond = Math.floor(seconds /1000);
		if (progressBar.dragpos.containsMouse === false && toolbarBackground.bottomtab.containsMouse === false && playButton.hover.containsMouse === false && prevBut.hover.containsMouse === false && nextBut.hover.containsMouse === false && fullscreenButton.hover.containsMouse === false && playlistButton.hover.containsMouse === false && mutebut.hover.containsMouse === false && volumeMouse.dragger.containsMouse === false && volumeMouse.hover.containsMouse === false) ismoving++;
	}
	// End if mouse is moving above the Video Surface increase "ismoving"
}
// End on Current Time Changed


// Start on State Changed
function onState() {
	if (vlcPlayer.state == 1) {
		buftext.changeText = "Opening";
		subMenu.clearSubtitles();
		if (vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting) var itemSettings = JSON.parse(vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting);
		if (typeof itemSettings !== 'undefined') {
			if (typeof itemSettings.art !== 'undefined' && typeof itemSettings.art === 'string') {
				videoSource.visible = false;
				artwork.source = itemSettings.art;
				artwork.visible = true;
			} else {
				artwork.source = "";
				artwork.visible = false;
				videoSource.visible = true;			
			}
			if (typeof itemSettings.aspectRatio !== 'undefined' && typeof itemSettings.aspectRatio === 'string') {
				var kl = 0;
				for (kl = 0; typeof UI.core.aspectRatios[kl] !== 'undefined'; kl++) if (UI.core.aspectRatios[kl] == itemSettings.aspectRatio) {
					UI.core.curAspect = UI.core.aspectRatios[kl];
					if (UI.core.curAspect == "Default") {
						videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
						videoSource.width = videoSource.parent.width;
						videoSource.height = videoSource.parent.height;
					} else changeAspect(UI.core.curAspect,"ratio");
					break;
				}
			} else if (vlcPlayer.playlist.currentItem > 0) {
				videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
				videoSource.width = videoSource.parent.width;
				videoSource.height = videoSource.parent.height;
				UI.core.curAspect = UI.core.aspectRatios[0];
			}
			if (typeof itemSettings.crop !== 'undefined' && typeof itemSettings.crop === 'string') {
				var kl = 0;
				for (kl = 0; typeof UI.core.crops[kl] !== 'undefined'; kl++) if (UI.core.crops[kl] == itemSettings.crop) {
					UI.core.curCrop = UI.core.crops[kl];
					if (UI.core.curCrop == "Default") {
						videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
						videoSource.width = videoSource.parent.width;
						videoSource.height = videoSource.parent.height;
						UI.core.curCrop = UI.core.crops[0];
					} else {
						changeAspect(UI.core.curCrop,"crop");
					}
					break;
				}
			} else if (vlcPlayer.playlist.currentItem > 0) {
				videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
				videoSource.width = videoSource.parent.width;
				videoSource.height = videoSource.parent.height;
				UI.core.curCrop = UI.core.crops[0];
			}
			if (typeof itemSettings.subtitles !== 'undefined') {
				subMenu.addSubtitleItems(itemSettings.subtitles);
				subButton.visible = true;
			} else {
				subButton.visible = false;
				totalSubs = 0;
			}
		}
	}
		
	// Reconnect if connection to server lost
	if (vlcPlayer.time > 0) {
		if (vlcPlayer.state != 6 && vlcPlayer.state != 7) {
			if (lastState != vlcPlayer.state) lastState = vlcPlayer.state;
		} else if (vlcPlayer.state != 5) {
			if (lastState >= 0 && lastState <= 4) {
				if (lastPos < 0.95) {
					vlcPlayer.playlist.currentItem = lastItem;
					vlcPlayer.playlist.play();
					vlcPlayer.position = lastPos;
				}
				lastState = vlcPlayer.state;
			}
		}
	}
	// End Reconnect if connection to server lost
	
	if (vlcPlayer.state == 6 && autoloop == 1) {
		// autoloop (if set to true)
		vlcPlayer.playlist.currentItem = 0;
		vlcPlayer.playlist.play();
	}
	
	// if title changed, change title in top bar (did this to avoid the "non-NOTIFYable property" errors)
	if (title != vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].title.replace("[custom]","")) title = vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].title.replace("[custom]","");
}
// End on State Changed

// Start on QML Loaded
function onQmlLoaded() {
	UI.core.curAspect = UI.core.aspectRatios[0];
	UI.core.curCrop = UI.core.crops[0];

	vlcPlayer.onMediaPlayerBuffering.connect( onBuffering ); // Set Buffering Event Handler
	vlcPlayer.onMediaPlayerTimeChanged.connect( onTime ); // Set Time Changed Event Handler
	vlcPlayer.onStateChanged.connect( onState ); // Set State Changed Event Handler
	
	plugin.jsMessage.connect( onMessage ); // Catch On Page JS Messages
	
	fireQmlMessage("[qml-loaded]"); // Send message to JS that QML has Loaded

	playlist.addPlaylistItems();
}
// End on QML Loaded


// Start Check On Page JS Message	
function onMessage( message ) {
	if (message.isJson()) {
		var jsonMessage = JSON.parse(message);
		if (jsonMessage["settings"] === true) {
			if (jsonMessage["caching"]) caching = jsonMessage["caching"]; // Get network-caching parameter
			if (jsonMessage["mouseevents"] == 1 || jsonMessage["mouseevents"] === true) UI.core.mouseevents = 1; // Set Mouse Events
			if (jsonMessage["autoplay"] == 1 || jsonMessage["autoplay"] === true || jsonMessage["autostart"] == 1 || jsonMessage["autostart"] == true) vlcPlayer.playlist.playItem(0); // Autoplay
			if (jsonMessage["autoloop"] == 1 || jsonMessage["autoloop"] == true || jsonMessage["loop"] == 1 || jsonMessage["loop"] == true) autoloop = 1; // Autoloop
			if (jsonMessage["mute"] == 1 || jsonMessage["mute"] === true) automute = 1; // Automute
			if (jsonMessage["allowfullscreen"] == 0 || jsonMessage["allowfullscreen"] === false) allowfullscreen = 0; // Allowfullscreen
			if (jsonMessage["multiscreen"] == 1 || jsonMessage["multiscreen"] === true) {
				multiscreen = 1;
				automute = 1;
			}
			if (jsonMessage["titleBar"] == "both" || jsonMessage["titleBar"] == "fullscreen" || jsonMessage["titleBar"] == "minimized" || jsonMessage["titleBar"] == "none") setTitleBar = jsonMessage["titleBar"];
			if (jsonMessage["progressCache"] == 1 || jsonMessage["progressCache"] === true) setCache = true;
		}
	} else {
		if (message.startsWith("[start-subtitle]")) subMenu.playSubtitles(message.replace("[start-subtitle]","")); // Get Subtitle URL and Play Subtitle
		if (message.startsWith("[clear-subtitle]")) subMenu.clearSubtitles(); // Clear Loaded External Subtitle
		if (message.startsWith("[load-m3u]")) playM3U(message.replace("[load-m3u]","")); // Load M3U Playlist URL
	}
	
	
	
}
// End Check On Page JS Message

// END EVENT FUNCTIONS

// Start Set Text to Upper Right Text Element (fades out after 300ms)
function setText(newtext) {
	volumebox.changeText = newtext;
	volumebox.shadowEffectDuration = 1;
	volumebox.textEffectDuration = 0;
	volumebox.textHolder.opacity = 1;
	volumebox.shadowHolder.opacity = 1;
	volumebox.textEffectDuration = 300;	
	timervolume = 1;
}
// End Set Text to Upper Right Text Element (fades out after 300ms)

// Fade Logo In and Out in Splash Screen
function fadeLogo() {
	if (splashScreen.iconOpacity == 1) {
		splashScreen.iconOpacity = 0;
	} else {
		splashScreen.iconOpacity = 1;
	}
}
// End Fade Logo In and Out in Splash Screen

// Refresh Mute Icon
function refreshMuteIcon() {
	mutebut.icon = vlcPlayer.state == 0 ? UI.icon.volume.medium : vlcPlayer.position == 0 && vlcPlayer.playlist.currentItem == 0 ? automute == 0 ? UI.icon.volume.medium : vlcPlayer.audio.mute : vlcPlayer.audio.mute ? UI.icon.mute : vlcPlayer.volume == 0 ? UI.icon.mute : vlcPlayer.volume <= 30 ? UI.icon.volume.low : vlcPlayer.volume > 30 && vlcPlayer.volume <= 134 ? UI.icon.volume.medium : UI.icon.volume.high
}
// End Refresh Mute Icon

// Start Function to get Youtube Title with Youtube API
function setYoutubeTitle(xhr,pli) {
	return function() {
		if (xhr.readyState == 4) {
			var plstring = xhr.responseText;
			plstring = plstring.substr(plstring.indexOf('"title":"')+9);
			plstring = plstring.substr(0,plstring.indexOf('"'));

			vlcPlayer.playlist.items[pli].title = "[custom]"+plstring;
							
			playlist.addPlaylistItems();
		}
	};
}
// End Function to get Youtube Title with Youtube API

// END CORE FUNCTIONS



// START FUNCTIONS RELATED TO FULLSCREEN

// Start Fullscreen Toggle
function togFullscreen() {
	if (allowfullscreen == 1) {
		ismoving = 1;
	
		oldRatioWidth = videoSource.width / videoSource.parent.width;
		oldRatioHeight = videoSource.height / videoSource.parent.height;
		
		progressBar.effectDuration = 0;
		toggleFullscreen();
		
		if (multiscreen == 0) progressBar.effectDuration = 250;
	}
}
// End Fullscreen Toggle

// Start Reset Video Layer Size When Plugin Area Changed Size ( required by togFullscreen() )
function onSizeChanged() {
	if (oldRatioWidth > 0 && oldRatioHeight > 0) {
		videoSource.width = videoSource.parent.width * oldRatioWidth;
		videoSource.height = videoSource.parent.height * oldRatioHeight;
	}
}
// End Reset Video Layer Size When Plugin Area Changed Size ( required by togFullscreen() )

// Start Multiscreen - Fullscreen Functions
function gobig() {
	if (vlcPlayer.state != 1) if (toolbarBackground.bottomtab.containsMouse === false) togFullscreen();
	if (multiscreen == 1) {
		if (vlcPlayer.volume == 0) vlcPlayer.volume = 90;
		volheat.volume = (vlcPlayer.volume /200) * volheat.width;
		if (vlcPlayer.audio.mute) Wjs.toggleMute();
		refreshMuteIcon();
	}
}
function isbig() {
	if (toolbarBackground.bottomtab.containsMouse === false) togPause();
}
// End Multiscreen - Fullscreen Functions

// END FUNCTIONS RELATED TO FULLSCREEN



// START UI INTERACTION FUNCTIONS

// Start Toggle Playlist Menu (open/close)
function togglePlaylist() {
	if (playlistmenu === false) {
		if (subtitlemenu === true) {
			subMenublock.visible = false;
			subtitlemenu = false;
		}
		playlistblock.visible = true;
		playlistmenu = true;
	} else {
		playlistblock.visible = false;
		playlistmenu = false;
	}
}
// End Toggle Playlist Menu (open/close)

// TOGGLE SUBTITLE MENU FUNCTION MOVED TO "/themes/sleek/components/SubtitleMenuItems.qml" (can be called with "subMenu." prefix)

// Start Toggle Mute
function toggleMute() {

	if (vlcPlayer.volume == 0 && vlcPlayer.audio.mute === false) {
		vlcPlayer.volume = 80;
	} else {
		vlcPlayer.toggleMute();
	}
	refreshMuteIcon();
	if (vlcPlayer.audio.mute) {
		volheat.volume = 0;
	} else {
		volheat.volume = (vlcPlayer.volume /200) * volheat.width;
	}
}
// End Toggle Mute

// Start Change Volume on Click or Hover
function clickVolume(mouseX,mouseY) {
	if (mouseX > 0 && mouseX < 116) {
		vlcPlayer.volume = (mouseX / 120) *200;
		volheat.volume = mouseX -2;
	} else if (mouseX <= 0) {
		vlcPlayer.volume = 0;
		volheat.volume = 0;
	} else if (mouseX >= 116) {
		vlcPlayer.volume = 200;
		volheat.volume = 116;
	}
	refreshMuteIcon();
}
function hoverVolume(mouseX,mouseY) {
	if (mouseX > 0 && mouseX < 116) {
		volheat.volume = mouseX -2;
	} else if (mouseX <= 0) {
		volheat.volume = 0;
	} else if (mouseX >= 116) {
		volheat.volume = 116;
	}
}
// End Change Volume on Click or Hover

// Start Progress Bar Seek Functionality
function progressDrag(mouseX,mouseY) {
	dragging = true;
	var newtime = (vlcPlayer.time * (1 / vlcPlayer.position)) * ((mouseX -4) / theview.width);
	if (newtime > 0) timeBubble.srctime = getTime(newtime);
}
function progressChanged(mouseX,mouseY) {
	var newtime = (vlcPlayer.time * (1 / vlcPlayer.position)) * ((mouseX -4) / theview.width);
	if (newtime > 0) timeBubble.srctime = getTime(newtime);
}
function progressReleased(mouseX,mouseY) {
	lastPos = (mouseX -4) / theview.width;
	if (vlcPlayer.state == 6) {
		vlcPlayer.playlist.currentItem = lastItem;
		vlcPlayer.playlist.play();
	}
	vlcPlayer.position = lastPos;
	dragging = false;
}
// End Progress Bar Seek Functionality

// Start Scroll Playlist Menu
function movePlaylist(mousehint) {
	if (mousehint <= (playlistScroll.dragger.height / 2)) {
		playlistScroll.dragger.anchors.topMargin = 0;
		playlist.anchors.topMargin = 0;
	} else if (mousehint >= (240 - (playlistScroll.dragger.height / 2))) {
		playlistScroll.dragger.anchors.topMargin = 240 - playlistScroll.dragger.height;
		if ((vlcPlayer.playlist.itemCount *40) > 240) {
			playlist.anchors.topMargin = 240 - (vlcPlayer.playlist.itemCount *40);
		}
	} else {
		playlistScroll.dragger.anchors.topMargin = mousehint - (playlistScroll.dragger.height / 2);
		playlist.anchors.topMargin = -(((vlcPlayer.playlist.itemCount * 40) - 240) / ((240 - playlistScroll.dragger.height) / (mousehint - (playlistScroll.dragger.height /2))));
	}
}
// End Scroll Playlist Menu

// Start Scroll Subtitle Menu
function moveSubMenu(mousehint) {
	if (mousehint <= (subMenuScroll.dragger.height / 2)) {
		subMenuScroll.dragger.anchors.topMargin = 0;
		subMenu.anchors.topMargin = 0;
	} else if (mousehint >= (240 - (subMenuScroll.dragger.height / 2))) {
		subMenuScroll.dragger.anchors.topMargin = 240 - subMenuScroll.dragger.height;
		if ((totalSubs *40) > 240) {
			subMenu.anchors.topMargin = 240 - (totalSubs *40);
		}
	} else {
		subMenuScroll.dragger.anchors.topMargin = mousehint - (subMenuScroll.dragger.height / 2);
		subMenu.anchors.topMargin = -(((totalSubs * 40) - 240) / ((240 - subMenuScroll.dragger.height) / (mousehint - (totalSubs.dragger.height /2))));
	}
}
// End Scroll Subtitle Menu


// Start Change Volume to New Volume (difference from current volume)
function volumeTo(newvolume,direction) {
	if (direction == "increase" && vlcPlayer.volume < 200) {
		var curvolume = vlcPlayer.volume +newvolume;
		if (curvolume > 200) curvolume = 200;
	}
	if (direction == "decrease" && vlcPlayer.volume > 0) {
		var curvolume = vlcPlayer.volume -newvolume;
		if (curvolume < 0) curvolume = 0;
	}
	if (vlcPlayer.audio.mute) Wjs.toggleMute();
	vlcPlayer.volume = curvolume;
	refreshMuteIcon();
	setText("Volume " + (Math.round((250 * (curvolume /200))/10) *5) + "%");
	volheat.volume = (vlcPlayer.volume /200) * (volheat.width -4);
}
// End Change Volume to New Volume (difference from current volume)

// END UI INTERACTION FUNCTIONS



// START TIME RELATED FUNCTIONS

// Start Functions to Get Time and Video Length (format "00:00:00")
function getTime(t) {
	var tempHour = ("0" + Math.floor(t / 3600000)).slice(-2);
	var tempMinute = ("0" + (Math.floor(t / 60000) %60)).slice(-2);
	var tempSecond = ("0" + (Math.floor(t / 1000) %60)).slice(-2);

	if (getLength() >= 3600000) {
		return tempHour + ":" + tempMinute + ":" + tempSecond;
	} else {
		return tempMinute + ":" + tempSecond;
	}
}

function getLengthTime() {
	var tempHour = (("0" + Math.floor(getLength() / 3600000)).slice(-2));
	var tempMinute = (("0" + (Math.floor(getLength() / 60000) %60)).slice(-2));
	var tempSecond = (("0" + (Math.floor(getLength() / 1000) %60)).slice(-2));
	if (tempSecond < 0) tempSecond =  "00";
	if (getLength() >= 3600000) {
		return tempHour + ":" + tempMinute + ":" + tempSecond;
	} else {
		return tempMinute + ":" + tempSecond;
	}
}
// End Function to Get Time and Video Length (format "00:00:00")


// Start Get Video Length in seconds
function getLength() {
	if (vlcPlayer.length > 0) {
		return vlcPlayer.length;
	} else {
		return vlcPlayer.time * (1 / vlcPlayer.position);
	}
}
// End Get Video Length in seconds

// END TIME RELATED FUNCTIONS



// START PLAYBACK RELATED FUNCTIONS

// Start Toggle Pause
function togPause() {

	if (vlcPlayer.state == 6) {
			
		// if playback ended, restart playback
		vlcPlayer.playlist.currentItem = lastItem;
		vlcPlayer.playlist.play();
		
	} else {
	
		// Change Icon from Pause to Play and vice versa
		if (vlcPlayer.playing) {
			pausetog.visible = true;
			gobigpause = true;
		} else {
			playtog.visible = true;
			gobigplay = true;
		}
		// End Change Icon
		
		if (multiscreen == 1 && fullscreen === false && vlcPlayer.playing === true) {
			
		} else {
			vlcPlayer.togglePause(); // Toggle Pause
		}
		
	}
}
// End Toggle Pause


// Start Change Playback Speed
function rateTo(direction) {
	var newRate = 0;
	var curRate = vlcPlayer.input.rate;

	if (direction == "increase") {
		if (curRate >= 0.25 && curRate < 0.5) newRate = 0.125;
		if (curRate >= 0.5 && curRate < 1) newRate = 0.25;
		if (curRate >= 1 && curRate < 2) newRate = 0.5;
		if (curRate >= 2 && curRate < 4) newRate = 1;
		if (curRate >= 4) newRate = curRate;
		if ((curRate + newRate) < 100) vlcPlayer.input.rate = curRate + newRate;
	}
	if (direction == "decrease") {
		if (curRate > 0.25 && curRate <= 0.5) newRate = 0.125;
		if (curRate > 0.5 && curRate <= 1) newRate = 0.25;
		if (curRate > 1 && curRate <= 2) newRate = 0.5;
		if (curRate > 2 && curRate <= 4) newRate = 1;
		if (curRate > 4) newRate = curRate /2;
		
		if ((curRate + newRate) >= 0.25) vlcPlayer.input.rate = curRate - newRate;
	}
	if (direction == "normal") vlcPlayer.input.rate = 1;

	setText("Speed: " + parseFloat(Math.round(vlcPlayer.input.rate * 100) / 100).toFixed(2) + "x");
}
// End Change Playback Speed


// Start Jump Forward to Frame (frame by frame jump) at Seconds (difference from current position)
function nextFrame(newtime) {
	if (vlcPlayer.state == 3 || vlcPlayer.state == 4) {
		if (notmuted == 0) if (vlcPlayer.audio.mute === false) {
			Wjs.toggleMute();
			notmuted = 1;
		}
		if (vlcPlayer.state == 4) vlcPlayer.togglePause();
		prevtime = vlcPlayer.time +newtime;
		vlcPlayer.time = prevtime;
		vlcPlayer.togglePause();
		pauseAfterBuffer = 1;
	}
}
// End Jump Forward to Frame (frame by frame jump) at Seconds (difference from current position)


// Start Jump to Seconds (difference from current position)
function jumpTo(newtime,direction) {
	if (vlcPlayer.state == 3 || vlcPlayer.state == 4) {
		if (notmuted == 0) if (vlcPlayer.audio.mute === false) {
			Wjs.toggleMute();
			notmuted = 1;
		}
		if (vlcPlayer.state == 4) {
			vlcPlayer.togglePause();
			pauseAfterBuffer = 1;
		}
		if (direction == "forward") prevtime = vlcPlayer.time +newtime;
		if (direction == "backward") prevtime = vlcPlayer.time -newtime;
		vlcPlayer.time = prevtime;
	}		
}
// End Jump to Seconds (difference from current position)

// END PLAYBACK RELATED FUNCTIONS



// START VIDEO LAYER EFFECTS FUNCTIONS

// Start Change Zoom Mode
function changeZoom(newzoom) {
	videoSource.width = videoSource.parent.width * newzoom;
	videoSource.height = videoSource.parent.height * newzoom;
}
// End Change Zoom Mode


// Start Change Aspect Ratio - used to change aspect ratio and crop video layer
function changeAspect(newaspect,newtype) {
	if (newtype == "crop") {
		// if change crop
		videoSource.fillMode = VlcVideoSurface.PreserveAspectCrop;
	} else if (newtype == "ratio") {
		// if change aspect ratio
		videoSource.fillMode = VlcVideoSurface.Stretch;
	}
	
	// Start Set New Video Layer Size
	var res = newaspect.split(":");
	
	var maxWidth = videoSource.parent.width;
	var maxHeight = videoSource.parent.height;

	if (maxWidth < maxHeight) {
		var width = maxWidth * parseFloat(res[0]);
		var height = maxWidth * parseFloat(res[1]);
	} else {
		var width = maxHeight * parseFloat(res[0]);
		var height = maxHeight * parseFloat(res[1]);
	}

	if (width > maxWidth) {
		videoSource.width = maxWidth;
		videoSource.height = height * (maxWidth / width);
	}
	if (height > maxHeight) {
		videoSource.height = maxHeight;
		videoSource.width = width * (maxHeight / height);
	}
	if (height <= maxHeight && width <= maxWidth) {
		videoSource.width = width;
		videoSource.height = height;
	}
	// End Set New Video Layer Size
}
// End Change Aspect Ratio

// END VIDEO LAYER EFFECTS FUNCTIONS



// START FUNCTIONS FOR EXTERNAL FILE SUPPORT (SRT, SUB, M3U)

// EXTERNAL SUBTITLE FUNCTIONS MOVED TO "themes/sleek/components/SubtitleMenuItems.qml" (can be called with "subMenu." prefix)

// Load M3U Playlist
function playM3U(m3uElement) {

	var xhr = new XMLHttpRequest;
	xhr.onreadystatechange = function() {
		if (xhr.readyState == 4) {

			var m3udata = xhr.responseText;
			
			var extension = m3uElement.split('.').pop();
			if (extension.toLowerCase() == "m3u") {
				m3udata = m3udata.replace(/\r\n|\r|\n/g, '\n');
				
				m3udata = strip(m3udata);
				var m3udatay = m3udata.split('\n');

				var s = 0;
				var st = "";
				var itemnr = 0;
				vlcPlayer.playlist.removeItem(0);
				for (s = 1; s < m3udatay.length; s++) {
					if (m3udatay[s].charAt(0) == "#") {
						// get video source title
						st = m3udatay[s].split(',');
						st.shift();
						st = st.join(',');
						// end get video source title
					} else {
						vlcPlayer.playlist.add(m3udatay[s]);
						if (st !== 'undefined' && typeof st === 'string') vlcPlayer.playlist.items[itemnr].title = "[custom]"+st;
						st = "";
						itemnr++;
					}
				}
				if (s > 3) {
					// Adding Playlist Menu Items from M3U File
					playlist.addPlaylistItems();	
					// End Adding Playlist Menu Items from M3U File
					playlistButton.visible = 1;
				}
				vlcPlayer.play();
			}
		}
	}
	xhr.open("get", m3uElement);
	xhr.setRequestHeader("Content-Encoding", "UTF-8");
	xhr.send();
}
// End Load M3U Playlist

// END FUNCTIONS FOR EXTERNAL FILE SUPPORT (SRT, SUB, M3U)