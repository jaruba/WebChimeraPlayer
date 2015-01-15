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

var mouseClicked = 0; // Fix for Missing Clicks

// START HOTKEYS
function Keys(event) {
	if (event.key == Qt.Key_Space) { Wjs.togPause(); }
	if (event.key == Qt.Key_Escape) {
		if (fullscreen) {
			fullscreen = false;
			if (multiscreen == 1) if (vlcPlayer.audio.mute === false) vlcPlayer.toggleMute(); // Multiscreen - Mute on Playback Start
		}
	}
	if (event.key == Qt.Key_F || event.key == Qt.Key_F11) {
		Wjs.togFullscreen();
	}
	if (event.key == Qt.Key_E) {
		Wjs.nextFrame(500);
	}
	if (event.key == Qt.Key_N) {
		vlcPlayer.playlist.next();
	}
	if(event.modifiers == Qt.ControlModifier) {
		if (event.key == Qt.Key_Right) {
			Wjs.jumpTo(60000,"forward");
		} else if (event.key == Qt.Key_Left) {
			Wjs.jumpTo(60000,"backward");
		} else if (event.key == Qt.Key_Up) {
			Wjs.volumeTo(8,"increase");
		} else if (event.key == Qt.Key_Down) {
			Wjs.volumeTo(8,"decrease");
		} else if (event.key == Qt.Key_L) {
			Wjs.togglePlaylist();
		}
	}
	if(event.modifiers == Qt.AltModifier) {
		if (event.key == Qt.Key_Right) {
			Wjs.jumpTo(10000,"forward");
		} else if (event.key == Qt.Key_Left) {
			Wjs.jumpTo(10000,"backward");
		}
	}
	if (event.key == Qt.Key_M) {
		Wjs.toggleMute();
		if (vlcPlayer.audio.mute) {
			Wjs.setText("Muted");
		} else {
			Wjs.setText("Volume " + (Math.round((250 * (vlcPlayer.volume /200))/10) *5) + "%");
		}
		Wjs.refreshMuteIcon();
	}
	if (event.key == Qt.Key_P) {
		vlcPlayer.time = 0;
	}
	if (event.key == Qt.Key_Plus || event.key == Qt.Key_BracketRight) {
		Wjs.rateTo("increase");
	}
	if (event.key == Qt.Key_Minus || event.key == Qt.Key_BracketLeft) {
		Wjs.rateTo("decrease");
	}
	if (event.key == Qt.Key_Equal) {
		Wjs.rateTo("normal");
	}
	if (event.key == Qt.Key_A) {
		var kl = 0;
		for (kl = 0; typeof UI.core.aspectRatios[kl] !== 'undefined'; kl++) if (UI.core.aspectRatios[kl] == vlcPlayer.video.aspectRatio) {
			if (typeof UI.core.aspectRatios[kl+1] !== 'undefined') {
				vlcPlayer.video.aspectRatio = UI.core.aspectRatios[kl+1];
			} else vlcPlayer.video.aspectRatio = UI.core.aspectRatios[0];
			
			if (vlcPlayer.video.aspectRatio == "Default") {
				videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
				videoSource.width = videoSource.parent.width;
				videoSource.height = videoSource.parent.height;
			} else {
				Wjs.changeAspect(vlcPlayer.video.aspectRatio,"ratio");
			}
			
			Wjs.setText("Aspect Ratio: " + vlcPlayer.video.aspectRatio);
			break;
		}
	}
	if (event.key == Qt.Key_C) {
		var kl = 0;
		for (kl = 0; typeof UI.core.crops[kl] !== 'undefined'; kl++) if (UI.core.crops[kl] == vlcPlayer.video.crop) {
			if (typeof UI.core.crops[kl+1] !== 'undefined') {
				vlcPlayer.video.crop = UI.core.crops[kl+1];
			} else vlcPlayer.video.crop = UI.core.crops[0];
			if (vlcPlayer.video.crop == "Default") {
				videoSource.fillMode = VlcVideoSurface.PreserveAspectFit;
				videoSource.width = videoSource.parent.width;
				videoSource.height = videoSource.parent.height;
			} else {
				Wjs.changeAspect(vlcPlayer.video.crop,"crop");
			}
			
			Wjs.setText("Crop: " + vlcPlayer.video.crop);
			break;
		}
	}
	if (event.key == Qt.Key_Z) {
		var kl = 0;
		for (kl = 0; typeof UI.core.zooms[kl] !== 'undefined'; kl++) if (UI.core.curZoom == kl) {
			if (typeof UI.core.zooms[kl+1] !== 'undefined') {
				UI.core.curZoom = kl +1;
			} else UI.core.curZoom = 0;
			
			Wjs.changeZoom(UI.core.zooms[UI.core.curZoom][0]);
			
			Wjs.setText("Zoom Mode: " + UI.core.zooms[UI.core.curZoom][1]);
			break;
		}
	}
	if (event.key == Qt.Key_T) {
		Wjs.setText(showtime.text.trim());
	}
	if(event.modifiers == Qt.AltModifier) {
		if (event.key == Qt.Key_Right) {
			Wjs.jumpTo(10000,"forward");
		} else if (event.key == Qt.Key_Left) {
			Wjs.jumpTo(10000,"backward");
		}
	}
	if(event.modifiers == Qt.ShiftModifier) {
		if (event.key == Qt.Key_Right) {
			Wjs.jumpTo(3000,"forward");
		} else if (event.key == Qt.Key_Left) {
			Wjs.jumpTo(3000,"backward");
		}
	}
}
// END HOTKEYS


