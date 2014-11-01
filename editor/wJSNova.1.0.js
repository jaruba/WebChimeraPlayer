/******************************************
 * Websanova.com
 *
 * Resources for web entrepreneurs
 *
 * @author          Websanova
 * @copyright       Copyright (c) 2012 Websanova.
 * @license         This websanova JSNova jQuery plugin is dual licensed under the MIT and GPL licenses.
 * @link            http://www.websanova.com
 * @docs            http://www.websanova.com/plugins/websanova/jsnova
 * @version         Version 1.0
 *
 ******************************************/

function getUrlVar() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
}

(function($)
{
	$.fn.wJSNova = function(option, settings)
	{	
		if(typeof option === 'object')
		{
			settings = option;
		}
		else if(typeof option === 'string')
		{
			var data = this.data('_wJSNova');

			if(data)
			{
				if(option == 'resize') { data.resize(); return true }
				else if($.fn.wJSNova.defaultSettings[option] !== undefined)
				{
					if(settings !== undefined){
						data.settings[option] = settings;
						return true;
					}
					else return data.settings[option];
				}
				else return false;
			}
			else return false;
		}

		settings = $.extend({}, $.fn.wJSNova.defaultSettings, settings || {});

		return this.each(function()
		{
			var $elem = $(this);

			var $settings = jQuery.extend(true, {}, settings);

			var jsn = new JSNova($settings);

			$elem.append(jsn.generate());
			jsn.resize();

			$elem.data('_wJSNova', jsn);
		});
	}

	$.fn.wJSNova.defaultSettings = {};

	function JSNova(settings)
	{
		this.jsn = null;
		this.settings = settings;

		this.menu = null;

		this.sidebar = null;
		this.jQueryVersion = null;
		this.jQueryUIVersion = null;
		this.jQueryUITheme = null;

		this.codeArea = null;
		this.boxHTML = null;
		this.boxQML = null;
		this.boxJS = null;
		this.boxResult = null;

		return this;
	}

	JSNova.prototype = 
	{
		init: function()
		{
			this.resize();
		},
		
		generate: function()
		{
			var $this = this;

			if($this.jsn) return $this.jsn;

			/************************************************
			 * Menu
			 ************************************************/
			var menuButton_run = $('<span id="buttonrun" class="_wJSNova_menuButton"><i class="glyphicon glyphicon-play"></i>Run</span>').click(function(){$this.run();});
			var menuButton_download = $('<span class="_wJSNova_menuButton"><i class="glyphicon glyphicon-download-alt"></i>Download</span>').click(function(){$this.download();});
			var menuButton_save = $('<span class="_wJSNova_menuButton"><i class="glyphicon glyphicon-send"></i>Suggest Demo</span>').click(function(){$this.save();});
			var menuButton_reset = $('<span class="_wJSNova_menuButton"><i class="glyphicon glyphicon-refresh"></i>Reset</span>').click(function(){$this.reset();});

			$this.menu = 
			$('<div class="_wJSNova_menu"></div>')
			.append('<a href="http://jaruba.github.io/WebchimeraGUI/"><div class="_wJSNova_logo"></div></a>')
			.append(
				$('<div class="_wJSNova_menuPadding"></div>')
				.append(menuButton_run)
				.append(menuButton_download)
				.append(menuButton_save)
				.append(menuButton_reset) 
				.append('<span id="message"></span>')
			);
			
			/************************************************
			 * Sidebar
			 ************************************************/
			var demos = [['Basic (No GUI)', 'basic'],['Single Video','single'],['Playlist','playlist'],['Custom Titles','titles'],['Duplicate Video 2','duplicate2'],['Whirlwind','whirlwind'],['Multiscreen Demo','multiscreen'],['Duplicate Video','duplicate'],['Fullscreen Zoom','zoom'],['3D Rotate','rotate']];
			$this.Demoz = $("<select name='demos' onchange='location = \"http://jaruba.github.io/WebchimeraGUI/editor/?demo=\"+this.options[this.selectedIndex].value;' style='width: 100%'></select>");
			var hash = getUrlVar()["demo"];
			 for (var item = 0; item < demos.length; item++) {
				 if (demos[item][1] == hash) {
					$this.Demoz.append('<option value="' + demos[item][1] + '" selected>' + demos[item][0] + '</option>');
				 } else {
					$this.Demoz.append('<option value="' + demos[item][1] + '">' + demos[item][0] + '</option>');
				 }
			 }

			
			$this.WebchimeraJS = $('<select name="webchimerajs" class="_wJSNova_sidebarSelect"></select>');
			$this.WebchimeraJS.append('<option value="latest">Latest Webchimera.js</option>');
			$this.WebchimeraJS.append('<option value="none">none</option>');

			$this.jQueryVersion = $('<select name="jquery" class="_wJSNova_sidebarSelect"></select>');
			$this.jQueryVersion.append('<option value="none">none</option>');
			$.each(['2.1.1', '2.1.0', '2.0.3', '2.0.2', '2.0.1', '2.0.0', '1.11.1', '1.11.0'],
			function(index,version){ $this.jQueryVersion.append('<option value="https://ajax.googleapis.com/ajax/libs/jquery/' + version + '/jquery.min.js">jQuery ' + version + '</option>'); });	

			$this.jQueryUIVersion = $('<select name="jqueryui" class="_wJSNova_sidebarSelect"></select>');
			$this.jQueryUIVersion.append('<option value="none">none</option>');
			$.each(['1.11.2', '1.11.1', '1.11.0', '1.10.4', '1.10.3', '1.10.2', '1.10.1', '1.10.0', '1.9.2', '1.9.1', '1.9.0'],
			function(index,version){ $this.jQueryUIVersion.append('<option value="https://ajax.googleapis.com/ajax/libs/jqueryui/' + version + '/jquery-ui.min.js">jQuery UI ' + version + '</option>'); });

//			$this.jQueryUITheme = $('<select class="_wJSNova_sidebarSelect"></seletct>');
//			$.each(['base', 'black-tie', 'blitzer', 'cupertino', 'dot-luv', 'excite-bike', 'hot-sneaks', 'humanity', 'mint-choc', 'redmond', 'smoothness', 'south-street', 'start', 'swanky-purse', 'trontastic', 'ui-darkness', 'ui-lightness', 'vader'],
//			function(index,version){ $this.jQueryUITheme.append('<option value="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/' + version + '/jquery-ui.css">' + version + '</option>'); });

			$this.sidebar = 
			$('<div class="_wJSNova_sidebar"></div>')
			.append(
				$('<div class="_wJSNova_sidebarPadding"></div>')
				.append('<div class="_wJSNova_sidebarLabel">Select Demo:</div>')
				.append($this.Demoz)
				.append('<div class="_wJSNova_sidebarLabel">Webchimera JS:</div>')
				.append($this.WebchimeraJS)
				.append('<div class="_wJSNova_sidebarLabel">jQuery Version:</div>')
				.append($this.jQueryVersion)
				.append('<div class="_wJSNova_sidebarLabel">jQuery UI Version:</div>')
				.append($this.jQueryUIVersion)
//				.append('<div class="_wJSNova_sidebarLabel">jQuery UI Theme:</div>')
//				.append($this.jQueryUITheme)
			);

			/************************************************
			 * Code Area
			 ************************************************/
			$this.boxHTML = $('<textarea name="html" class="_wJSNova_boxEdit" data-editor="html"></textarea>');
			$this.boxQML = $('<textarea name="qml" class="_wJSNova_boxEdit" data-editor="javascript"></textarea>');
			$this.boxJS = $('<textarea name="js" class="_wJSNova_boxEdit" data-editor="javascript"></textarea>');
			$this.boxResult = $('<iframe id="iframe" class="_wJSNova_boxEdit" frameBorder="0" style="z-index: 1"></iframe>');
			
			$.each([$this.boxHTML, $this.boxQML, $this.boxJS, $this.boxResult], function(index, item)
			{
				item.hover(function(){ $(this).parent().children('._wJSNova_boxLabel').fadeOut(200); }, function() { if (!($(this).is(":focus"))) $(this).parent().children('._wJSNova_boxLabel').fadeIn(200); });
			});
			
			$this.codeArea = 
			$('<div class="_wJSNova_codeArea"></div>')
			.append(
				$('<table class="_wJSNova_codeAreaTable" cellpadding="0" cellspacing="1"></table>')
				.append(
					$('<tr></tr>')
					.append(
						$('<td class="_wJSNova_box _wJSNova_boxTop _wJSNova_boxLeft"></td>')
						.append(
							$('<div class="_wJSNova_boxContainer"></div>')
							.append($this.boxHTML)
							.append('<div id="htmlbox" class="_wJSNova_boxLabel">HTML</div>')
							.hover(function() { $("#htmlbox").fadeOut(200); },function() { $("#htmlbox").fadeIn(200); })
						)
					)
					.append(
						$('<td class="_wJSNova_box _wJSNova_boxTop _wJSNova_boxRight"></td>')
						.append(
							$('<div class="_wJSNova_boxContainer"></div>')
							.append($this.boxJS)
							.append('<div id="jsbox" class="_wJSNova_boxLabel">JavaScript</div>')
							.hover(function() { $("#jsbox").fadeOut(200); },function() { $("#jsbox").fadeIn(200); })
						)
					)
				)
				.append(
					$('<tr></tr>')
					.append(
						$('<td class="_wJSNova_box _wJSNova_boxBottom _wJSNova_boxLeft"></td>')
						.append(
							$('<div class="_wJSNova_boxContainer"></div>')
							.append($this.boxQML)
							.append('<div id="qmlbox" class="_wJSNova_boxLabel">QML</div>')
							.hover(function() { $("#qmlbox").fadeOut(200); },function() { $("#qmlbox").fadeIn(200); })
						)
					)
					.append(
						$('<td class="_wJSNova_box _wJSNova_boxBottom _wJSNova_boxRight"></td>')
						.append(
							$('<div class="_wJSNova_boxContainer"></div>')
							.append('<div id="runcode" onclick="$(\'#runcode\').remove(); $(\'#buttonrun\').trigger(\'click\'); return false;"></div>')
							.append($this.boxResult)
							.append('<div class="_wJSNova_boxLabel">Result</div>')
						)
					)
				)
			)
			
			$this.jsn = 
			$('<div class="_wJSNova_holder"></div>')
			.append($this.menu)
			.append($this.sidebar)
			.append($this.codeArea);
			
			return $this.jsn;
		},
		
		run: function()
		{
			for (kl = 0; typeof textareas[kl] !== 'undefined'; kl++) textareas[kl].val(editors[kl].getSession().getValue());
			var html = this.boxHTML.val();
			var js = this.boxJS.val();
			var qml = this.boxQML.val();

			if (this.WebchimeraJS.val() != "none") {
				var WebchimeraScript = '<script type="text/javascript" src="http://jaruba.github.io/WebchimeraGUI/js/webchimera.js"></script>';
			} else WebchimeraScript = '';
			
			if (this.jQueryVersion.val() != "none") {
				var jQuery = '<script type="text/javascript" src="' + this.jQueryVersion.val() + '"></script>';
			} else jQuery = '';
			
			if (this.jQueryUIVersion.val() != "none") {
				var jQueryUI = '<script type="text/javascript" src="' + this.jQueryUIVersion.val() + '"></script>';
			} else var jQueryUI = '';
			
//			var jQueryUITheme = '<link rel="stylesheet" type="text/css" href="' + this.jQueryUITheme.val() + '"/>'
			
			var result = '<html><head>' + WebchimeraScript + jQuery + jQueryUI + '<style>#player_wrapper { width: 100%; height: 100% } #qmlcode { display: none }</style></head><body>' + html + '<textarea id="qmlcode">' + qml + '</textarea><script type="text/javascript">' + js + ' var objs = document.getElementsByTagName("object"); for(var i = 0; i < objs.length; i++) if (objs[i].type == "application/x-chimera-plugin") document.getElementById(objs[i].id).qml = document.getElementById("qmlcode").value; </script></body></html>';
			
			this.writeResult(result);
		},
		
		reset: function()
		{
			location.reload();
		},
		
		download: function()
		{
			for (kl = 0; typeof textareas[kl] !== 'undefined'; kl++) textareas[kl].val(editors[kl].getSession().getValue());
			$("#editorform").submit();
		},
		
		save: function()
		{
			for (kl = 0; typeof textareas[kl] !== 'undefined'; kl++) textareas[kl].val(editors[kl].getSession().getValue());
			var data = $("#editorform").serializeArray();
			$.post("http://www.movault.net/webchimera/editor/generator/demos/custom-demo.php", data);
			$("#message").html("Demo sent successfully!").fadeIn(300).delay(2500).fadeOut(300);
		},
		
		writeResult: function(result)
		{
			var iframe = this.boxResult[0];
		
			if(iframe.contentDocument) doc = iframe.contentDocument;
			else if(iframe.contentWindow) doc = iframe.contentWindow.document;
			else doc = iframe.document;
			
			doc.open();
			doc.writeln(result);
			doc.close();
		},
		
		resize: function()
		{
			var menuHeight = this.menu.outerHeight(true);
			var jsnHeight = this.jsn.outerHeight(true) - menuHeight;
			
			var codeAreaWidth = this.jsn.outerWidth(true) - this.sidebar.outerWidth(true);
			
			this.sidebar.css({top: menuHeight, height: jsnHeight});
			this.codeArea.css({top: menuHeight, height: jsnHeight, width: codeAreaWidth});
		}
	}
})(jQuery);
