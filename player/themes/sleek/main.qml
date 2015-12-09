/*****************************************************************************
* Copyright (c) 2014-2015 Branza Victor-Alexandru <branza.alex[at]gmail.com>
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
import "./" as Local

Rectangle {

	// load core javascript functions and settings
	property variant ui: {}
	Local.UIsettings { id: skinData }
	property var borderVisible: skinData.variables.settings.toolbar.borderVisible;
	property var buttonWidth: skinData.variables.settings.toolbar.buttonWidth;
	property var timeMargin: skinData.variables.settings.toolbar.timeMargin;
	Local.Settings { id: settings }
	Local.Functions { id: wjs }
	Local.Hotkeys { id: hotkeys }
	Local.Buttons { id: buttons }
	// end load core javascript functions and settings
	
    id: theview;
    color: ui.colors.videoBackground; // Set Video Background Color
	
	Local.Fonts {
		id: fonts
		icons.source: ui.settings.iconFont
		defaultFont.source: ui.settings.defaultFont
		secondaryFont.source: ui.settings.secondaryFont
	}
	
	Local.ArtworkLayer { id: artwork } // Load Artwork Layer (if set with .addPlaylist)

	Local.VideoLayer { id: videoSource } // Load Video Layer

	// Start Subtitle Text Box
	Local.SubtitleText {
		id: subtitlebox
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
	}
	// End Start Subtitle Text Box

	// Start Top Center Text Box (Opening, Buffering, etc.)
	Local.TopCenterText {
		id: buftext
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
	}
	// End Top Center Text Box
			
	// Draw Play Icon (appears in center of screen when Toggle Pause)
	Local.BigPlayIcon {
		id: playtog
		color: ui.colors.bigIconBackground
		icon: ui.icon.bigPlay
		iconColor: ui.colors.bigIcon
	}
	// End Draw Play Icon (appears in center of screen when Toggle Pause)
	
	// Draw Pause Icon (appears in center of screen when Toggle Pause)
	Local.BigPauseIcon {
		id: pausetog
		color: ui.colors.bigIconBackground
		icon: ui.icon.bigPause
		iconColor: ui.colors.bigIcon
	}
	// End Draw Pause Icon (appears in center of screen when Toggle Pause)
		
	// Start Loading Screen
	Local.SplashScreen {
		id: splashScreen
		color: ui.colors.videoBackground
		fontColor: ui.colors.font
		fontShadow: ui.colors.fontShadow
		onLogoEffect: wjs.fadeLogo()
	}
	// End Loading Screen
	
	// Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) includes Toolbar
	Local.MouseSurface {
		id: mousesurface
		onWidthChanged: wjs.onSizeChanged();
		onHeightChanged: wjs.onSizeChanged();
		onPressed: hotkeys.mouseClick(mouse.button);
		onReleased: hotkeys.mouseRelease(mouse.button);
		onDoubleClicked: hotkeys.mouseDblClick(mouse.button);
		onPositionChanged: hotkeys.mouseMoved(mouse.x,mouse.y);
		onWheel: hotkeys.mouseScroll(wheel.angleDelta.x,wheel.angleDelta.y);
		Keys.onPressed: hotkeys.keys(event);		
						
		// Draw Toolbar
		Local.Toolbar {
			id: toolbar
			height: fullscreen ? 32 : 30

			Local.ToolbarBackground {
				id: toolbarBackground
				color: ui.colors.background
				opacity: ui.settings.toolbar.opacity
			}

			// Start Left Side Buttons in Toolbar
			Local.ToolbarLeft {
	
				// Start Playlist Previous Button
				Local.ToolbarButton {
					id: prevBut
					icon: settings.glyphsLoaded ? ui.icon.prev : ""
					iconSize: fullscreen ? 8 : 7
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("prev");
				}
				Local.ToolbarBorder {
					color: ui.colors.toolbar.border
					anchors.left: prevBut.right
					visible: prevBut.visible ? borderVisible : false
				}
				// End Playlist Previous Button
	
				// Start Play/Pause Button
				Local.ToolbarButton {
					id: playButton
					icon: settings.glyphsLoaded ? vlcPlayer.playing ? ui.icon.pause : vlcPlayer.state != 6 ? ui.icon.play : ui.icon.replay : ""
					iconSize: fullscreen ? 14 : 13
					anchors.left: prevBut.visible ? prevBut.right : parent.left
					anchors.leftMargin: prevBut.visible ? 1 : 0
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("play");
				}
				Local.ToolbarBorder {
					color: ui.colors.toolbar.border
					anchors.left: playButton.right
					visible: borderVisible
				}
				// End Play/Pause Button
	
				// Start Playlist Next Button
				Local.ToolbarButton {
					id: nextBut
					icon: settings.glyphsLoaded ? ui.icon.next : ""
					iconSize: fullscreen ? 8 : 7
					anchors.left: playButton.right
					anchors.leftMargin: 1
					visible: vlcPlayer.playlist.itemCount > 1 ? true : false
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("next");
				}
				Local.ToolbarBorder {
					visible: nextBut.visible ? borderVisible : false
					anchors.left: nextBut.right
					color: ui.colors.toolbar.border
				}
				// End Playlist Next Button
				
				// Start Mute Button
				Local.ToolbarButton {
					id: mutebut
					anchors.left: nextBut.visible ? nextBut.right : playButton.right
					anchors.leftMargin: 1
					icon: settings.glyphsLoaded ? vlcPlayer.state == 0 ? ui.icon.volume.medium : vlcPlayer.position == 0 && vlcPlayer.playlist.currentItem == 0 ? settings.automute == 0 ? ui.icon.volume.medium : ui.icon.mute : vlcPlayer.audio.mute ? ui.icon.mute : vlcPlayer.volume == 0 ? ui.icon.mute : vlcPlayer.volume <= 30 ? ui.icon.volume.low : vlcPlayer.volume > 30 && vlcPlayer.volume <= 134 ? ui.icon.volume.medium : ui.icon.volume.high : ""
					iconSize: fullscreen ? 17 : 16
					width: skinData.done === true ? ui.settings.toolbar.buttonMuteWidth : skinData.variables.settings.toolbar.buttonMuteWidth
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("mute");
					onButtonEntered: wjs.refreshMuteIcon();
					onButtonExited: wjs.refreshMuteIcon();

				}
				// End Mute Button
				
				// Start Volume Control
				Local.VolumeHeat {
									
					Local.VolumeHeatMouse {
						id: volumeMouse
						onPressAndHold: wjs.hoverVolume(mouseX,mouseY)
						onPositionChanged: wjs.clickVolume(mouseX,mouseY)
						onReleased: wjs.clickVolume(mouseX,mouseY)
					}
					Local.VolumeHeatGraphics {
						id: volheat
						backgroundColor: ui.colors.volumeHeat.background
						volColor: ui.colors.volumeHeat.color
					}
	
				}
				// End Volume Control

				Local.ToolbarBorder {
					id: volumeBorder
					anchors.left: mutebut.right
					anchors.leftMargin: settings.firstvolume == 1 ? 0 : mutebut.hover.containsMouse ? 130 : volumeMouse.dragger.containsMouse ? 130 : 0
					color: ui.colors.toolbar.border
					visible: borderVisible
					Behavior on anchors.leftMargin { PropertyAnimation { duration: 250 } }
				}
	
				// Start "Time / Length" Text in Toolbar
				Local.ToolbarTimeLength {
					id: showtime
					text: wjs.getTime(vlcPlayer.time)
					color: ui.colors.toolbar.currentTime
				}
				Local.ToolbarTimeLength {
					anchors.left: showtime.right
					anchors.leftMargin: 0
					text: settings.refreshTime ? wjs.getLengthTime() != "" ? " / "+ wjs.getLengthTime() : "" : wjs.getLengthTime() != "" ? " / "+ wjs.getLengthTime() : ""
					color: ui.colors.toolbar.lengthTime
				}
				// End "Time / Length" Text in Toolbar
			}
			// End Left Side Buttons in Toolbar
			
			// Start Right Side Buttons in Toolbar
			Local.ToolbarRight {
				// Start Open Subtitle Menu Button
				Local.ToolbarBorder {
					color: ui.colors.toolbar.border
					visible: subButton.visible ? borderVisible : false
				}
				Local.ToolbarButton {
					id: subButton
					icon: settings.glyphsLoaded ? ui.icon.subtitles : ""
					iconSize: fullscreen ? 17 : 16
					anchors.right: playlistButton.visible? playlistButton.left : fullscreenButton.left
					anchors.rightMargin: 1
					visible: false
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("subtitles");
				}
				// End Open Subtitle Menu Button
				
				// Start Open Playlist Button
				Local.ToolbarBorder {
					color: ui.colors.toolbar.border
					anchors.right: playlistButton.left
					visible: playlistButton.visible ? borderVisible : false
				}
				Local.ToolbarButton {
					id: playlistButton
					icon: settings.glyphsLoaded ? ui.icon.playlist : ""
					iconSize: fullscreen ? 18 : 17
					visible: settings.debugPlaylist ? true : vlcPlayer.playlist.itemCount > 1 ? true : false
					anchors.right: fullscreenButton.left
					anchors.rightMargin: 1
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("playlist");
				}
				// End Open Playlist Button
				
				// Fullscreen Button
				Local.ToolbarBorder {
					color: ui.colors.toolbar.border
					anchors.right: fullscreenButton.left
					visible: borderVisible
				}
				Local.ToolbarButton {
					id: fullscreenButton
					anchors.right: parent.right
					icon: settings.glyphsLoaded ? fullscreen ? ui.icon.minimize : ui.icon.maximize : ""
					iconSize: fullscreen ? 18 : 17
					iconElem.color: settings.allowfullscreen == 1 ? hover.containsMouse ? ui.colors.toolbar.buttonHover : ui.colors.toolbar.button : ui.colors.toolbar.buttonHover
					hover.cursorShape: settings.allowfullscreen == 1 ? toolbar.opacity == 1 ? Qt.PointingHandCursor : mousesurface.cursorShape : Qt.ForbiddenCursor
					opacity: settings.allowfullscreen == 1 ? 1 : 0.2
					color: settings.allowfullscreen == 1 ? "transparent" : "#000000"
					glow: ui.settings.buttonGlow
					onButtonClicked: buttons.clicked("fullscreen");
				}
				// End Fullscreen Button
			}
			// End Right Side Buttons in Toolbar
		}
		// End Draw Toolbar
		
		// Draw Time Bubble (visible when hovering over Progress Bar)
	//	Local.TimeBubble {
	//		id: timeBubble
	//		fontColor: ui.colors.timeBubble.font
	//		backgroundIcon: settings.glyphsLoaded ? ui.icon.timeBubble.small : ""
	//		backgroundColor: ui.colors.timeBubble.background
	//		backgroundBorder: ui.colors.timeBubble.border
	//		backgroundOpacity: 0.9
	//	}
		// End Time Bubble

		// Draw Progression Bar
    //    Local.ProgressBar {
	//		id: progressBar
	//		backgroundColor: ui.colors.progress.background
	//		viewedColor: ui.colors.progress.viewed
	//		positionColor: ui.colors.progress.position
	//		cache.visible: false // vlcPlayer.state > 0 ? ui.settings.caching : false // fix for non-notify issue
	//		cache.color: ui.colors.progress.cache
	//		//onPressed: wjs.progressDrag(mouseX,mouseY);
	//		//onChanged: wjs.progressChanged(mouseX,mouseY);
	//		//onReleased: wjs.progressReleased(mouseX,mouseY);
	//	}
		// End Draw Progress Bar
		
		Local.DigitalZoom { id: digiZoom } // Digital Zoom Feature

		Local.PIP { id: pip } // Picture in Picture Feature
		
		// Start Top Right Text Box
		Local.TopRightText {
			id: volumebox
			fontColor: ui.colors.font
			fontShadow: ui.colors.fontShadow
		}
		// End Top Right Text Box

		// Title Bar (top bar)
		Local.TitleBar {
			id: topText
			fontColor: ui.colors.titleBar.font
			backgroundColor: ui.colors.titleBar.background
			isVisible: settings.uiVisible == 0 ? false : (vlcPlayer.state == 3 || vlcPlayer.state == 4 || vlcPlayer.state == 6) ? ui.settings.titleBar == "fullscreen" ? fullscreen ? true : false : ui.settings.titleBar == "minimized" ? fullscreen === false ? true : false : ui.settings.titleBar == "both" ? true : ui.settings.titleBar == "none" ? false : false : false
		}
		// End Title Bar (top bar)
		
		// Start Playlist Menu
		Local.Menu {
			id: playlistblock
			background.color: ui.colors.playlistMenu.background
			
			// Start Playlist Menu Scroll
			Local.MenuScroll {
				id: playlistScroll
				draggerColor: ui.colors.playlistMenu.drag
				backgroundColor: ui.colors.playlistMenu.scroller
				onDrag: wjs.movePlaylist(mouseY)
				dragger.height: (playlist.totalPlay * 40) < 240 ? 240 : (240 / (playlist.totalPlay * 40)) * 240
			}
			// End Playlist Menu Scroll
		
			Local.MenuContent {
				width: playlistblock.width < 694 ? (playlistblock.width -12) : 682
				
				Local.PlaylistMenuItems { id: playlist } // Playlist Items Holder (This is where the Playlist Items will be loaded)
		
				// Top Holder (Title + Close Button)
				Local.MenuHeader {
					text: "Playlist Menu"
					textColor: ui.colors.playlistMenu.headerFont
					backgroundColor: ui.colors.playlistMenu.header
										
					// Start Close Playlist Button
					Local.MenuClose {
						id: playlistClose
						icon: settings.glyphsLoaded ? ui.icon.closePlaylist : ""
						iconSize: 9
						iconColor: playlistClose.hover.containsMouse ? ui.colors.playlistMenu.closeHover : ui.colors.playlistMenu.close
						color: playlistClose.hover.containsMouse ? ui.colors.playlistMenu.closeBackgroundHover : ui.colors.playlistMenu.closeBackground
						hover.onClicked: { playlistblock.visible = false; }
					}
					// End Close Playlist Button
				}
				// End Top Holder (Title + Close Button)
				
			}
		}
		// End Playlist Menu

		// Start Replace MRL Text Box (for debug playlist feature)
		Local.ReplaceMRL {
			color: "#111111"
			id: inputBox
		}
		// End Replace MRL Text Box (for debug playlist feature)

		// Start Add MRL Text Box (for debug playlist feature)
		Local.AddMRL {
			color: "#111111"
			id: inputAddBox
		}
		// End Add MRL Text Box (for debug playlist feature)


		// Start Subtitle Menu
		Local.Menu {
			id: subMenublock
			background.color: ui.colors.playlistMenu.background
			
			// Start Subtitle Menu Scroll
			Local.MenuScroll {
				id: subMenuScroll
				draggerColor: ui.colors.playlistMenu.drag
				backgroundColor: ui.colors.playlistMenu.scroller
				onDrag: wjs.moveSubMenu(mouseY)
				dragger.height: (settings.totalSubs * 40) < 240 ? 240 : (240 / (settings.totalSubs * 40)) * 240
			}
			// End Subtitle Menu Scroll
		
			Local.MenuContent {
				width: subMenublock.width < 694 ? (subMenublock.width -12) : 682
				
				Local.SubtitleMenuItems { id: subMenu } // Subtitle Items Holder (This is where the Playlist Items will be loaded)
		
				// Top Holder (Title + Close Button)
				Local.MenuHeader {
					text: "Subtitle Menu"
					textColor: ui.colors.playlistMenu.headerFont
					backgroundColor: ui.colors.playlistMenu.header
										
					// Start Close Subtitle Menu Button
					Local.MenuClose {
						id: subMenuClose
						icon: settings.glyphsLoaded ? ui.icon.closePlaylist : ""
						iconSize: 9
						iconColor: subMenuClose.hover.containsMouse ? ui.colors.playlistMenu.closeHover : ui.colors.playlistMenu.close
						color: subMenuClose.hover.containsMouse ? ui.colors.playlistMenu.closeBackgroundHover : ui.colors.playlistMenu.closeBackground
						hover.onClicked: { subMenublock.visible = false; }
					}
					// End Close Subtitle Menu Button
				}
				// End Top Holder (Title + Close Button)
				
			}
		}
		// End Subtitle Menu
		
		// Start Context Menu
		Local.ContextMenu {
			id: contextblock
			color: ui.colors.playlistMenu.background
			border.color: "#979595"
		}
		// End Context Menu
		
    }
	// End Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) [includes Toolbar]
	
	Component.onCompleted: wjs.onQmlLoaded()
}
