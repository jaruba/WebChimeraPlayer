import QtQuick 2.1
import QmlVlc 0.1

Rectangle {

	// REGISTER GLOBAL VARIABLES
	
	property var lastSecond: 0;
	property var lastState: 0;
	property var lastPos: 0;
	property var lastItem: -1;
	property var tempSecond: 0;
	property var pli: 0;
	property var plstring: "";
	property var oldAspectType: "Default";
	property var oldAspectValue: "Default";
	property var itemnr: 0;
	property var firstSecond: 0;
	property var mediaChanged: 0;
	
	// Required for jump to seconds (while paused)
	property var notmuted: 0;
	property var pauseAfterBuffer: 0;
	property var prevtime: 0;
	// End Required for jump to seconds (while paused)
	
	// END REGISTER GLOBAL VARIABLES
	
	// add startsWith function
	function startsWith(source, target) {
		return source.slice(0, target.length) == target;
	}
	// End add startsWith function
	
	// add isJson function
	function isJson(source) {
		try {
			JSON.parse(source);
		} catch (e) {
			return false;
		}
		return true;
	}
	// end add isJson function
	
	// START CORE FUNCTIONS
	
	// START EVENT FUNCTIONS
	
	// Start on Buffering Changed
	function onBuffering( percents ) {
		buftext.changeText = "Buffering " + percents +"%"; // Announce Buffering Percent
		settings.buffering = percents; // Set Global Variable "buffering"
		
		if (percents == 100 && pauseAfterBuffer == 1) {
			pauseAfterBuffer = 0;
			if (vlcPlayer.state == 3) vlcPlayer.togglePause();
		}
	}
	// End on Buffering Changed
	
	// Start on Media Changed
	function onMediaChanged() {
		mediaChanged = 1;
		
		settings.ismoving = 1;
		lastSecond = 0;
	
		// remove previous subtitles
		subMenublock.visible = false;
		subMenu.clearAll();
		subButton.visible = false;
		// end remove previous subtitles
				
		// Reset properties related to .setTotalLength()
		var changedSettings = false;
		if (settings.customLength > 0) {
			settings.customLength = 0;
			changedSettings = true;
		}
		if (settings.newProgress > 0) {
			settings.newProgress = 0;
			changedSettings = true;
		}
		if (changedSettings) settings = settings;
		delete changedSettings;
		// end Reset properties related to .setTotalLength()

		resetAspect(); // set to default aspect ratio
	}
	// End on Media Changed
	
	// Start on Current Time Changed
	function onTime( seconds ) {
	
		if (mediaChanged == 1) {
			mediaChanged = 0;
			firstSecond = seconds; // implementation for m3u runtime
			settings.subDelay = 0;
			vlcPlayer.subtitle.delay = 0;
		}
	
		var itemSettings = {};
		
		// implementation for m3u runtime
		if (isJson(vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting)) {
			itemSettings = JSON.parse(vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting);
			if (Math.floor(firstSecond/1000) == 0 || Math.floor(firstSecond/1000) == 1) {
				if (typeof itemSettings.runtime !== 'undefined' && itemSettings.runtime == Math.floor(seconds/1000)) {
					if (vlcPlayer.playlist.currentItem == vlcPlayer.playlist.itemCount -1) {
						vlcPlayer.stop();
					} else {
						vlcPlayer.playlist.next();
					}
				}
			} else {
				if (typeof itemSettings.runtime !== 'undefined' && itemSettings.runtime == Math.floor(seconds/1000) - Math.floor(firstSecond/1000)) {
					if (vlcPlayer.playlist.currentItem == vlcPlayer.playlist.itemCount -1) {
						vlcPlayer.stop();
					} else {
						vlcPlayer.playlist.next();
					}
				}
			}
		}
		// end implementation for m3u runtime
		
		settings.lastTime = tempSecond;
		tempSecond = seconds;
		
		settings.newProgress = vlcPlayer.time / getLength();
		settings = settings;
			
		if (vlcPlayer.time > 0) lastPos = vlcPlayer.position;
		
		// Solution to jump to time while video is paused
		if (prevtime > 0 && seconds > prevtime) {
			 pauseAfterBuffer = 0;
			 if (notmuted == 1) if (vlcPlayer.audio.mute) {
				 wjs.toggleMute();
				 notmuted = 0;
				 prevtime = 0;
			 }
		}
		// End Solution to jump to time while video is paused
		
		// If volume is 0%, set to 40%
		if (settings.multiscreen == 0 && settings.firstvolume == 1) {
			if (vlcPlayer.volume == 0) vlcPlayer.volume = 80;
			volheat.volume = (vlcPlayer.volume /200) * (volheat.width -4);
		}
		if (settings.firstvolume == 1) settings.firstvolume = 2;
		// End If volume is 0%, set to 40%
	
		// if mute parameter set to true, mute on start	
		if (settings.automute == 1) if (vlcPlayer.volume > 0) {
			vlcPlayer.volume = 0;
			volheat.volume = 0;
			settings.automute = 2;
		}
	
		if (seconds < 1200) {
			// Show Previous/Next Buttons if Playlist available
			if (vlcPlayer.playlist.itemCount > 1) {
				prevBut.visible = true;
				nextBut.visible = true;
			} else {
				prevBut.visible = false;
				nextBut.visible = false;
			}
			// End Show Previous/Next Buttons if Playlist available
			
			refreshMuteIcon();
		}
		
		// Start if mouse is moving above the Video Surface increase "settings.ismoving"
		if (Math.floor(seconds /1000) > lastSecond) {
			// Don't Hide Toolbar if it's Hovered
			lastSecond = Math.floor(seconds /1000);
			if (progressBar.dragpos.containsMouse === false && toolbarBackground.bottomtab.containsMouse === false && playButton.hover.containsMouse === false && prevBut.hover.containsMouse === false && nextBut.hover.containsMouse === false && fullscreenButton.hover.containsMouse === false && playlistButton.hover.containsMouse === false && mutebut.hover.containsMouse === false && volumeMouse.dragger.containsMouse === false && volumeMouse.hover.containsMouse === false) { settings.ismoving++; settings = settings; }
		}
		// End if mouse is moving above the Video Surface increase "settings.ismoving"
	}
	// End on Current Time Changed
	
	
	// Start on State Changed
	function onState() {
		if (vlcPlayer.state == 1) {
			if (settings.refreshPlaylistItems) settings.refreshPlaylistItems = false;
			else settings.refreshPlaylistItems = true;
			
			settings = settings;
		
			buftext.changeText = "Opening";
			
			if (lastItem != vlcPlayer.playlist.currentItem) lastItem = vlcPlayer.playlist.currentItem;
			if (lastItem == -1) lastItem = 0;
			
			// set aspect ratio
			var itemSettings = {};
	
			if (vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting) itemSettings = JSON.parse(vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting);
	
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
					for (kl = 0; typeof settings.aspectRatios[kl] !== 'undefined'; kl++) if (settings.aspectRatios[kl] == itemSettings.aspectRatio) {
						settings.curAspect = settings.aspectRatios[kl];
						if (settings.curAspect == "Default") {
							videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
							videoSource.width = videoSource.parent.width;
							videoSource.height = videoSource.parent.height;
						} else changeAspect(settings.curAspect,"ratio");
						break;
					}
				} else if (vlcPlayer.playlist.currentItem > 0) {
					videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
					videoSource.width = videoSource.parent.width;
					videoSource.height = videoSource.parent.height;
					settings.curAspect = settings.aspectRatios[0];
				}
				if (typeof itemSettings.crop !== 'undefined' && typeof itemSettings.crop === 'string') {
					var kl = 0;
					for (kl = 0; typeof settings.crops[kl] !== 'undefined'; kl++) if (settings.crops[kl] == itemSettings.crop) {
						settings.curCrop = settings.crops[kl];
						if (settings.curCrop == "Default") {
							videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
							videoSource.width = videoSource.parent.width;
							videoSource.height = videoSource.parent.height;
							settings.curCrop = settings.crops[0];
						} else {
							changeAspect(settings.curCrop,"crop");
						}
						break;
					}
				} else if (vlcPlayer.playlist.currentItem > 0) {
					videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
					videoSource.width = videoSource.parent.width;
					videoSource.height = videoSource.parent.height;
					settings.curCrop = settings.crops[0];
				}
			}
			// end set aspect ratio
		}
		
		// Load Internal and External Subtitles (when playback starts)
		if (vlcPlayer.state == 3 && subButton.visible === false) {
			var itemSettings = {};
			if (isJson(vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting)) itemSettings = JSON.parse(vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].setting);
			var doSubs = false;
			if (typeof itemSettings.subtitles !== 'undefined' && itemSettings.hasOwnProperty('subtitles') === true) doSubs = true;					
			if (vlcPlayer.subtitle.count > 1) doSubs = true;
			if (doSubs) {
				subButton.visible = true;
				subMenu.addSubtitleItems(itemSettings.subtitles);
				subMenuScroll.dragger.anchors.topMargin = 0;
				subMenu.anchors.topMargin = 0;
			}			
		}
		// End Load Internal and External Subtitles
			
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
		
		if (vlcPlayer.state == 6 && settings.autoloop == 1) {
			// autoloop (if set to true)
			vlcPlayer.playlist.currentItem = 0;
			vlcPlayer.playlist.play();
		}
		
		// if title changed, change title in top bar (did this to avoid the "non-NOTIFYable property" errors)
		if (settings.title != settings.titleCache[vlcPlayer.playlist.currentItem]) settings.title = settings.titleCache[vlcPlayer.playlist.currentItem];
	}
	// End on State Changed
	
	// Start on QML Loaded
	function onQmlLoaded() {
		settings.curAspect = settings.aspectRatios[0];
		settings.curCrop = settings.crops[0];
	
		vlcPlayer.onMediaPlayerBuffering.connect( onBuffering ); // Set Buffering Event Handler
		vlcPlayer.onMediaPlayerTimeChanged.connect( onTime ); // Set Time Changed Event Handler
		vlcPlayer.onMediaPlayerMediaChanged.connect( onMediaChanged );
		vlcPlayer.onStateChanged.connect( onState ); // Set State Changed Event Handler
		pip.vSource.onMediaPlayerPositionChanged.connect( pip.keepMuted ); // Keep Picture in Picture Video Muted
		
		if (typeof plugin.version !== "undefined") vlcPlayer.subtitle.onLoadError.connect( subMenu.subtitleError );
		
		plugin.jsMessage.connect( onMessage ); // Catch On Page JS Messages
		
		fireQmlMessage("[qml-loaded]"); // Send message to JS that QML has Loaded
		
		if (vlcPlayer.playlist.itemCount > 0) playlist.addPlaylistItems();
		
		if (settings.autoplay == 1 && vlcPlayer.state == 0 && vlcPlayer.playlist.itemCount > 0) vlcPlayer.playlist.playItem(0); 
	}
	// End on QML Loaded
	
	
	// Start Check On Page JS Message	
	function onMessage( message ) {
		if (isJson(message)) {
			var jsonMessage = JSON.parse(message);
			ui = skinData.variables;
			if (jsonMessage["settings"] === true) {
				if (jsonMessage["toolbar"] == 0 || jsonMessage["toolbar"] === false) { settings.toolbar = 0; settings = settings; }
				if (jsonMessage["caching"]) settings.cache = jsonMessage["caching"]; // Get network-caching parameter
				if (jsonMessage["mouseevents"] == 1 || jsonMessage["mouseevents"] === true) settings.mouseevents = 1; // Set Mouse Events
				if (jsonMessage["autoplay"] == 1 || jsonMessage["autoplay"] === true || jsonMessage["autostart"] == 1 || jsonMessage["autostart"] == true) {
					// Autoplay
					if (vlcPlayer.state == 0 && vlcPlayer.playlist.itemCount > 0) vlcPlayer.playlist.playItem(0);
					settings.autoplay = 1;
				}
				if (jsonMessage["autoloop"] == 1 || jsonMessage["autoloop"] == true || jsonMessage["loop"] == 1 || jsonMessage["loop"] == true) settings.autoloop = 1; // Autoloop
				if (jsonMessage["mute"] == 1 || jsonMessage["mute"] === true) settings.automute = 1; // Automute
				if (jsonMessage["allowfullscreen"] == 0 || jsonMessage["allowfullscreen"] === false) settings.allowfullscreen = 0;
				if (jsonMessage["digitalZoom"] == 1 || jsonMessage["digitalZoom"] === true) { settings.digitalzoom = 1; settings = settings; }
				if (jsonMessage["pip"] == 1 || jsonMessage["pip"] === true) { settings.pip = 1; settings = settings; }
				if (jsonMessage["multiscreen"] == 1 || jsonMessage["multiscreen"] === true) {
					settings.multiscreen = 1;
					settings.automute = 1;
				}
				if (jsonMessage["titleBar"] == "both" || jsonMessage["titleBar"] == "fullscreen" || jsonMessage["titleBar"] == "minimized" || jsonMessage["titleBar"] == "none") ui.settings.titleBar = jsonMessage["titleBar"];
				if (jsonMessage["progressCache"] == 1 || jsonMessage["progressCache"] === true) ui.settings.caching = true;
				if (jsonMessage["debugPlaylist"] == 1 || jsonMessage["debugPlaylist"] === true) { settings.debugPlaylist = true; settings = settings; }
			}
			if (jsonMessage["skinning"] === true) {
				if (jsonMessage["fonts"]) {
					var skinFonts = jsonMessage["fonts"];
					if (skinFonts["icons"]) ui.settings.iconFont = skinFonts["icons"];
					if (skinFonts["text"]) {
						var textFont = skinFonts["text"];
						if (textFont["default"]) ui.settings.defaultFont = textFont["default"];
						if (textFont["secondary"]) ui.settings.secondaryFont = textFont["secondary"];
					}
				}
				if (jsonMessage["toolbar"]) {
					var skinToolbar = jsonMessage["toolbar"];
					if (skinToolbar["settings"]) {
						var tbSettings = skinToolbar["settings"];
						if (tbSettings["button"]) {
							var btSettings = tbSettings["button"];
							if (btSettings["width"]) buttonWidth = btSettings["width"];
							if (btSettings["muteWidth"]) ui.settings.toolbar.buttonMuteWidth = btSettings["muteWidth"];
							if (btSettings["hoverGlow"]) ui.settings.buttonGlow = btSettings["hoverGlow"];
							if (typeof btSettings["borderVisible"] !== "undefined") borderVisible = btSettings["borderVisible"];
						}
						if (typeof tbSettings["timeMargin"] !== "undefined") timeMargin = tbSettings["timeMargin"];
						if (typeof tbSettings["opacity"] !== "undefined") ui.settings.toolbar.opacity = tbSettings["opacity"];
					}
					if (skinToolbar["colors"]) {
						var tbColors = skinToolbar["colors"];
						if (tbColors["button"]) ui.colors.toolbar.button = tbColors["button"];
						if (tbColors["buttonHover"]) ui.colors.toolbar.buttonHover = tbColors["buttonHover"];
						if (tbColors["border"]) ui.colors.toolbar.border = tbColors["border"];
						if (tbColors["currentTime"]) ui.colors.toolbar.currentTime = tbColors["currentTime"];
						if (tbColors["lengthTime"]) ui.colors.toolbar.lengthTime = tbColors["lengthTime"];
						if (tbColors["background"]) ui.colors.background = tbColors["background"];
						if (tbColors["progressBar"]) {
							var tbProgress = tbColors["progressBar"];
							if (tbProgress["background"]) ui.colors.progress.background = tbProgress["background"];
							if (tbProgress["viewed"]) ui.colors.progress.viewed = tbProgress["viewed"];
							if (tbProgress["position"]) ui.colors.progress.position = tbProgress["position"];
							if (tbProgress["cache"]) ui.colors.progress.cache = tbProgress["cache"];
						}
						if (tbColors["volume"]) {
							var tbVolume = tbColors["volume"];
							if (tbVolume["background"]) ui.colors.volumeHeat.background = tbVolume["background"];
							if (tbVolume["color"]) ui.colors.volumeHeat.color = tbVolume["color"];
						}
					}
					if (skinToolbar["icons"]) {
						var tbIcons = skinToolbar["icons"];
						if (tbIcons["prev"]) ui.icon.prev = tbIcons["prev"];
						if (tbIcons["next"]) ui.icon.next = tbIcons["next"];
						if (tbIcons["play"]) ui.icon.play = tbIcons["play"];
						if (tbIcons["pause"]) ui.icon.pause = tbIcons["pause"];
						if (tbIcons["mute"]) ui.icon.mute = tbIcons["mute"];
						if (tbIcons["subtitles"]) ui.icon.subtitles = tbIcons["subtitles"];
						if (tbIcons["playlist"]) ui.icon.playlist = tbIcons["playlist"];
						if (tbIcons["minimize"]) ui.icon.minimize = tbIcons["minimize"];
						if (tbIcons["maximize"]) ui.icon.maximize = tbIcons["maximize"];
					}
				}
				ui = ui;
			}		
		} else {
			if (startsWith(message,"[hide-toolbar]")) { settings.toolbar = 0; settings = settings; } // Hide Toolbar
			if (startsWith(message,"[show-toolbar]")) { settings.toolbar = 1; settings = settings; } // Show Toolbar
			if (startsWith(message,"[toggle-toolbar]")) { toggleToolbar(); } // Toggle Toolbar Visibility
			if (startsWith(message,"[toggle-ui]")) { toggleUI(); } // Toggle UI Visibility
			if (startsWith(message,"[hide-ui]")) { hideUI(); } // Hide UI
			if (startsWith(message,"[show-ui]")) { showUI(); } // Show UI
			if (startsWith(message,"[toggle-playlist]")) { togglePlaylist(); } // Toggle Playlist
			if (startsWith(message,"[start-subtitle]")) playSubtitles(message.replace("[start-subtitle]","")); // Get Subtitle URL and Play Subtitle
			if (startsWith(message,"[clear-subtitle]")) clearSubtitles(); // Clear Loaded External Subtitle
			if (startsWith(message,"[load-m3u]")) playM3U(message.replace("[load-m3u]","")); // Load M3U Playlist URL
			if (startsWith(message,"[set-total-length]")) settings.customLength = message.replace("[set-total-length]",""); // Set custom total length
			if (startsWith(message,"[reset-progress]")) {
				// Reset properties related to .setTotalLength()
				var changedSettings = false;
				if (settings.customLength > 0) {
					settings.customLength = 0;
					changedSettings = true;
				}
				if (settings.newProgress > 0) {
					settings.newProgress = 0;
					changedSettings = true;
				}
				if (changedSettings) settings = settings;
				delete changedSettings;
				// end Reset properties related to .setTotalLength()
			}
			if (startsWith(message,"[swap-items]")) {
				vlcPlayer.playlist.advanceItem(message.replace("[swap-items]","").split("|")[0],message.replace("[swap-items]","").split("|")[1]);
				playlist.addPlaylistItems(); // Refresh Playlist GUI
			}
			if (startsWith(message,"[sub-size]")) {
				settings.subSize = parseInt(message.replace("[sub-size]",""));
				settings = settings;
			}
			if (startsWith(message,"[sub-delay]")) {
				settings.subDelay = parseInt(message.replace("[sub-delay]",""));
				vlcPlayer.subtitle.delay = settings.subDelay;
			}
			if (startsWith(message,"[audio-delay]")) {
				settings.audioDelay = parseInt(message.replace("[audio-delay]",""));
				vlcPlayer.audio.delay = settings.audioDelay;
			}
			if (startsWith(message,"[notify]")) setText(message.replace("[notify]",""));
			if (startsWith(message,"[toggle-mute]")) toggleMute();
			if (startsWith(message,"[set-mute]")) { setMute(message.replace("[set-mute]","")); }
			if (startsWith(message,"[toggle-subtitles]")) toggleSubtitles();
			if (startsWith(message,"[set-volume]")) { vlcPlayer.volume = parseInt(message.replace("[set-volume]","")); volheat.volume = (parseInt(message.replace("[set-volume]","")) /200) * volheat.width; }
			if (startsWith(message,"[aspect-ratio]")) changeAspect(message.replace("[aspect-ratio]",""),"ratio");
			if (startsWith(message,"[crop]")) changeAspect(message.replace("[crop]",""),"crop");
			if (startsWith(message,"[zoom]")) changeZoom(parseFloat(message.replace("[zoom]","")));
			if (startsWith(message,"[next-frame]")) nextFrame(parseInt(message.replace("[next-frame]","")));
			if (startsWith(message,"[reset-size]")) resetAspect();
			if (startsWith(message,"[select-subtitle]")) selectSubtitle(parseInt(message.replace("[select-subtitle]","")));
			if (startsWith(message,"[refresh-playlist]")) {
				playlist.addPlaylistItems(); // Refresh Playlist GUI
				if (vlcPlayer.playlist.itemCount > 1) {
					playlistButton.visible = 1;
					prevBut.visible = true;
					nextBut.visible = true;
				} else {
					playlistButton.visible = 0;
					prevBut.visible = false;
					nextBut.visible = false;
				}
				if (settings.autoplay == 1 && vlcPlayer.state == 0 && vlcPlayer.playlist.itemCount > 0) vlcPlayer.playlist.playItem(0); 
			}
			if (startsWith(message,"[downloaded]")) { settings.downloaded = parseFloat(message.replace("[downloaded]","")); settings = settings; } // Get Downloaded Percent
			if (startsWith(message,"[opening-text]")) { settings.openingText = message.replace("[opening-text]",""); settings = settings; } // Get New Opening Text
			
			// implementation for .preventDefault()
			if (startsWith(message,"[stop-pressed]")) settings.preventKey[message.replace("[stop-pressed]","")] = true;
			if (startsWith(message,"[start-pressed]")) delete settings.preventKey[message.replace("[start-pressed]","")];
			if (startsWith(message,"[stop-clicked]")) settings.preventClicked[message.replace("[stop-clicked]","")] = true;
			if (startsWith(message,"[start-clicked]")) delete settings.preventClicked[message.replace("[start-clicked]","")];
			// end implementation for .preventDefault()
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
		settings.timervolume = 1;
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
		volheat.volume = vlcPlayer.audio.mute ? 0 : (vlcPlayer.volume /200) * (volheat.width -4);
		mutebut.icon = vlcPlayer.state == 0 ? ui.icon.volume.medium : vlcPlayer.position == 0 && vlcPlayer.playlist.currentItem == 0 ? settings.automute == 0 ? ui.icon.volume.medium : ui.icon.mute : vlcPlayer.audio.mute ? ui.icon.mute : vlcPlayer.volume == 0 ? ui.icon.mute : vlcPlayer.volume <= 30 ? ui.icon.volume.low : vlcPlayer.volume > 30 && vlcPlayer.volume <= 134 ? ui.icon.volume.medium : ui.icon.volume.high
	}
	// End Refresh Mute Icon
	
		
	// END CORE FUNCTIONS
	
	
	
	// START FUNCTIONS RELATED TO FULLSCREEN
	
	// Start Fullscreen Toggle
	function togFullscreen() {
		if (settings.allowfullscreen == 1) {
			settings.ismoving = 1;
		
			progressBar.effectDuration = 0;
			toggleFullscreen();

			if (oldAspectType != "Default") {
				if (oldAspectType == "zoom") changeZoom(oldAspectValue);
				else changeAspect(oldAspectValue,oldAspectType);
			} else resetAspect();
						
			if (settings.multiscreen == 0) progressBar.effectDuration = 250;
		}
	}
	// End Fullscreen Toggle
	
	// Start Reset Video Layer Size When Plugin Area Changed Size ( required by togFullscreen() )
	function onSizeChanged() {
		if (oldAspectType != "Default") {
			if (oldAspectType == "zoom") changeZoom(oldAspectValue);
			else changeAspect(oldAspectValue,oldAspectType);
		} else resetAspect();
	}
	// End Reset Video Layer Size When Plugin Area Changed Size ( required by togFullscreen() )
	
	// Start Multiscreen - Fullscreen Functions
	function gobig() {
		if (vlcPlayer.state != 1) if (toolbarBackground.bottomtab.containsMouse === false) togFullscreen();
		if (settings.multiscreen == 1) {
			if (vlcPlayer.volume == 0) vlcPlayer.volume = 90;
			volheat.volume = (vlcPlayer.volume /200) * volheat.width;
			if (vlcPlayer.audio.mute) wjs.toggleMute();
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
		if (!playlistblock.visible) {
			if (subMenublock.visible) subMenublock.visible = false;
			playlistblock.visible = true;
		} else playlistblock.visible = false;
	}
	// End Toggle Playlist Menu (open/close)
	
	// Toggle Toolbar Visibility
	function toggleToolbar() {
		if (settings.toolbar == 1) {
			settings.toolbar = 0;
		} else settings.toolbar = 1;
		settings = settings;
	}
	// End Toggle Toolbar Visibility
	
	// Toggle UI Visibility
	function hideUI() {
		if (settings.uiVisible) {
			settings.uiVisible = 0;
			if (playlistblock.visible) playlistblock.visible = false;
			if (subMenublock.visible) subMenublock.visible = false;
		}
		settings = settings;
	}
	function showUI() {
		if (!settings.uiVisible) settings.uiVisible = 1;
		settings = settings;
	}
	function toggleUI() {
		if (settings.uiVisible) {
			hideUI();
		} else showUI();
	}
	// End Toggle UI Visibility
	
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
	
	// Start Toggle Mute
	function setMute(newMute) {
		vlcPlayer.audio.mute = newMute;
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
		if (vlcPlayer.audio.mute) vlcPlayer.audio.mute = false;
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
		settings.dragging = true;
		var newtime = (vlcPlayer.time * (1 / settings.newProgress)) * ((mouseX -4) / theview.width);
		if (newtime > 0) timeBubble.srctime = getTime(newtime);
	}
	function progressChanged(mouseX,mouseY) {
		var newtime = (vlcPlayer.time * (1 / settings.newProgress)) * ((mouseX -4) / theview.width);
		if (newtime > 0) timeBubble.srctime = getTime(newtime);
	}
	function progressReleased(mouseX,mouseY) {
		lastPos = (mouseX -4) / theview.width;
		if (vlcPlayer.state == 6) {
			vlcPlayer.playlist.currentItem = lastItem;
			vlcPlayer.playlist.play();
		}
		// calculate new player time and set it in the player
		vlcPlayer.time = (vlcPlayer.time * (1 / settings.newProgress)) * ((mouseX -4) / theview.width);
		settings.dragging = false;
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
			if ((settings.totalSubs *40) > 240) {
				subMenu.anchors.topMargin = 240 - (settings.totalSubs *40);
			}
		} else {
			subMenuScroll.dragger.anchors.topMargin = mousehint - (subMenuScroll.dragger.height / 2);
			subMenu.anchors.topMargin = -(((settings.totalSubs * 40) - 240) / ((240 - subMenuScroll.dragger.height) / (mousehint - (subMenuScroll.dragger.height /2))));
		}
	}
	// End Scroll Subtitle Menu
	
	
	// Start Change Volume to New Volume (difference from current volume)
	function volumeTo(newvolume) {
		if (newvolume >= 0 && vlcPlayer.volume < 200) {
			var curvolume = vlcPlayer.volume +newvolume;
			if (curvolume > 200) curvolume = 200;
		}
		if (newvolume < 0 && vlcPlayer.volume > 0) {
			var curvolume = vlcPlayer.volume +newvolume;
			if (curvolume < 0) curvolume = 0;
		}
		if (vlcPlayer.audio.mute) wjs.toggleMute();
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
		if (isNaN(tempHour)) return "";
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
    	} else if (settings.customLength > 0) {
			return settings.customLength;
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
				settings.gobigpause = true;
			} else {
				playtog.visible = true;
				settings.gobigplay = true;
			}
			// End Change Icon
			
			if (settings.multiscreen == 1 && fullscreen === false && vlcPlayer.playing === true) {
				
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
				wjs.toggleMute();
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
	function jumpTo(newtime) {
		if (vlcPlayer.state == 3 || vlcPlayer.state == 4) {
			if (notmuted == 0) if (vlcPlayer.audio.mute === false) {
				wjs.toggleMute();
				notmuted = 1;
			}
			if (vlcPlayer.state == 4) {
				vlcPlayer.togglePause();
				pauseAfterBuffer = 1;
			}
			prevtime = vlcPlayer.time +newtime;
			vlcPlayer.time = prevtime;
		}		
	}
	// End Jump to Seconds (difference from current position)
	
	// END PLAYBACK RELATED FUNCTIONS
	
	
	
	// START VIDEO LAYER EFFECTS FUNCTIONS
	
	function gcd(a,b) {
		if(b>a) {
			var temp = a;
			a = b;
			b = temp;
		}
		while(b!=0) {
			var m=a%b;
			a=b;
			b=m;
		}
		return a;
	}
	
	// Start Change Zoom Mode
	function changeZoom(newzoom) {
		videoSource.width = videoSource.parent.width * newzoom;
		videoSource.height = videoSource.parent.height * newzoom;
		oldAspectType = "zoom";
		oldAspectValue = newzoom;
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
		
		var ratio = gcd(vlcPlayer.video.width,vlcPlayer.video.height);
		
		var destAspect = videoSource.parent.width / videoSource.parent.height;
		
		if (ratio) var sourceAspect = (ratio * parseFloat(res[0])) / (ratio * parseFloat(res[1]));
		else var sourceAspect = vlcPlayer.video.width / vlcPlayer.video.height;
		
		var cond = destAspect > sourceAspect;

		if (cond) {
			videoSource.height = videoSource.parent.height;
			videoSource.width = videoSource.parent.height * sourceAspect;
		} else {
			videoSource.height = videoSource.parent.width / sourceAspect;
			videoSource.width = videoSource.parent.width;
		}
		
		oldAspectType = newtype;
		oldAspectValue = newaspect;
		
		// End Set New Video Layer Size
	}
	
	function resetAspect() {
		settings.curAspect = "Default";
		settings.curCrop = "Default";
		settings.curZoom = 0;
		videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
		videoSource.width = videoSource.parent.width;
		videoSource.height = videoSource.parent.height;
		oldAspectType = "Default";
		oldAspectValue = "Default";
	}
	// End Change Aspect Ratio
	
	// END VIDEO LAYER EFFECTS FUNCTIONS
	
	
	// START FUNCTIONS FOR EXTERNAL FILE SUPPORT (SRT, SUB, M3U)
	
	// EXTERNAL SUBTITLE FUNCTIONS MOVED TO "themes/sleek/components/SubtitleMenuItems.qml" (can be called with "subMenu." prefix)
	
	// Proxy functions to expose the subtitle functions from "subMenu." prefix
	function toggleSubtitles() {
		subMenu.toggleSubtitles();
	}
	function selectSubtitle(selSub) {
		subMenu.selectSubtitle(selSub);
	}
	function playSubtitles(subtitleElement) {
		subMenu.playSubtitles(subtitleElement);
	}
	function clearSubtitles() {
		subMenu.clearSubtitles();
	}
	// End proxy functions to expose the subtitle functions from "subMenu." prefix
	
	function strip(s) {
		return s.replace(/^\s+|\s+$/g,"");
	}
	
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

					var tmpRuntime = 0;
					for (s = 1; s < m3udatay.length; s++) {
						if (m3udatay[s].substr(0,7) == "#EXTINF") {
							// get video source title
							st = m3udatay[s].split(',');
							st.shift();
							st = st.join(',');
							// end get video source title
						} else if (m3udatay[s].substr(0,20) == "#EXTVLCOPT:run-time=") {
							tmpRuntime = parseInt(m3udatay[s].replace("#EXTVLCOPT:run-time=",""));
						} else {
							vlcPlayer.playlist.add(m3udatay[s]);
							if (typeof st !== 'undefined' && typeof st === 'string') vlcPlayer.playlist.items[itemnr].title = "[custom]"+st;
							if (typeof tmpRuntime !== 'undefined' && tmpRuntime > 0) {
								var tmpSettings = {};
								if (isJson(vlcPlayer.playlist.items[itemnr].setting)) {
									tmpSettings = JSON.parse(vlcPlayer.playlist.items[itemnr].setting);
									tmpSettings.runtime = tmpRuntime;
								} else {
									tmpSettings.runtime = tmpRuntime;
								}
								vlcPlayer.playlist.items[itemnr].setting = JSON.stringify(tmpSettings);
								delete tmpSettings;
								tmpRuntime = 0;
							}
							st = "";
							itemnr++;
						}
					}
					if (vlcPlayer.playlist.itemCount > 1) {
						playlist.addPlaylistItems(); // Refresh Playlist Menu GUI
						playlistButton.visible = 1;
						prevBut.visible = true;
						nextBut.visible = true;
					} else {
						playlistButton.visible = 0;
						prevBut.visible = false;
						nextBut.visible = false;
					}
					if (vlcPlayer.state == 0) vlcPlayer.play();
				}
			}
		}
		xhr.open("get", m3uElement);
		xhr.setRequestHeader("Content-Encoding", "UTF-8");
		xhr.send();
	}
	// End Load M3U Playlist
	
	// END FUNCTIONS FOR EXTERNAL FILE SUPPORT (SRT, SUB, M3U)

}