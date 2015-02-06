import QtQuick 2.1
import QmlVlc 0.1

Rectangle {
	property var mouseClicked: 0; // Fix for Missing Clicks
	
	// START HOTKEYS
	function keys(event) {
		if (contextblock.visible === true) contextblock.close();
		if (event.key == Qt.Key_Space) { wjs.togPause(); }
		if (event.key == Qt.Key_Escape) {
			if (fullscreen) {
				fullscreen = false;
				if (multiscreen == 1) if (vlcPlayer.audio.mute === false) vlcPlayer.toggleMute(); // Multiscreen - Mute on Playback Start
			}
		}
		if (event.key == Qt.Key_F || event.key == Qt.Key_F11) {
			wjs.togFullscreen();
		}
		if (event.key == Qt.Key_E) {
			wjs.nextFrame(500);
		}
		if (event.key == Qt.Key_N) {
			vlcPlayer.playlist.next();
		}
		if(event.modifiers == Qt.ControlModifier) {
			if (event.key == Qt.Key_Right) {
				wjs.jumpTo(60000,"forward");
			} else if (event.key == Qt.Key_Left) {
				wjs.jumpTo(60000,"backward");
			} else if (event.key == Qt.Key_Up) {
				wjs.volumeTo(8,"increase");
			} else if (event.key == Qt.Key_Down) {
				wjs.volumeTo(8,"decrease");
			} else if (event.key == Qt.Key_L) {
				wjs.togglePlaylist();
			}
		}
		if(event.modifiers == Qt.AltModifier) {
			if (event.key == Qt.Key_Right) {
				wjs.jumpTo(10000,"forward");
			} else if (event.key == Qt.Key_Left) {
				wjs.jumpTo(10000,"backward");
			}
		}
		if (event.key == Qt.Key_M) {
			wjs.toggleMute();
			if (vlcPlayer.audio.mute) {
				wjs.setText("Muted");
			} else {
				wjs.setText("Volume " + (Math.round((250 * (vlcPlayer.volume /200))/10) *5) + "%");
			}
			wjs.refreshMuteIcon();
		}
		if (event.key == Qt.Key_P) {
			vlcPlayer.time = 0;
		}
		if (event.key == Qt.Key_Plus || event.key == Qt.Key_BracketRight) {
			wjs.rateTo("increase");
		}
		if (event.key == Qt.Key_Minus || event.key == Qt.Key_BracketLeft) {
			wjs.rateTo("decrease");
		}
		if (event.key == Qt.Key_Equal) {
			wjs.rateTo("normal");
		}
		if (event.key == Qt.Key_A) {
			var kl = 0;
			for (kl = 0; typeof ui.core.aspectRatios[kl] !== 'undefined'; kl++) if (ui.core.aspectRatios[kl] == curAspect) {
				if (typeof ui.core.aspectRatios[kl+1] !== 'undefined') {
					curAspect = ui.core.aspectRatios[kl+1];
				} else curAspect = ui.core.aspectRatios[0];
				
				if (curAspect == "Default") {
					wjs.resetAspect();
				} else {
					wjs.changeAspect(curAspect,"ratio");
				}
				
				wjs.setText("Aspect Ratio: " + curAspect);
				break;
			}
		}
		if (event.key == Qt.Key_C) {
			var kl = 0;
			for (kl = 0; typeof ui.core.crops[kl] !== 'undefined'; kl++) if (ui.core.crops[kl] == curCrop) {
				if (typeof ui.core.crops[kl+1] !== 'undefined') {
					curCrop = ui.core.crops[kl+1];
				} else curCrop = ui.core.crops[0];
				if (curCrop == "Default") {
					wjs.resetAspect();
				} else {
					wjs.changeAspect(curCrop,"crop");
				}
				
				wjs.setText("Crop: " + curCrop);
				break;
			}
		}
		if (event.key == Qt.Key_Z) {
			var kl = 0;
			for (kl = 0; typeof ui.core.zooms[kl] !== 'undefined'; kl++) if (curZoom == kl) {
				if (typeof ui.core.zooms[kl+1] !== 'undefined') {
					curZoom = kl +1;
				} else curZoom = 0;
				
				wjs.changeZoom(ui.core.zooms[curZoom][0]);
				
				wjs.setText("Zoom Mode: " + ui.core.zooms[curZoom][1]);
				break;
			}
		}
		if (event.key == Qt.Key_T) {
			wjs.setText(showtime.text.trim());
		}
		if(event.modifiers == Qt.AltModifier) {
			if (event.key == Qt.Key_Right) {
				wjs.jumpTo(10000,"forward");
			} else if (event.key == Qt.Key_Left) {
				wjs.jumpTo(10000,"backward");
			}
		}
		if(event.modifiers == Qt.ShiftModifier) {
			if (event.key == Qt.Key_Right) {
				wjs.jumpTo(3000,"forward");
			} else if (event.key == Qt.Key_Left) {
				wjs.jumpTo(3000,"backward");
			}
		}
	}
	// END HOTKEYS
	
	
	// MOUSE ACTIONS
	function mouseScroll(mouseX,mouseY) {
		// Change Volume on Mouse Scroll
		if (mouseY > 0) wjs.volumeTo(8,"increase");
		if (mouseY < 0) wjs.volumeTo(8,"decrease");
		// End Change Volume on Mouse Scroll
	}
	function mouseMoved(mouseX,mouseY) {
		ismoving = 1;  // Reset Idle Mouse Movement if mouse position has changed
		
		if (ui.core.mouseevents == 1) {
			// JavaScript Mouse Events Demo
			var sendjsdata = {};
			sendjsdata["type"] = "mouseMove";
			sendjsdata["x"] = mouseX;
			sendjsdata["y"] = mouseY;
			
			fireQmlMessage(JSON.stringify(sendjsdata));
		}
	
		cursorX = mouseX;
		cursorY = mouseY;
	}
	function mouseDblClick(clicked) {
		if (multiscreen == 0) {
			if (ui.core.mouseevents == 1) {
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
						
				if (vlcPlayer.state == 4) wjs.togPause();
					
				gobigpause = false;
				gobigplay = false;
				pausetog.visible = false;
				playtog.visible = false;
				if (!fullscreen) mouseClicked = 1; // Fix for Missing Clicks
				wjs.togFullscreen();
				mousesurface.focus = true;
			}
		}
		if (multiscreen == 1) MouseClicked(clicked); // Multiscreen does not support Fullscreen Toggle on Double Click
	}
	function mouseClick(clicked) {
		mouseClicked = 1; // Fix for Missing Clicks
		if (toolbarBackground.bottomtab.containsMouse === false) {
			var sendjsdata = {};
	
			if (clicked == Qt.RightButton) {
				// JavaScript Mouse Events Demo
				if (ui.core.mouseevents == 1) {
					sendjsdata["type"] = "mouseRightClick";
					fireQmlMessage(JSON.stringify(sendjsdata));
				}
				if (cursorX == 0 && cursorY == 0) { } else {
					if (multiscreen == 1 && fullscreen === false) { } else {
						contextblock.open();
						contextblock.addContextItems();
					}
				}
			} else {
				if (contextblock.visible === true) {
					contextblock.close();
				} else {
					if (multiscreen == 0) {
						if (vlcPlayer.state != 1) wjs.isbig(); // Toggle Pause if clicked on Surface
						if (ui.core.mouseevents == 1) {
							// JavaScript Mouse Events Demo
							sendjsdata["type"] = "mouseLeftClick";
							fireQmlMessage(JSON.stringify(sendjsdata));
						}
					} else {
						if (fullscreen) {
							wjs.isbig();
						} else {
							wjs.gobig();
						}
					}
				}
			}
		}
	}
	function mouseRelease(clicked) {
		// Start Fix for Missing Clicks
		if (mouseClicked == 1) {
			mouseClicked = 0;
		} else {
			if (toolbarBackground.bottomtab.containsMouse === false) {
				var sendjsdata = {};
		
				if (clicked == Qt.RightButton) {
					// JavaScript Mouse Events Demo
					if (ui.core.mouseevents == 1) {
						sendjsdata["type"] = "mouseRightClick";
						fireQmlMessage(JSON.stringify(sendjsdata));
					}
					contextblock.addContextItems();
					contextblock.toggle();
				} else {
					if (multiscreen == 0) {
						if (vlcPlayer.state != 1) wjs.isbig(); // Toggle Pause if clicked on Surface
						if (ui.core.mouseevents == 1) {
							// JavaScript Mouse Events Demo
							sendjsdata["type"] = "mouseLeftClick";
							fireQmlMessage(JSON.stringify(sendjsdata));
						}
					} else {
						if (fullscreen) {
							wjs.isbig();
						} else {
							wjs.gobig();
						}
					}
				}
			}
		}
		// End Fix for Missing Clicks
	}
	// END MOUSE ACTIONS
}