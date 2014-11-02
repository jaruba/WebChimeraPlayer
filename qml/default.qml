/*****************************************************************************
* Copyright (c) 2014 Sergey Radionov <rsatom_gmail.com>
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
import QtQuick.Layouts 1.0
import QmlVlc 0.1

Rectangle {
	property var gobigplay: false;
	property var gobigpause: false;
	property var dragging: false;
	property var lastitem: 0;
	property var lastpos: 0;
	property var laststate: 0;
	property var ismoving: 1;
	property var buffering: 0;
	property var playlistmenu: false;
	property var pli: 0;
	property var plstring: "";
		
	// Start Function for Toggle Pause
	function togPause() {
		if (vlcPlayer.state == 6) {
		
			vlcPlayer.playlist.playItem(lastitem); // if playback ended, restart playback
			
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
			
			vlcPlayer.togglePause(); // Toggle Pause
			
		}
	}
	// End Function for Toggle Pause
	
	Component.onCompleted: {
        vlcPlayer.onMediaPlayerBuffering.connect( onBuffering ); // Set Buffering Event Handler

		// Adding Playlist Menu Items
		for (pli = 0; pli < vlcPlayer.playlist.itemCount; pli++) {
			if (vlcPlayer.playlist.items[pli].title.replace("[custom]","").length > 85) {
				plstring = vlcPlayer.playlist.items[pli].title.replace("[custom]","").substr(0,85) +'...';
			} else {
				plstring = vlcPlayer.playlist.items[pli].title.replace("[custom]","");
			}
			Qt.createQmlObject('import QtQuick 2.1; import QtQuick.Layouts 1.0; import QmlVlc 0.1; Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.topMargin: 32 + ('+ pli +' *40); color: "transparent"; width: playlistblock.width < 694 ? (playlistblock.width -56) : 638; height: 40; MouseArea { id: pitem'+ pli +'; hoverEnabled: true; anchors.fill: parent; onClicked: vlcPlayer.playlist.playItem('+ pli +'); } Rectangle { width: playlistblock.width < 694 ? (playlistblock.width -56) : 638; clip: true; height: 40; color: vlcPlayer.state == 1 ? vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#656565" : "#e5e5e5" : pitem'+ pli +'.containsMouse ? "#656565" : "#444444" : vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#656565" : "#e5e5e5" : pitem'+ pli +'.containsMouse ? "#656565" : "#444444"; Text { anchors.left: parent.left; anchors.leftMargin: 30; anchors.verticalCenter: parent.verticalCenter; text: "'+ plstring +'"; font.pointSize: 10; color: vlcPlayer.state == 1 ? vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5" : vlcPlayer.playlist.currentItem == '+ pli +' ? pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#2f2f2f" : pitem'+ pli +'.containsMouse ? "#e5e5e5" : "#e5e5e5"; } } }', playmbig, 'plmenustr' +pli);
		}							
		// End Adding Playlist Menu Items

    }

    function onBuffering( percents ) {
        buftext.text = "Buffering " + percents +"%"; // Announce Buffering Percent
		buffering = percents; // Set Global Variable "buffering"
    }
	
	// Start Function to Scroll Playlist Menu
	function movePlaylist(mousehint) {
		if (mousehint <= (playmdrag.height / 2)) {
			playmdrag.anchors.topMargin = 0;
			playmbig.anchors.topMargin = 0;
		} else if (mousehint >= (240 - (playmdrag.height / 2))) {
			playmdrag.anchors.topMargin = 240 - playmdrag.height;
			if ((vlcPlayer.playlist.itemCount *40) > 240) {
				playmbig.anchors.topMargin = 240 - (vlcPlayer.playlist.itemCount *40);
			}
		} else {
			playmdrag.anchors.topMargin = mousehint - (playmdrag.height / 2);
			playmbig.anchors.topMargin = -(((vlcPlayer.playlist.itemCount * 40) - 240) / ((240 - playmdrag.height) / (mousehint - (playmdrag.height /2))));
		}
	}
	// End Function to Scroll Playlist Menu
	

	
    id: theview;
    color: "#000000"; // Set Video Background Color
	
	// Declare Video Layer
    VlcVideoSurface {
        source: vlcPlayer;
        anchors.top: parent.top;
        anchors.left: parent.left;
        width: parent.width;
        height: parent.height;
    }
	// End Video Layer
	
	// Check if mouse has been moved every 1 second (needed to know when to hide Toolbar in Full Screen)
	Timer {
		interval: 1000; running: true; repeat: true
		onTriggered: {
			// Don't Hide Toolbar if it's Hovered
			if (dragpos.containsMouse === false) if (bottomtab.containsMouse === false) ismoving++;
		}
	}
	// End Check Mouse Movement
	
	// Triggered when player is in Opening State
	Timer {
		interval: 1; running: vlcPlayer.state == 1 ? true : false; repeat: false
		onTriggered: {
			buftext.text = "Opening"; // Announce Opening State
		}
	}
	// End Opening State
	
	// Semi-transparent black background for Announcements (Opening, Buffering, etc.)
	Rectangle {
		id: bufbox
		visible: vlcPlayer.state == 1 ? true : buffering > 0 && buffering < 100 ? true : false
		color: '#000000'
		opacity: 0.6
		width: 160
		height: 34
		anchors.top: parent.top
		anchors.topMargin: 7
		anchors.horizontalCenter: parent.horizontalCenter
	}
	// End Announce Background
	
	// Announcement Text (Opening, Buffering, etc.)
	Text {
		id: buftext
		visible: vlcPlayer.state == 1 ? true : buffering > 0 && buffering < 100 ? true : false
		anchors.top: parent.top
		anchors.topMargin: 10
		anchors.horizontalCenter: parent.horizontalCenter
		text: ""
		font.pointSize: 15
		color: "#fff"
	}
	// End Announce Text
	
	// Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) includes Toolbar
    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
		onClicked: { if (vlcPlayer.state != 1) if (bottomtab.containsMouse === false) togPause(); } // Toggle Pause if clicked on Surface
		onPositionChanged: { ismoving = 1; } // Reset Idle Mouse Movement if mouse position has changed
		focus: true
		Keys.onPressed: {
			if (event.key == Qt.Key_Space) { togPause(); }
			if (event.key == Qt.Key_Escape) { fullscreen = false; }
		}		
		
		// Draw Progression Bar
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: fullscreen ? 30 : parent.containsMouse ? 30 : 0
			opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
			Behavior on opacity { PropertyAnimation { duration: 250} }
			
			// Start Progress Bar Functionality (Time Chat Bubble, Seek)
			MouseArea {
				id: dragpos
		        hoverEnabled: true
				anchors.fill: parent
				onPressed: {
					dragging = true;
					var newtime = (vlcPlayer.time * (1 / vlcPlayer.position)) * ((mouse.x -4) / theview.width);
					if (newtime > 0) srctime.text = (("0" + Math.floor(newtime / 3600000)).slice(-2)) +":"+ (("0" + (Math.floor(newtime / 60000) %60)).slice(-2)) +":"+ ("0" + (Math.floor((newtime - Math.floor(newtime / 3600000) * 3600000 - Math.floor(vlcPlayer.time / 60000) * 60000) / 1000) %60)).slice(-2);
				}
				onPositionChanged: {
					var newtime = (vlcPlayer.time * (1 / vlcPlayer.position)) * ((mouse.x -4) / theview.width);
					if (newtime > 0) srctime.text = (("0" + Math.floor(newtime / 3600000)).slice(-2)) +":"+ (("0" + (Math.floor(newtime / 60000) %60)).slice(-2)) +":"+ ("0" + (Math.floor((newtime - Math.floor(newtime / 3600000) * 3600000 - Math.floor(newtime / 60000) * 60000) / 1000) %60)).slice(-2);
				}
				onReleased: {
					if (vlcPlayer.state == 6) vlcPlayer.playlist.playItem(lastitem);
					vlcPlayer.position = (mouse.x -4) / theview.width;
					dragging = false;
				}
			}			
            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: '#696969'
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
					id: movepos
                    width: dragging ? dragpos.mouseX -4 : (parent.width - anchors.leftMargin - anchors.rightMargin) * vlcPlayer.position
                    color: '#498c9f'
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
				}
            }
			// End Progress Bar Functionality (Time Chat Bubble, Seek)
		}
        RowLayout {
			id: movecur
		    spacing: 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: dragging ? dragpos.mouseX -4 :(parent.width - anchors.rightMargin) * vlcPlayer.position
            anchors.bottomMargin: fullscreen ? 30 : parent.containsMouse ? 30 : 0
			opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
			Behavior on opacity { PropertyAnimation { duration: 250} }
            Rectangle {
                Layout.fillWidth: true
                height: 8
                color: 'transparent'
                anchors.verticalCenter: parent.verticalCenter
				Rectangle {
					id: curpos
					height: 8
					width: 8
					color: '#e5e5e5'
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
					anchors.left: parent.left
				}
            }
		}
        RowLayout {
		    spacing: 0
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: fullscreen ? spacing : parent.containsMouse ? spacing : -height
			opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
			Behavior on opacity { PropertyAnimation { duration: 250} }
            Rectangle {
                Layout.fillWidth: true
                height: 30
				color: '#2b2b2b'
                anchors.verticalCenter: parent.verticalCenter
				MouseArea {
					id: bottomtab
					hoverEnabled: true
					anchors.fill: parent
				}
			}
		}
		// End Draw Progress Bar

		// Top Bar (shows custom video title - if set)
        RowLayout {
			visible: vlcPlayer.state == 3 || vlcPlayer.state == 4 || vlcPlayer.state == 6 ? fullscreen ? vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].title.indexOf("[custom]") > -1 ? 1 : 0 : 0 : 0
		    spacing: 0
            anchors.left: parent.left
            anchors.right: parent.right
			anchors.top: parent.top
            anchors.topMargin: spacing
			opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
            Behavior on opacity { PropertyAnimation { duration: 250} }
            Rectangle {
                Layout.fillWidth: true
                height: 34
				color: '#000000'
				opacity: 0.7
                anchors.verticalCenter: parent.verticalCenter
				Text {
					id: toptext
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left;
					anchors.leftMargin: 14
					text: vlcPlayer.state == 1 ? vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].title.replace("[custom]","") : vlcPlayer.playlist.items[vlcPlayer.playlist.currentItem].title.replace("[custom]","");
					font.pointSize: 12
					color: "#ffffff"
				}
			}
		}
		// End Top Bar (shows video title - if set)
		
		// Draw Toolbar
        RowLayout {
            id: toolbar
			spacing: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: fullscreen ? spacing : parent.containsMouse ? spacing : -height
			opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
			Behavior on opacity { PropertyAnimation { duration: 250} }

			// Start Playlist Previous Button
            Rectangle {
				id: prevBut
                height: 30
				width: 59
				visible: vlcPlayer.playlist.itemCount > 1 ? true : false
                color: 'transparent'
                Image {
                    source: mouseAreaPrev.containsMouse ? "../images/prev_h.png" : "../images/prev.png"
                    anchors.centerIn: parent
					MouseArea {
					   id: mouseAreaPrev
					   anchors.fill: parent
					   anchors.margins: 0
					   hoverEnabled: true
					}
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: vlcPlayer.playlist.prev()
                }
            }
            Rectangle {
				id: prevBut2
				height: 30
				width: 1
				color: '#404040'
				visible: vlcPlayer.playlist.itemCount > 1 ? true : false
			}
			// End Playlist Previous Button

			// Start Play/Pause Button
            Rectangle {
                height: 30
                width: 59
                color: 'transparent'
                Image {
                    source: mouseAreaPlay.containsMouse ? vlcPlayer.playing ? "../images/pause_h.png" : vlcPlayer.state != 6 ? "../images/play3_h.png" : "../images/replay2_h.png" : vlcPlayer.playing ?"../images/pause.png" :  vlcPlayer.state != 6 ? "../images/play3.png" : "../images/replay2.png"
                    anchors.centerIn: parent
					MouseArea {
					   id: mouseAreaPlay
					   anchors.fill: parent
					   anchors.margins: 0
					   hoverEnabled: true
					}
                }
                MouseArea {
                    anchors.fill: parent					
                    onClicked: togPause()
                }
            }
            Rectangle {
				height: 30
				width: 1
				color: '#404040'
			}
			// End Play/Pause Button

			// Start Playlist Next Button
            Rectangle {
				id: nextBut
                height: 30
				width: 59
				visible: vlcPlayer.playlist.itemCount > 1 ? true : false
                color: 'transparent'
                Image {
                    source: mouseAreaNext.containsMouse ? "../images/next_h.png" : "../images/next.png"
                    anchors.centerIn: parent
					MouseArea {
					   id: mouseAreaNext
					   anchors.fill: parent
					   anchors.margins: 0
					   hoverEnabled: true
					}
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: vlcPlayer.playlist.next();
                }
            }
            Rectangle {
				id: nextBut2
				height: 30
				width: 1
				visible: vlcPlayer.playlist.itemCount > 1 ? true : false
				color: '#404040'
			}
			// End Playlist Next Button
			
			// Start Mute Button
            Rectangle {
				id: mutebut
                height: 30
                width: 40
                color: 'transparent'
                Image {
					id: muteimg
					source: vlcPlayer.audio.mute ? mouseAreaMute.containsMouse ? "../images/mute-off5_h.png" : "../images/mute-off2.png" : mouseAreaMute.containsMouse ? "../images/mute-on3_h.png" : "../images/mute-on3.png"
                    anchors.top: parent.top
					anchors.topMargin: 1
                    anchors.left: parent.left
					anchors.leftMargin: 2
					Timer {
						interval: 1; running: vlcPlayer.state == 3 && vlcPlayer.time > 0 ? true : false; repeat: false
						onTriggered: {
							movecura.anchors.leftMargin = (parent.width - anchors.leftMargin - anchors.rightMargin) * (vlcPlayer.volume /60);
							moveposa.width = (parent.width - anchors.leftMargin - anchors.rightMargin) * (vlcPlayer.volume /60);
							lastitem = vlcPlayer.playlist.currentItem;
						}
					}
					Timer {
						interval: 1; running: true; repeat: true
						onTriggered: {
							// Fix for Playback Freeze Bug
							if (vlcPlayer.state != 6 && vlcPlayer.state != 7) {
								lastpos = vlcPlayer.position;
								if (laststate != vlcPlayer.state) laststate = vlcPlayer.state;
							} else {
								if (laststate >= 0 && laststate <= 4) {
									if (lastpos < 0.95) {
										vlcPlayer.playlist.playItem(lastitem);
										vlcPlayer.position = lastpos;
									}
									laststate = vlcPlayer.state;
								}
							}
							// End Fix for Playback Freeze Bug
						}
					}
                }
				MouseArea {
				   id: mouseAreaMute
				   anchors.fill: parent
				   anchors.margins: 0
				   hoverEnabled: true
                    onClicked: { 
						vlcPlayer.toggleMute();
						muteimg.source = vlcPlayer.audio.mute ? mouseAreaMute.containsMouse ? "../images/mute-off5_h.png" : "../images/mute-off2.png" : mouseAreaMute.containsMouse ? "../images/mute-on3_h.png" : "../images/mute-on3.png"
					}
                    onEntered: { 
						muteimg.source = vlcPlayer.audio.mute ? mouseAreaMute.containsMouse ? "../images/mute-off5_h.png" : "../images/mute-off2.png" : mouseAreaMute.containsMouse ? "../images/mute-on3_h.png" : "../images/mute-on3.png"
					}
					onExited: {
						muteimg.source = vlcPlayer.audio.mute ? mouseAreaMute.containsMouse ? "../images/mute-off5_h.png" : "../images/mute-off2.png" : mouseAreaMute.containsMouse ? "../images/mute-on3_h.png" : "../images/mute-on3.png"
					}
				}
            }
			// End Mute Button
			
			// Start Volume Control
            Rectangle {
				clip: true
                height: 30
                width: mouseAreaMute.containsMouse ? 120 : mouseAreaVl.containsMouse ? 120 : 0
				anchors.top: parent.top
				color: 'transparent'
	            Behavior on width { PropertyAnimation { duration: 250} }
                Image {
                    source: "../images/volume.png"
					width: 106
					height: 18
					anchors.left: parent.left
					anchors.leftMargin: 7
					anchors.verticalCenter: parent.verticalCenter
                }
				MouseArea {
					id: mouseAreaVl
					anchors.fill: parent
					anchors.left: parent.left
				    hoverEnabled: true
				}
				MouseArea {
					id: mouseAreaVol
					anchors.fill: parent
					anchors.left: parent.left
					onPressAndHold: { if (mouse.x > 0 && mouse.x < 116) { moveposa.width = mouse.x -2; movecura.anchors.leftMargin = mouse.x -2; } else if (mouse.x <= 0) { moveposa.width = 0; movecura.anchors.leftMargin = 0; } else if (mouse.x >= 116) { moveposa.width = 120; movecura.anchors.leftMargin = 116; } }
					onPositionChanged: { if (mouse.x > 0 && mouse.x < 116) { vlcPlayer.volume = (mouse.x / 120) *200; moveposa.width = mouse.x -2; movecura.anchors.leftMargin = mouse.x -2; } else if (mouse.x <= 0) { vlcPlayer.volume = 0; moveposa.width = 0; movecura.anchors.leftMargin = 0; } else if (mouse.x >= 116) { vlcPlayer.volume = 200; moveposa.width = 120; movecura.anchors.leftMargin = 116; } }
					onReleased: { if (mouse.x > 0 && mouse.x < 116) { vlcPlayer.volume = (mouse.x / 120) *200; moveposa.width = mouse.x -2; movecura.anchors.leftMargin = mouse.x -2; } else if (mouse.x <= 0) { vlcPlayer.volume = 0; moveposa.width = 0; movecura.anchors.leftMargin = 0; } else if (mouse.x >= 116) { vlcPlayer.volume = 200; moveposa.width = 120; movecura.anchors.leftMargin = 116; } }
				}
				Rectangle {
					width: 120
					height: 8
					color: '#696969'
					anchors.verticalCenter: parent.verticalCenter
					Rectangle {
						id: moveposa
						clip: true
						width: (parent.width - anchors.leftMargin - anchors.rightMargin) * (vlcPlayer.volume /60)
						anchors.top: parent.top
						anchors.left: parent.left
						anchors.bottom: parent.bottom
						Image {
							height: 8
							width: 120
							source: "../images/volume_heat.png"
						}
					}
					Rectangle {
						id: movecura
						color: '#ffffff'
						width: 4
						height: 14
						anchors.verticalCenter: parent.verticalCenter
						anchors.left: parent.left
						anchors.leftMargin: (parent.width - anchors.leftMargin - anchors.rightMargin) * (vlcPlayer.volume /60)
					}

				}

            }			
            Rectangle {
				clip: true
				height: 30
				width: mouseAreaMute.containsMouse ? 10 : mouseAreaVl.containsMouse ? 10 : 0
				color: 'transparent'
	            Behavior on width { PropertyAnimation { duration: 250} }
			}
            Rectangle {
				anchors.left: mutebut.right
				anchors.leftMargin: mouseAreaMute.containsMouse ? 130 : mouseAreaVl.containsMouse ? 130 : 0
				height: 30
				width: 1
				color: '#404040'
	            Behavior on anchors.leftMargin { PropertyAnimation { duration: 250} }
			}
			// End Volume Control

			// Start "Time / Length" Text in Toolbar
			Text {
				id: showtime
				anchors.left: mutebut.right
				anchors.leftMargin: mouseAreaMute.containsMouse ? 131 : mouseAreaVl.containsMouse ? 131 : 0
				text: "   "+ (("0" + Math.floor(vlcPlayer.time / 3600000)).slice(-2)) +":"+ (("0" + (Math.floor(vlcPlayer.time / 60000) %60)).slice(-2)) +":"+ ("0" + (Math.floor((vlcPlayer.time - Math.floor(vlcPlayer.time / 3600000) * 3600000 - Math.floor(vlcPlayer.time / 60000) * 60000) / 1000) %60)).slice(-2) +" / "+ (("0" + Math.floor(vlcPlayer.time * (1 / vlcPlayer.position) / 3600000)).slice(-2)) +":"+ (("0" + (Math.floor(vlcPlayer.time * (1 / vlcPlayer.position) / 60000) %60)).slice(-2)) +":"+ ("0" + (Math.floor((vlcPlayer.time * (1 / vlcPlayer.position) - Math.floor(vlcPlayer.time * (1 / vlcPlayer.position) / 3600000) * 3600000 - Math.floor(vlcPlayer.time * (1 / vlcPlayer.position) / 60000) * 60000) / 1000) %60)).slice(-2)
				font.pointSize: 9
				color: "#9a9a9a"
	            Behavior on anchors.leftMargin { PropertyAnimation { duration: 250} }
			}
			// End "Time / Length" Text in Toolbar
        }
		// End Left Side Buttons in Toolbar
		
		// Start Right Side Buttons in Toolbar
        RowLayout {
			spacing: 0
			anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: fullscreen ? spacing : parent.containsMouse ? spacing : -height
			opacity: vlcPlayer.time == 0 ? 0 : fullscreen ? ismoving > 5 ? 0 : 1 : 1
            Behavior on anchors.bottomMargin { PropertyAnimation { duration: 250} }
			Behavior on opacity { PropertyAnimation { duration: 250} }
			
			
			// Start Open Playlist Button
            Rectangle {
				height: 30
				width: 1
				color: '#404040'
			}
            Rectangle {
                height: 30
				width: 59
				visible: vlcPlayer.playlist.itemCount > 1 ? true : false
                color: 'transparent'
                Image {
                    source: mouseAreaPlaylist.containsMouse ? "../images/playlist_h.png" : "../images/playlist.png"
                    anchors.centerIn: parent
					MouseArea {
					   id: mouseAreaPlaylist
					   anchors.fill: parent
					   anchors.margins: 0
					   hoverEnabled: true
					}
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: if (playlistmenu === false) {
						playlistblock.visible = true;
						playlistmenu = true;
					} else { playlistblock.visible = false; playlistmenu = false }
				}
			}
			// End Open Playlist Button
			
			// Fullscreen Button
            Rectangle {
				height: 30
				width: 1
				color: '#404040'
			}
            Rectangle {
                height: 30
                width: 59
				color: 'transparent'
                Image {
					source: fullscreen ? mouseAreaFS.containsMouse ? "../images/fullscreen2_h.png" : "../images/fullscreen2.png" : mouseAreaFS.containsMouse ? "../images/fullscreen_h.png" : "../images/fullscreen.png"
					anchors.centerIn: parent
					MouseArea {
					   id: mouseAreaFS
					   anchors.fill: parent
					   anchors.margins: 0
					   hoverEnabled: true
					}
				}
                MouseArea {
                    anchors.fill: parent
                    onClicked: toggleFullscreen()
                }
            }
			// End Fullscreen Button
        }
		// End Right Side Buttons in Toolbar

		// Set Mute Button State (this is a quick fix, sometimes the Mute Button would appear as Mute on playback start even if Sound was not Muted)
		Timer  {
			interval: 1; running: vlcPlayer.state == 3 && vlcPlayer.time < 5 ? true : false; repeat: false
			onTriggered: {
				muteimg.source = vlcPlayer.audio.mute ? mouseAreaMute.containsMouse ? "../images/mute-off5_h.png" : "../images/mute-off2.png" : mouseAreaMute.containsMouse ? "../images/mute-on3_h.png" : "../images/mute-on3.png"
			}
		}
		// End Set Mute Button State
						
		// When Playback Starts
		Timer {
			interval: 1; running: vlcPlayer.time > 0 && vlcPlayer.time < 1200 ? true : false; repeat: false
			onTriggered: {
				// Show Previous/Next Buttons if Playlist available
				if (vlcPlayer.playlist.itemCount > 1) {
					prevBut.visible = true;
					nextBut.visible = true;
					prevBut2.visible = true;
					nextBut2.visible = true;
				}
				// End Show Previous/Next Buttons if Playlist available
				
				// Set Mute Button State (this is a quick fix, sometimes the Mute Button would appear as Mute on playback start even if Sound was not Muted)
				muteimg.source = vlcPlayer.audio.mute ? mouseAreaMute.containsMouse ? "../images/mute-off5_h.png" : "../images/mute-off2.png" : mouseAreaMute.containsMouse ? "../images/mute-on3_h.png" : "../images/mute-on3.png";
				// End Set Mute Button State
				
			}
		}
		// End When Playback Starts

		// Draw Play Icon Image (appears in center of screen when Toggle Pause)
		Image {
			id: playtog
			source: "../images/play2-150x150.png"
			anchors.centerIn: parent
			visible: false
			height: gobigplay ? 150 : 80
			width: gobigplay ? 150 : 80
			opacity: gobigplay ? 0 : 1
			
			// Start Play Icon Effect when Visible
            Behavior on height { PropertyAnimation { duration: 250} }
            Behavior on width { PropertyAnimation { duration: 250} }
            Behavior on opacity { PropertyAnimation { duration: 250} }
			// End Play Icon Effect when Visible

			// Start Timer to Hide after 250 miliseconds
			Timer  {
				interval: 250; running: gobigplay ? true : false; repeat: false
				onTriggered: {
					playtog.visible = false;
					gobigplay = false;
				}
			}
			// End Timer to Hide after 250 miliseconds
		}
		// End Draw Play Icon Image (appears in center of screen when Toggle Pause)
		
		// Draw Pause Icon Image (appears in center of screen when Toggle Pause)
		Image {
			id: pausetog
			source: "../images/pause2-150x150.png"
			anchors.centerIn: parent
			visible: false
			height: gobigpause ? 150 : 80
			width: gobigpause ? 150 : 80
			opacity: gobigpause ? 0 : 1

			// Start Pause Icon Effect when Visible
            Behavior on height { PropertyAnimation { duration: 250} }
            Behavior on width { PropertyAnimation { duration: 250} }
            Behavior on opacity { PropertyAnimation { duration: 250} }
			// End Pause Icon Effect when Visible

			// Start Timer to Hide after 250 miliseconds
			Timer  {
				interval: 250; running: gobigpause ? true : false; repeat: false
				onTriggered: {
					pausetog.visible = false;
					gobigpause = false;
				}
			}
			// End Timer to Hide after 250 miliseconds
		}
		// End Draw Pause Icon Image (appears in center of screen when Toggle Pause)
		
		// Draw Time Chat Bubble (visible when hovering over Progress Bar)
		Rectangle {
			visible: vlcPlayer.position > 0 ? dragging ? true : dragpos.containsMouse ? true : false : false
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 63
			anchors.left: parent.left
			anchors.leftMargin: dragpos.mouseX < 31 ? 0 : (dragpos.mouseX +31) > theview.width ? (theview.width -62) : (dragpos.mouseX -31) // Move Time Chat Bubble dependant of Mouse Horizontal Position
			color: 'transparent'
			
			// Time Chat Bubble Background Image
			Image {
				width: 62
				height: 25
				source: "../images/show-time.png"
			}
			// End Time Chat Bubble Background Image
			
			// Time Chat Bubble Text
			Text {
				id: srctime
				anchors.top: parent.top
				anchors.topMargin: 3
				anchors.left: parent.left
				anchors.leftMargin: 8
				text: "00:00:00"
				font.pointSize: 9
				color: "#ffffff"
			}
			// End Time Chat Bubble Text
		}
		// End Time Chat Bubble
		// End Toolbar

		// Start Loading Screen
		Rectangle {
			anchors.fill: parent
			color: "#000000"
			visible: vlcPlayer.state < 3 ? true : false
			// If Playlist is Open Show Top Text
			Text {
				visible: playlistmenu
				anchors.top: parent.top
				anchors.topMargin: 10
				anchors.horizontalCenter: parent.horizontalCenter
				text: "Opening"
				font.pointSize: 15
				color: "#fff"
			}
			// End If Playlist is Open Show Top Text

			Rectangle {
				anchors.centerIn: parent
				width: 1
				height: 100
				color: "transparent"
				Rectangle {
					Image {
						anchors.top: parent.top
						anchors.horizontalCenter: parent.horizontalCenter
						source: "../images/player_logo_small.png"
					}
					Image {
						id: playerlogo
						anchors.top: parent.top
						anchors.horizontalCenter: parent.horizontalCenter
						opacity: 0
						Behavior on opacity { PropertyAnimation { duration: 600} }
						source: "../images/player_logo_small_h2.png"
					}
					Text {
						visible: vlcPlayer.state == 1 ? true : buffering > 0 && buffering < 100 ? true : false
						anchors.top: parent.top
						anchors.topMargin: 88
						anchors.horizontalCenter: parent.horizontalCenter
						text: "Loading Resource"
						font.pointSize: 13
						color: "#fff"
					}
				}
			}
		}

		// Start Loading Logo Fade Effect
		Timer {
			interval: 700; running: true; repeat: true
			onTriggered: {
				if (playerlogo.opacity == 1) {
					playerlogo.opacity = 0;
				} else {
					playerlogo.opacity = 1;
				}
			}
		}
		// End Loading Logo Fade Effect

		// End Loading Screen

		// Start Playlist Menu
		Rectangle {
			id: playlistblock
			visible: false
			anchors.centerIn: parent
			width: (parent.width * 0.9) < 694 ? (parent.width * 0.9) : 694
			height: 284
			color: "#444444"
			MouseArea {
				hoverEnabled: true
				anchors.fill: parent
			}
			
			// Start Playlist Menu Scroller
			Rectangle {
				anchors.top: parent.top
				anchors.topMargin: 38
				anchors.right: parent.right
				anchors.rightMargin: 6
				width: 35
				height: 240
				color: "transparent"
				Rectangle {
					anchors.horizontalCenter: parent.horizontalCenter
					width: 10
					height: 240
					color: "#696969"
					opacity: playmdrag.height == 240 ? 0.5 : 1
				}
				Rectangle {
					id: playmdrag
					anchors.top: parent.top
					anchors.topMargin: 0
					anchors.left: parent.left
					anchors.leftMargin: 13
					width: 10
					height: (vlcPlayer.playlist.itemCount * 40) < 240 ? 240 : (240 / (vlcPlayer.playlist.itemCount * 40)) * 240
					opacity: playmdrag.height == 240 ? 0 : 1
					color: "#e5e5e5"
				}
				MouseArea {
					id: playmdragger
					anchors.fill: parent
					onPressed: movePlaylist(mouse.y)
					onPressAndHold: movePlaylist(mouse.y)
					onPositionChanged: movePlaylist(mouse.y)
					onReleased: movePlaylist(mouse.y)
				}
			}
			// End Playlist Menu Scroller

			Rectangle {
				anchors.centerIn: parent
				width: playlistblock.width < 694 ? (playlistblock.width -12) : 682
				height: 272
				color: "transparent"
				clip: true
				
				// Start Playlist Items Holder
				Rectangle {
					id: playmbig
					anchors.top: parent.top
					anchors.topMargin: 0
					width: playlistblock.width < 694 ? (playlistblock.width -12) : 682
					height: 272
					color: "transparent"
					// This is where the Playlist Items will be loaded
				}
				// End Playlist Items Holder
	
	
	
				// Top Holder (Title + Close Button)
				Rectangle {
					anchors.fill: parent
					anchors.centerIn: parent
					width: parent.width
					height: 26
					color: "transparent"
					// Top "Title" text Holder
					Rectangle {
						width: parent.width -44
						anchors.left: parent.left
						anchors.leftMargin: 0
						height: 26
						color: "#2f2f2f"
						Text {
                            anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: 29
							text: "Title"
							font.pointSize: 10
							color: "#d5d5d5"
						}
					}
					// End Top "Title" text Holder
					
					// Start Close Playlist Button
					Image {
						source: "../images/close-list.png"
                        anchors.right: parent.right
                        anchors.rightMargin: 0
						width: 35
						height: 26
						MouseArea {
							anchors.fill: parent
							onClicked: {
								playlistblock.visible = false;
								playlistmenu = false
							}
						}
					}
					// End Close Playlist Button
				}
				// End Top Holder (Title + Close Button)
			}
		}
		// End Playlist Menu
		
		// Load All Images (if an image is used in the UI and it is not set here, it will be loaded with a delay when it first appears in the UI)
		Rectangle {
			visible: false
			Image {	source: "../images/fullscreen_h.png" }
			Image {	source: "../images/fullscreen.png" }
			Image {	source: "../images/fullscreen2_h.png" }
			Image { source: "../images/fullscreen2.png"	}
			Image {	source: "../images/pause_h.png"	}
			Image { source: "../images/pause.png" }
			Image {	source: "../images/play3_h.png"	}
			Image {	source: "../images/play3.png" }
			Image {	source: "../images/mute-off5_h.png"	}
			Image {	source: "../images/mute-off2.png" }
			Image {	source: "../images/mute-on3_h.png" }
			Image {	source: "../images/mute-on3.png" }
			Image {	source: "../images/replay2.png"	}
			Image {	source: "../images/replay2_h.png" }
			Image {	source: "../images/prev.png" }
			Image {	source: "../images/prev_h.png" }
			Image { source: "../images/next.png" }
			Image { source: "../images/next_h.png" }
			Image { source: "../images/playlist.png" }
			Image { source: "../images/playlist_h.png" }
		}
		// End Load All Images

    }
	// End Mouse Area over entire Surface (check mouse movement, toggle pause when clicked) [includes Toolbar]
	
}
