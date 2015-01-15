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

import QtQuick 2.1
import QmlVlc 0.1
import "../../core/functions.js" as Wjs
import "../../core/hotkeys.js" as Hotkeys
import "ui-settings.js" as UI
import "components" as Loader

Rectangle {
	// We strongly recommend that you do not remove or change any of the global variables
	property var gobigplay: false;
	property var gobigpause: false;
	property var dragging: false;
	property var ismoving: 1;
	property var buffering: 0;
	property var autoloop: 0;
	property var automute: 0;
	property var allowfullscreen: 1;
	property var playlistmenu: false;
	property var title: "";
    property var multiscreen: 0;
	property var timervolume: 0;
	property var glyphsLoaded: false;
	property var firsttime: 1;
	property var caching: 0;
	property var lastTime: 0;
	property var buttonNormalColor: UI.colors.toolbar.button;
	property var buttonHoverColor: UI.colors.toolbar.buttonHover;
	
    id: theview;
    color: UI.colors.videoBackground; // Set Video Background Color
	
	Loader.Fonts {
		id: fonts
		icons.source: UI.settings.iconFont
		defaultFont.source: UI.settings.defaultFont
		secondaryFont.source: UI.settings.secondaryFont
	}
	
	Loader.ArtworkLayer { id: artwork } // Load Artwork Layer (if set with .addPlaylist)

	Loader.VideoLayer { id: videoSource } // Load Video Layer

	// Start Subtitle Text Box
	Loader.SubtitleText {
		id: subtitlebox
		fontColor: UI.colors.font
		fontShadow: UI.colors.fontShadow
	}
	// End Start Subtitle Text Box

	// Start Top Center Text Box (Opening, Buffering, etc.)
	Loader.TopCenterText {
		id: buftext
		fontColor: UI.colors.font
		fontShadow: UI.colors.fontShadow
	}
	// End Top Center Text Box

	// Start Top Right Text Box
	Loader.TopRightText {
		id: volumebox
		fontColor: UI.colors.font
		fontShadow: UI.colors.fontShadow
	}
	// End Top Right Text Box
		
	// Start Loading Screen
	Loader.SplashScreen {
		id: splashScreen
		color: UI.colors.videoBackground
		fontColor: UI.colors.font
		fontShadow: UI.colors.fontShadow
		onLogoEffect: Wjs.fadeLogo()
	}
	// End Loading Screen
		
	// Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) includes Toolbar
	Loader.MouseSurface {
		id: mousesurface
		onWidthChanged: Wjs.onSizeChanged();
		onHeightChanged: Wjs.onSizeChanged();
		onPressed: Hotkeys.MouseClick(mouse.button);
		onReleased: Hotkeys.MouseRelease(mouse.button);
		onDoubleClicked: Hotkeys.MouseDblClick(mouse.button);
		onPositionChanged: Hotkeys.MouseMoved(mouse.x,mouse.y);
		onWheel: Hotkeys.MouseScroll(wheel.angleDelta.x,wheel.angleDelta.y);
		Keys.onPressed: Hotkeys.Keys(event);		
		
		// Title Bar (top bar)
		Loader.TitleBar {
			id: topText
			fontColor: UI.colors.titleBar.font
			backgroundColor: UI.colors.titleBar.background
			isVisible: (vlcPlayer.state == 3 || vlcPlayer.state == 4 || vlcPlayer.state == 6) ? UI.settings.titleBar == "fullscreen" ? fullscreen ? true : false : UI.settings.titleBar == "minimized" ? fullscreen === false ? true : false : UI.settings.titleBar == "both" ? true : UI.settings.titleBar == "none" ? false : false : false
		}
		// End Title Bar (top bar)
						
		// Draw Toolbar
		Loader.Toolbar {
			id: toolbar
			height: fullscreen ? 32 : 30

			Loader.ToolbarBackground {
				id: toolbarBackground
				color: UI.colors.background
				opacity: 0.9
			}

			// Start Left Side Buttons in Toolbar
			Loader.ToolbarLeft {
	
				// Start Playlist Previous Button
				Loader.ToolbarButton {
					id: prevBut
					width: UI.settings.toolbar.buttonWidth
					icon: glyphsLoaded ? UI.icon.prev : ""
					iconSize: fullscreen ? 8 : 7
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: UI.settings.buttonGlow
					onButtonClicked: vlcPlayer.playlist.prev();
				}
				Loader.ToolbarBorder {
					color: UI.colors.toolbar.border
					visible: UI.settings.toolbar.borderVisible ? prevBut.visible : false
				}
				// End Playlist Previous Button
	
				// Start Play/Pause Button
				Loader.ToolbarButton {
					id: playButton
					width: UI.settings.toolbar.buttonWidth
					icon: glyphsLoaded ? vlcPlayer.playing ? UI.icon.pause : vlcPlayer.state != 6 ? UI.icon.play : UI.icon.replay : ""
					iconSize: fullscreen ? 14 : 13
					glow: UI.settings.buttonGlow
					onButtonClicked: Wjs.togPause();
				}
				Loader.ToolbarBorder {
					color: UI.colors.toolbar.border
					visible: UI.settings.toolbar.borderVisible
				}
				// End Play/Pause Button
	
				// Start Playlist Next Button
				Loader.ToolbarButton {
					id: nextBut
					width: UI.settings.toolbar.buttonWidth
					icon: glyphsLoaded ? UI.icon.next : ""
					iconSize: fullscreen ? 8 : 7
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: UI.settings.buttonGlow
					onButtonClicked: vlcPlayer.playlist.next();
				}
				Loader.ToolbarBorder {
					visible: UI.settings.toolbar.borderVisible ? nextBut.visible : false
					color: UI.colors.toolbar.border
				}
				// End Playlist Next Button
				
				// Start Mute Button
				Loader.ToolbarButton {
					id: mutebut
					icon: glyphsLoaded ? vlcPlayer.audio.mute ? UI.icon.mute : vlcPlayer.volume == 0 ? UI.icon.mute : vlcPlayer.volume <= 30 ? UI.icon.volume.low : vlcPlayer.volume > 30 && vlcPlayer.volume <= 134 ? UI.icon.volume.medium : UI.icon.volume.high : ""
					iconSize: fullscreen ? 17 : 16
					width: UI.settings.toolbar.buttonMuteWidth
					glow: UI.settings.buttonGlow
					onButtonClicked: Wjs.toggleMute();
					onButtonEntered: Wjs.refreshMuteIcon();
					onButtonExited: Wjs.refreshMuteIcon();
				}
				// End Mute Button
				
				// Start Volume Control
				Loader.VolumeHeat {
					
					Loader.VolumeHeatMouse {
						id: volumeMouse
						onPressAndHold: Wjs.hoverVolume(mouseX,mouseY)
						onPositionChanged: Wjs.clickVolume(mouseX,mouseY)
						onReleased: Wjs.clickVolume(mouseX,mouseY)
					}
					Loader.VolumeHeatGraphics {
						id: volheat
						backgroundColor: UI.colors.volumeHeat.background
						volLow: UI.colors.volumeHeat.color.low
						volMed: UI.colors.volumeHeat.color.medium
						volHigh: UI.colors.volumeHeat.color.high
					}
	
				}
				// End Volume Control

				Loader.ToolbarBorder {
					anchors.left: mutebut.right
					anchors.leftMargin: mutebut.hover.containsMouse ? 130 : volumeMouse.dragger.containsMouse ? 130 : 0
					color: UI.colors.toolbar.border
					visible: UI.settings.toolbar.borderVisible
					Behavior on anchors.leftMargin { PropertyAnimation { duration: 250 } }
				}
	
				// Start "Time / Length" Text in Toolbar
				Loader.ToolbarTimeLength {
					id: showtime
					text: "   "+ Wjs.getTime(vlcPlayer.time) +" / "+ Wjs.getLengthTime()
					color: UI.colors.toolbar.timeLength
				}
				// End "Time / Length" Text in Toolbar
			}
			// End Left Side Buttons in Toolbar
			
			// Start Right Side Buttons in Toolbar
			Loader.ToolbarRight {
				// Start Open Playlist Button
				Loader.ToolbarBorder {
					color: UI.colors.toolbar.border
					visible: UI.settings.toolbar.borderVisible ? playlistButton.visible : false
				}
				Loader.ToolbarButton {
					id: playlistButton
					width: UI.settings.toolbar.buttonWidth
					icon: glyphsLoaded ? UI.icon.playlist : ""
					iconSize: fullscreen ? 18 : 17
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: UI.settings.buttonGlow
					onButtonClicked: Wjs.togglePlaylist();
				}
				// End Open Playlist Button
				
				// Fullscreen Button
				Loader.ToolbarBorder {
					color: UI.colors.toolbar.border
					visible: UI.settings.toolbar.borderVisible
				}
				Loader.ToolbarButton {
					id: fullscreenButton
					width: UI.settings.toolbar.buttonWidth
					icon: glyphsLoaded ? fullscreen ? UI.icon.minimize : UI.icon.maximize : ""
					iconSize: fullscreen ? 18 : 17
					iconElem.color: allowfullscreen == 1 ? hover.containsMouse ? buttonHoverColor : buttonNormalColor : buttonHoverColor
					hover.cursorShape: allowfullscreen == 1 ? toolbar.opacity == 1 ? Qt.PointingHandCursor : mousesurface.cursorShape : Qt.ForbiddenCursor
					opacity: allowfullscreen == 1 ? 1 : 0.2
					color: allowfullscreen == 1 ? "transparent" : "#000000"
					glow: UI.settings.buttonGlow
					onButtonClicked: {
						if (allowfullscreen == 1) {
							Wjs.togFullscreen();
							if (multiscreen == 1) Wjs.toggleMute(); // Multiscreen - Edit
						}
					}
				}
				// End Fullscreen Button
			}
			// End Right Side Buttons in Toolbar
		}
		// End Draw Toolbar

		// Draw Progression Bar
        Loader.ProgressBar {
			id: progressBar
			backgroundColor: UI.colors.progress.background
			viewedColor: UI.colors.progress.viewed
			positionColor: UI.colors.progress.position
			cacheVisible: UI.settings.cache
			cacheColor: UI.colors.progress.cache
			onPressed: Wjs.progressDrag(mouseX,mouseY);
			onChanged: Wjs.progressChanged(mouseX,mouseY);
			onReleased: Wjs.progressReleased(mouseX,mouseY);
		}
		// End Draw Progress Bar

		// Draw Play Icon (appears in center of screen when Toggle Pause)
		Loader.BigPlayIcon {
			id: playtog
			color: UI.colors.bigIconBackground
			icon: UI.icon.bigPlay
			iconColor: UI.colors.bigIcon
		}
		// End Draw Play Icon (appears in center of screen when Toggle Pause)
		
		// Draw Pause Icon (appears in center of screen when Toggle Pause)
		Loader.BigPauseIcon {
			id: pausetog
			color: UI.colors.bigIconBackground
			icon: UI.icon.bigPause
			iconColor: UI.colors.bigIcon
		}
		// End Draw Pause Icon (appears in center of screen when Toggle Pause)
		
		// Draw Time Bubble (visible when hovering over Progress Bar)
		Loader.TimeBubble {
			id: timeBubble
			fontColor: UI.colors.timeBubble.font
			backgroundIcon: glyphsLoaded ? timeBubble.srctime.length > 5 ? UI.icon.timeBubble.big : timeBubble.srctime.length == 0 ? "" : UI.icon.timeBubble.small : ""
			backgroundColor: UI.colors.timeBubble.background
			backgroundBorder: UI.colors.timeBubble.border
			backgroundOpacity: 0.9
		}
		// End Time Bubble

		// Start Playlist Menu
		Loader.Menu {
			id: playlistblock
			background.color: UI.colors.playlistMenu.background
			
			// Start Playlist Menu Scroll
			Loader.PlaylistMenuScroll {
				id: playlistScroll
				draggerColor: UI.colors.playlistMenu.drag
				backgroundColor: UI.colors.playlistMenu.scroller
				onDrag: Wjs.movePlaylist(mouseY)
			}
			// End Playlist Menu Scroll
		
			Loader.PlaylistMenuContent {
				
				Loader.PlaylistMenuItems { id: playlist } // Playlist Items Holder (This is where the Playlist Items will be loaded)
		
				// Top Holder (Title + Close Button)
				Loader.PlaylistMenuHeader {
					text: "Title"
					textColor: UI.colors.playlistMenu.headerFont
					backgroundColor: UI.colors.playlistMenu.header
										
					// Start Close Playlist Button
					Loader.PlaylistMenuClose {
						id: playlistClose
						icon: glyphsLoaded ? UI.icon.closePlaylist : ""
						iconSize: 9
						iconColor: playlistClose.hover.containsMouse ? UI.colors.playlistMenu.closeHover : UI.colors.playlistMenu.close
						color: playlistClose.hover.containsMouse ? UI.colors.playlistMenu.closeBackgroundHover : UI.colors.playlistMenu.closeBackground
					}
					// End Close Playlist Button
				}
				// End Top Holder (Title + Close Button)
				
			}
		}
		// End Playlist Menu
		
    }
	// End Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) [includes Toolbar]
	
	Component.onCompleted: Wjs.onQmlLoaded()
}
