/*
This adds a "back" link to the page.
The idea here is that such a link requires JavaScript, so we don't want to present it to users without JS enabled.
Again, this is to adhere to the doctrine of "progressive enhancement".
I expect that users without JavaScript enabled can hit the back button themselves.
*/
function loadBack() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('customcode-instructions') ) {return false;}
	
	var instructions = document.getElementById('customcode-instructions');
	var backP = document.createElement("p");
	var backA = document.createElement("a");
	var backText = document.createTextNode("back");
	
	backA.onclick = function() {
		history.go(-1);
		return false;
	}
	backA.setAttribute("href","#");
	backA.setAttribute("title","Return to the previous page.");
	backA.appendChild(backText);
	backP.appendChild(backA);
	
	instructions.appendChild(backP);
}
addEvent(window,'load',loadBack);