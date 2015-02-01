var core = {
	// We strongly recommend that you do not remove or change any of the core variables
	curZoom: 0,
	mouseevents: 0,
	aspectRatios: ["Default", "1:1", "4:3", "16:9", "16:10", "2.21:1", "2.35:1", "2.39:1", "5:4"],
	crops: ["Default", "16:10", "16:9", "1.85:1", "2.21:1", "2.35:1", "2.39:1", "5:3", "4:3", "5:4", "1:1"],
	zooms: [[1, "Default"], [2, "2x Double"], [0.25, "0.25x Quarter"], [0.5, "0.5x Half"]],
	
	// Variables to identify current crop, aspect ratio and zoom state
	curZoom: 0,
	curCrop: "Default",
	curAspect: "Default"
}

var settings = {
	iconFont: "fonts/glyphicons.ttf",
	defaultFont: "http://fonts.gstatic.com/s/sourcesanspro/v9/toadOcfmlt9b38dHJxOBGNNE-IuDiR70wI4zXaKqWCM.ttf",
	secondaryFont: "http://fonts.gstatic.com/s/opensans/v10/k3k702ZOKiLJc3WVjuplzInF5uFdDttMLvmWuJdhhgs.ttf",
	toolbar: {
		borderVisible: true,
		buttonWidth: 59,
		buttonMuteWidth: 40
	},
	cache: false, // If cache progress bar is visible or not
	titleBar: "fullscreen", // When should the title bar be visible, possible values are: "fullscreen", "minimized", "both", "none"
	buttonGlow: false // if button icons should glow when hovered
}

var icon = {
	
	// Playback Button Icons
	prev: "\ue80a",
	next: "\ue809",
	play: "\ue87f",
	pause: "\ue880",
	replay: "\ue8a7",
	
	// Audio Related Button Icons
	mute: "\ue877",
	volume: {
		low: "\ue876",
		medium: "\ue875",
		high: "\ue878"
	},
	
	// Playlist Button Icon
	playlist: "\ue833",
	
	// Fullscreen Button Icons
	minimize: "\ue805",
	maximize: "\ue804",
	
	// Big Play/Pause Icons (appear in the center of the screen when Toggle Pause)
	bigPlay: "\ue82d",
	bigPause: "\ue82e",
	
	// Appears when hovering over progress bar
	timeBubble: {
		big: "\ue802",
		small: "\ue803"
	},
	
	// Close Playlist Button
	closePlaylist: "\ue896"
	
}

var colors = {

	// Video Background Color
	videoBackground: "#000000",
	
	// UI Background Color (toolbar, playlist menu)
	background: "#000000",
	
	// Default Font Colors
	font: "#ffffff",
	fontShadow: "#000000",

	// Top Title Bar Colors
	titleBar: {
		background: "#000000",
		font: "#cbcbcb"
	},

	// Progress Bar Colors
	progress: {
		background: "#262626",
		viewed: "#08758F",
		position: "#e5e5e5",
		cache: "#3e3e3e"
	},

	// Appears when hovering over progress bar
	timeBubble: {
		background: "#000000",
		border: "#898989",
		font: "#ffffff"
	},

	// Toolbar colors
	toolbar: {
		border: "#262626",
		button: "#7b7b7b",
		buttonHover: "#ffffff",
		
		// Color for "Time / Length" Text in Toolbar
		timeLength: "#9a9a9a"
	},
	
	// Big Play/Pause Icon (appears in center of screen when Toggle Pause)
	bigIcon: "#ffffff",
	bigIconBackground: "#1c1c1c",
	
	// Playlist Menu Colors
	playlistMenu: {
		background: "#292929",
		scroller: "#696969",
		drag: "#e5e5e5",
		header: "#1C1C1C",
		headerFont: "#d5d5d5",

		// Playlist Menu Close Button
		close: "#c0c0c0",
		closeHover: "#eaeaea",

		// Playlist Menu Close Button Background
		closeBackground: "#1C1C1C",
		closeBackgroundHover: "#151515"
	},
	
	volumeHeat: {
		background: "#696969",
		gradient: {
			low: "#E7A307",
			medium: "#E77607",
			high: "#E72107"
		}
	}
	
}