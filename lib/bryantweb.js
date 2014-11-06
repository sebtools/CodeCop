	function hovText(text) {
		return overlib(text, FGCOLOR, '#FFFFD7');
	}
	
	function ahovText(text,setheight) {
		return overlib(text, FGCOLOR, '#FFFFD7', HEIGHT, setheight, ABOVE);
	}
	
	function popWin(URL) {
		var pageRoot = "http://www.bryantwebconsulting.com/";
		window.open(pageRoot + "index.cfm" + URL, "popWin", "toolbar=no,height=300,width=300");
		return false;
	}
	//alert('bryantweb1');