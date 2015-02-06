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
import "./" as LoadSettings
import "../../core" as JsLogic
import "components" as Loader

Rectangle {

	// load core javascript functions and settings
	LoadSettings.UIsettings { id: ui }
	JsLogic.Settings { id: settings }
	JsLogic.Functions { id: wjs }
	JsLogic.Hotkeys { id: hotkeys }
	// end load core javascript functions and settings
	
    id: theview;
    color: ui.colors.videoBackground; // Set Video Background Color
	
	Loader.Fonts {
		id: fonts
		icons.source: ui.settings.iconFont
		defaultFont.source: ui.settings.defaultFont
		secondaryFont.source: ui.settings.secondaryFont
	}
	
	Loader.ArtworkLayer { id: artwork } // Load Artwork Layer (if set with .addPlaylist)

	Loader.VideoLayer { id: videoSource } // Load Video Layer

	// Start Subtitle Text Box
	Loader.SubtitleText {
		id: subtitlebox
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
	}
	// End Start Subtitle Text Box

	// Start Top Center Text Box (Opening, Buffering, etc.)
	Loader.TopCenterText {
		id: buftext
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
	}
	// End Top Center Text Box
	
	// Start Top Right Text Box
	Loader.TopRightText {
		id: volumebox
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
	}
	// End Top Right Text Box
		
	// Draw Play Icon (appears in center of screen when Toggle Pause)
	Loader.BigPlayIcon {
		id: playtog
		color: ui.colors.bigIconBackground
		icon: ui.icon.bigPlay
		iconColor: ui.colors.bigIcon
	}
	// End Draw Play Icon (appears in center of screen when Toggle Pause)
	
	// Draw Pause Icon (appears in center of screen when Toggle Pause)
	Loader.BigPauseIcon {
		id: pausetog
		color: ui.colors.bigIconBackground
		icon: ui.icon.bigPause
		iconColor: ui.colors.bigIcon
	}
	// End Draw Pause Icon (appears in center of screen when Toggle Pause)
		
	// Start Loading Screen
	Loader.SplashScreen {
		id: splashScreen
		color: ui.colors.videoBackground
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
		onLogoEffect: wjs.fadeLogo()
	}
	// End Loading Screen
			
	// Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) includes Toolbar
	Loader.MouseSurface {
		id: mousesurface
		onWidthChanged: wjs.onSizeChanged();
		onHeightChanged: wjs.onSizeChanged();
		onPressed: hotkeys.mouseClick(mouse.button);
		onReleased: hotkeys.mouseRelease(mouse.button);
		onDoubleClicked: hotkeys.mouseDblClick(mouse.button);
		onPositionChanged: hotkeys.mouseMoved(mouse.x,mouse.y);
		onWheel: hotkeys.mouseScroll(wheel.angleDelta.x,wheel.angleDelta.y);
		Keys.onPressed: hotkeys.keys(event);		
		
		// Title Bar (top bar)
		Loader.TitleBar {
			id: topText
			fontColor: ui.colors.titleBar.font
			backgroundColor: ui.colors.titleBar.background
			isVisible: (vlcPlayer.state == 3 || vlcPlayer.state == 4 || vlcPlayer.state == 6) ? ui.settings.titleBar == "fullscreen" ? fullscreen ? true : false : ui.settings.titleBar == "minimized" ? fullscreen === false ? true : false : ui.settings.titleBar == "both" ? true : ui.settings.titleBar == "none" ? false : false : false
		}
		// End Title Bar (top bar)
						
		// Draw Toolbar
		Loader.Toolbar {
			id: toolbar
			height: fullscreen ? 32 : 30

			Loader.ToolbarBackground {
				id: toolbarBackground
				color: ui.colors.background
				opacity: 0.9
			}

			// Start Left Side Buttons in Toolbar
			Loader.ToolbarLeft {
	
				// Start Playlist Previous Button
				Loader.ToolbarButton {
					id: prevBut
					width: ui.settings.toolbar.buttonWidth
					icon: settings.glyphsLoaded ? ui.icon.prev : ""
					iconSize: fullscreen ? 8 : 7
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (contextblock.visible === true) contextblock.close();
						vlcPlayer.playlist.prev();
					}
				}
				Loader.ToolbarBorder {
					color: ui.colors.toolbar.border
					visible: ui.settings.toolbar.borderVisible ? prevBut.visible : false
				}
				// End Playlist Previous Button
	
				// Start Play/Pause Button
				Loader.ToolbarButton {
					id: playButton
					width: ui.settings.toolbar.buttonWidth
					icon: settings.glyphsLoaded ? vlcPlayer.playing ? ui.icon.pause : vlcPlayer.state != 6 ? ui.icon.play : ui.icon.replay : ""
					iconSize: fullscreen ? 14 : 13
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (contextblock.visible === true) contextblock.close();
						wjs.togPause();
					}
				}
				Loader.ToolbarBorder {
					color: ui.colors.toolbar.border
					visible: ui.settings.toolbar.borderVisible
				}
				// End Play/Pause Button
	
				// Start Playlist Next Button
				Loader.ToolbarButton {
					id: nextBut
					width: ui.settings.toolbar.buttonWidth
					icon: settings.glyphsLoaded ? ui.icon.next : ""
					iconSize: fullscreen ? 8 : 7
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (contextblock.visible === true) contextblock.close();
						vlcPlayer.playlist.next();
					}
				}
				Loader.ToolbarBorder {
					visible: ui.settings.toolbar.borderVisible ? nextBut.visible : false
					color: ui.colors.toolbar.border
				}
				// End Playlist Next Button
				
				// Start Mute Button
				Loader.ToolbarButton {
					id: mutebut
					icon: settings.glyphsLoaded ? vlcPlayer.state == 0 ? ui.icon.volume.medium : vlcPlayer.position == 0 && vlcPlayer.playlist.currentItem == 0 ? settings.automute == 0 ? ui.icon.volume.medium : ui.icon.mute : vlcPlayer.audio.mute ? ui.icon.mute : vlcPlayer.volume == 0 ? ui.icon.mute : vlcPlayer.volume <= 30 ? ui.icon.volume.low : vlcPlayer.volume > 30 && vlcPlayer.volume <= 134 ? ui.icon.volume.medium : ui.icon.volume.high : ""
					iconSize: fullscreen ? 17 : 16
					width: ui.settings.toolbar.buttonMuteWidth
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (contextblock.visible === true) contextblock.close();
						wjs.toggleMute();
					}
					onButtonEntered: wjs.refreshMuteIcon();
					onButtonExited: wjs.refreshMuteIcon();
				}
				// End Mute Button
				
				// Start Volume Control
				Loader.VolumeHeat {
									
					Loader.VolumeHeatMouse {
						id: volumeMouse
						onPressAndHold: wjs.hoverVolume(mouseX,mouseY)
						onPositionChanged: wjs.clickVolume(mouseX,mouseY)
						onReleased: wjs.clickVolume(mouseX,mouseY)
					}
					Loader.VolumeHeatGraphics {
						id: volheat
						backgroundColor: ui.colors.volumeHeat.background
						volColor: ui.colors.volumeHeat.color
					}
	
				}
				// End Volume Control

				Loader.ToolbarBorder {
					id: volumeBorder
					anchors.left: mutebut.right
					anchors.leftMargin: settings.firstvolume == 1 ? 0 : mutebut.hover.containsMouse ? 130 : volumeMouse.dragger.containsMouse ? 130 : 0
					color: ui.colors.toolbar.border
					visible: ui.settings.toolbar.borderVisible
					Behavior on anchors.leftMargin { PropertyAnimation { duration: 250 } }
				}
	
				// Start "Time / Length" Text in Toolbar
				Loader.ToolbarTimeLength {
					id: showtime
					text: "   "+ wjs.getTime(vlcPlayer.time) +" / "+ wjs.getLengthTime()
					color: ui.colors.toolbar.timeLength
				}
				// End "Time / Length" Text in Toolbar
			}
			// End Left Side Buttons in Toolbar
			
			// Start Right Side Buttons in Toolbar
			Loader.ToolbarRight {
				// Start Open Subtitle Menu Button
				Loader.ToolbarBorder {
					color: ui.colors.toolbar.border
					visible: ui.settings.toolbar.borderVisible ? subButton.visible : false
				}
				Loader.ToolbarButton {
					id: subButton
					width: ui.settings.toolbar.buttonWidth
					icon: settings.glyphsLoaded ? ui.icon.subtitles : ""
					iconSize: fullscreen ? 17 : 16
					visible: false
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (contextblock.visible === true) contextblock.close();
						subMenu.toggleSubtitles();
					}
				}
				// End Open Subtitle Menu Button
				
				// Start Open Playlist Button
				Loader.ToolbarBorder {
					color: ui.colors.toolbar.border
					visible: ui.settings.toolbar.borderVisible ? playlistButton.visible : false
				}
				Loader.ToolbarButton {
					id: playlistButton
					width: ui.settings.toolbar.buttonWidth
					icon: settings.glyphsLoaded ? ui.icon.playlist : ""
					iconSize: fullscreen ? 18 : 17
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (contextblock.visible === true) contextblock.close();
						wjs.togglePlaylist();
					}
				}
				// End Open Playlist Button
				
				// Fullscreen Button
				Loader.ToolbarBorder {
					color: ui.colors.toolbar.border
					visible: ui.settings.toolbar.borderVisible
				}
				Loader.ToolbarButton {
					id: fullscreenButton
					width: ui.settings.toolbar.buttonWidth
					icon: settings.glyphsLoaded ? fullscreen ? ui.icon.minimize : ui.icon.maximize : ""
					iconSize: fullscreen ? 18 : 17
					iconElem.color: settings.allowfullscreen == 1 ? hover.containsMouse ? ui.colors.toolbar.buttonHover : ui.colors.toolbar.button : ui.colors.toolbar.buttonHover
					hover.cursorShape: settings.allowfullscreen == 1 ? toolbar.opacity == 1 ? Qt.PointingHandCursor : mousesurface.cursorShape : Qt.ForbiddenCursor
					opacity: settings.allowfullscreen == 1 ? 1 : 0.2
					color: settings.allowfullscreen == 1 ? "transparent" : "#000000"
					glow: ui.settings.buttonGlow
					onButtonClicked: {
						if (settings.allowfullscreen == 1) {
							if (contextblock.visible === true) contextblock.close();
							wjs.togFullscreen();
							if (settings.multiscreen == 1) wjs.toggleMute(); // Multiscreen - Edit
						}
					}
				}
				// End Fullscreen Button
			}
			// End Right Side Buttons in Toolbar
		}
		// End Draw Toolbar
		
		// Draw Time Bubble (visible when hovering over Progress Bar)
		Loader.TimeBubble {
			id: timeBubble
			fontColor: ui.colors.timeBubble.font
			backgroundIcon: settings.glyphsLoaded ? timeBubble.srctime.length > 5 ? ui.icon.timeBubble.big : timeBubble.srctime.length == 0 ? "" : ui.icon.timeBubble.small : ""
			backgroundColor: ui.colors.timeBubble.background
			backgroundBorder: ui.colors.timeBubble.border
			backgroundOpacity: 0.9
		}
		// End Time Bubble

		// Draw Progression Bar
        Loader.ProgressBar {
			id: progressBar
			backgroundColor: ui.colors.progress.background
			viewedColor: ui.colors.progress.viewed
			positionColor: ui.colors.progress.position
			cache.visible: vlcPlayer.state > 0 ? ui.settings.caching : false // fix for non-notify issue
			cache.color: ui.colors.progress.cache
			onPressed: wjs.progressDrag(mouseX,mouseY);
			onChanged: wjs.progressChanged(mouseX,mouseY);
			onReleased: wjs.progressReleased(mouseX,mouseY);
		}
		// End Draw Progress Bar
		

		// Start Playlist Menu
		Loader.Menu {
			id: playlistblock
			background.color: ui.colors.playlistMenu.background
			
			// Start Playlist Menu Scroll
			Loader.MenuScroll {
				id: playlistScroll
				draggerColor: ui.colors.playlistMenu.drag
				backgroundColor: ui.colors.playlistMenu.scroller
				onDrag: wjs.movePlaylist(mouseY)
				dragger.height: (vlcPlayer.playlist.itemCount * 40) < 240 ? 240 : (240 / (vlcPlayer.playlist.itemCount * 40)) * 240
			}
			// End Playlist Menu Scroll
		
			Loader.MenuContent {
				width: playlistblock.width < 694 ? (playlistblock.width -12) : 682
				
				Loader.PlaylistMenuItems { id: playlist } // Playlist Items Holder (This is where the Playlist Items will be loaded)
		
				// Top Holder (Title + Close Button)
				Loader.MenuHeader {
					text: "Title"
					textColor: ui.colors.playlistMenu.headerFont
					backgroundColor: ui.colors.playlistMenu.header
										
					// Start Close Playlist Button
					Loader.MenuClose {
						id: playlistClose
						icon: settings.glyphsLoaded ? ui.icon.closePlaylist : ""
						iconSize: 9
						iconColor: playlistClose.hover.containsMouse ? ui.colors.playlistMenu.closeHover : ui.colors.playlistMenu.close
						color: playlistClose.hover.containsMouse ? ui.colors.playlistMenu.closeBackgroundHover : ui.colors.playlistMenu.closeBackground
						hover.onClicked: {
							playlistblock.visible = false;
							settings.playlistmenu = false
						}
					}
					// End Close Playlist Button
				}
				// End Top Holder (Title + Close Button)
				
			}
		}
		// End Playlist Menu

		// Start Subtitle Menu
		Loader.Menu {
			id: subMenublock
			background.color: ui.colors.playlistMenu.background
			
			// Start Subtitle Menu Scroll
			Loader.MenuScroll {
				id: subMenuScroll
				draggerColor: ui.colors.playlistMenu.drag
				backgroundColor: ui.colors.playlistMenu.scroller
				onDrag: wjs.moveSubMenu(mouseY)
				dragger.height: (settings.totalSubs * 40) < 240 ? 240 : (240 / (settings.totalSubs * 40)) * 240
			}
			// End Subtitle Menu Scroll
		
			Loader.MenuContent {
				width: subMenublock.width < 694 ? (subMenublock.width -12) : 682
				
				Loader.SubtitleMenuItems { id: subMenu } // Subtitle Items Holder (This is where the Playlist Items will be loaded)
		
				// Top Holder (Title + Close Button)
				Loader.MenuHeader {
					text: "Language"
					textColor: ui.colors.playlistMenu.headerFont
					backgroundColor: ui.colors.playlistMenu.header
										
					// Start Close Subtitle Menu Button
					Loader.MenuClose {
						id: subMenuClose
						icon: settings.glyphsLoaded ? ui.icon.closePlaylist : ""
						iconSize: 9
						iconColor: subMenuClose.hover.containsMouse ? ui.colors.playlistMenu.closeHover : ui.colors.playlistMenu.close
						color: subMenuClose.hover.containsMouse ? ui.colors.playlistMenu.closeBackgroundHover : ui.colors.playlistMenu.closeBackground
						hover.onClicked: {
							subMenublock.visible = false;
							settings.subtitlemenu = false;
						}
					}
					// End Close Subtitle Menu Button
				}
				// End Top Holder (Title + Close Button)
				
			}
		}
		// End Subtitle Menu
		
		// Start Context Menu
		Loader.ContextMenu {
			id: contextblock
			color: ui.colors.playlistMenu.background
			border.color: "#979595"
		}
		// End Context Menu
		
    }
	// End Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) [includes Toolbar]
	
	Component.onCompleted: wjs.onQmlLoaded()
}