// MOUSE ACTIONS
function MouseScroll(mouseX,mouseY) {
	// Change Volume on Mouse Scroll
	if (mouseY > 0) Wjs.volumeTo(8,"increase");
	if (mouseY < 0) Wjs.volumeTo(8,"decrease");
	// End Change Volume on Mouse Scroll
}
function MouseMoved(mouseX,mouseY) {
	ismoving = 1;  // Reset Idle Mouse Movement if mouse position has changed
	
	if (UI.core.mouseevents == 1) {
		// JavaScript Mouse Events Demo
		var sendjsdata = {};
		sendjsdata["type"] = "mouseMove";
		sendjsdata["x"] = mouseX;
		sendjsdata["y"] = mouseY;
		
		fireQmlMessage(JSON.stringify(sendjsdata));
	}
}
function MouseDblClick(clicked) {
	if (multiscreen == 0) {
		if (UI.core.mouseevents == 1) {
			// JavaScript Mouse Events Demo
			if (vlcPlayer.state != 1) if (toolbarBackground.bottomtab.containsMouse === false) if (clicked == Qt.LeftButton) {
				var sendjsdata = {};
				sendjsdata["type"] = "mouseDoubleClick";
				
				fireQmlMessage(JSON.stringify(sendjsdata));
			}
		}
		var doit = 0;
		if (clicked == Qt.LeftButton) {
			if (multiscreen == 0) doit = 1;
			if (fullscreen) if (multiscreen == 1) doit = 1;
		}
		if (doit == 1) {
					
			if (vlcPlayer.state == 4) Wjs.togPause();
				
			gobigpause = false;
			gobigplay = false;
			pausetog.visible = false;
			playtog.visible = false;
			if (!fullscreen) mouseClicked = 1; // Fix for Missing Clicks
			Wjs.togFullscreen();
			mousesurface.focus = true;
		}
	}
	if (multiscreen == 1) MouseClicked(clicked); // Multiscreen does not support Fullscreen Toggle on Double Click
}
function MouseClick(clicked) {
	mouseClicked = 1; // Fix for Missing Clicks
	if (toolbarBackground.bottomtab.containsMouse === false) {
		var sendjsdata = {};

		if (clicked == Qt.RightButton) {
			// JavaScript Mouse Events Demo
			if (UI.core.mouseevents == 1) {
				sendjsdata["type"] = "mouseRightClick";
				fireQmlMessage(JSON.stringify(sendjsdata));
			}
		} else {
			if (multiscreen == 0) {
				if (vlcPlayer.state != 1) Wjs.isbig(); // Toggle Pause if clicked on Surface
				if (UI.core.mouseevents == 1) {
					// JavaScript Mouse Events Demo
					sendjsdata["type"] = "mouseLeftClick";
					fireQmlMessage(JSON.stringify(sendjsdata));
				}
			} else {
				if (fullscreen) {
					Wjs.isbig();
				} else {
					Wjs.gobig();
				}
			}
		}
	}
}
function MouseRelease(clicked) {
	// Start Fix for Missing Clicks
	if (mouseClicked == 1) {
		mouseClicked = 0;
	} else {
		if (toolbarBackground.bottomtab.containsMouse === false) {
			var sendjsdata = {};
	
			if (clicked == Qt.RightButton) {
				// JavaScript Mouse Events Demo
				if (UI.core.mouseevents == 1) {
					sendjsdata["type"] = "mouseRightClick";
					fireQmlMessage(JSON.stringify(sendjsdata));
				}
			} else {
				if (multiscreen == 0) {
					if (vlcPlayer.state != 1) Wjs.isbig(); // Toggle Pause if clicked on Surface
					if (UI.core.mouseevents == 1) {
						// JavaScript Mouse Events Demo
						sendjsdata["type"] = "mouseLeftClick";
						fireQmlMessage(JSON.stringify(sendjsdata));
					}
				} else {
					if (fullscreen) {
						Wjs.isbig();
					} else {
						Wjs.gobig();
					}
				}
			}
		}
	}
	// End Fix for Missing Clicks
}
// END MOUSE ACTIONS