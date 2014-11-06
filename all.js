//Allows events to be attached to objects without interfering with the HTML code
function addEvent(obj, evType, fn) {
	if (obj.addEventListener){
		obj.addEventListener(evType, fn, true);
		return true;
	} else if (obj.attachEvent){
		var r = obj.attachEvent("on"+evType, fn);
		return r;
	} else {
		return false;
	}
}
//a shortcut for the above when adding to an object using its id
function addEventToId(id, evType, fn) {
	addEvent(document.getElementById(id), evType, fn);
}
//A generic show/hide function that can be effectively extended by other functions (see rule-edit.js)
//It is specifically for use with sebForms - any use outside of that would be coincidental
function toggleField(field,action) {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('lbl-' + field) ) {return false;}
	
	var lblOptions = document.getElementById('lbl-' + field);
	var inpOptions;
	var oOptions;
	var dispType;
	
	if ( document.getElementById(field + '_set') ) {
		inpOptions = document.getElementById(field + '_set');
	} else {
		inpOptions = document.getElementById(field);
	}
	
	if ( lblOptions.parentNode.nodeName == "DIV" ) {
		oOptions = lblOptions.parentNode;
		dispType = 'block';
	} else if ( lblOptions.parentNode.parentNode.nodeName == "TR" ) {
		oOptions = lblOptions.parentNode.parentNode;
		dispType = 'table-row';
	}
	
	if ( action == 'hide' ) {
		oOptions.style.display = "none";
		lblOptions.style.display = "none";
		inpOptions.style.display = "none";
	} else {
		try {
			oOptions.style.display = dispType;
		} catch (err) {
			oOptions.style.display = "block";
		}
		lblOptions.style.display = "block";
		inpOptions.style.display = "block";
	}
}
function showOptions(type) {
	if (!document.getElementById) {return false;}
	if ( arguments.length >= 2 ) {
		field = arguments[1];
	} else {
		field = arguments[0];
	}
	var allOptions = document.getElementById('all' + type + '_1');
	
	if ( allOptions.checked ) {
		toggleField(field,'hide')
	} else {
		toggleField(field,'show')
	}
}
//makes any external links behave as target="_blank"
function externalLinks() {
	if (!document.getElementsByTagName) return false;
	
	var anchors = document.getElementsByTagName("a");
	var i=0;
	var anchor = 0;
	var anchorHref = 0;
	var baseUrl = location.protocol + '//'+ location.host;
	
	for ( i=0; i<anchors.length; i++ ) {
		anchor = anchors[i];
		if ( anchor.getAttribute("href") ) {
			anchorHref = anchor.getAttribute("href");
			if ( anchorHref.substr(0,5) == 'http:' || anchorHref.substr(0,6) == 'https:' || anchorHref.substr(0,4) == 'ftp:' ) {
				if ( anchorHref.substr(0,baseUrl.length) != baseUrl ) {
					anchor.target = "_blank";
					if ( anchor.title == '' || anchor.title == undefined ) {
						anchor.title = "external link";
					}
				}
			}
		}
	}
}
addEvent(window, 'load', externalLinks);//Add externalLinks() to window.onLoad