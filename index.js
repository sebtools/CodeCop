function showExtensions() {
	showOptions('Extensions');
	showOptions('Extensions','MoreExtensions');
}//effectively extending the showOptions() function in all.js
/*
Add showExtensions() method to the click of the yes and no options of the "All Extensions".
Run the method manually to ensure that the visibility of the options matches the current selections.
Note that this method ensures the visibility of the choices if JavaScript is not enabled.
Thereby adhering the doctrine of "progressive enhancement"
*/
function loadClicks() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('allExtensions_1') ) {return false;}
	if ( !document.getElementById('allExtensions_0') ) {return false;}
	
	addEventToId('allExtensions_1','click',showExtensions);
	addEventToId('allExtensions_0','click',showExtensions);
	
	showExtensions();
}
function loadBrowseServer() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('browse-server') ) {return false;}
	
	oInput = document.createElement("input");
	oInput.setAttribute("type","button");
	oInput.setAttribute("name","findFolder");
	oInput.setAttribute("value","Browse Server");
	oInput.onclick = function() {
		location.href='server-browse.cfm';
		return false;
	}
	
	document.getElementById('browse-server').appendChild(oInput);
	//<input type="button" name="findFolder" value="Browse Server" onclick="location.href='server-browse.cfm'" />
}
addEvent(window,'load',loadClicks);
addEvent(window,'load',loadBrowseServer);
function getSubmit() {
	var sebForm = document.getElementById('sebForm');
	var btnSubmit = 0;
	var inputs = sebForm.getElementsByTagName('input');
	var i = 0;
	
	for ( i=0; i < inputs.length; i++ ) {
		if ( inputs[i].type == 'submit' && inputs[i].value == 'Submit' ) {
			btnSubmit = inputs[i];
			break;
		}
	}
	return btnSubmit;
}
function loadSubmitting() {
	var btnSubmit = getSubmit();
	var loadImage = new Image();
	loadImage.src = 'i/loader-blue.gif';
	btnSubmit.onclick = function() {
		submitting();
		return true;//Must return true so that form still submits
	}
	//alert('loaded');
}
function submitting() {
	var para1 = document.createElement('p');
	var para2 = document.createElement('p');
	var img = document.createElement('img');
	var waiting = document.createTextNode('waiting...');
	var btnSubmit = getSubmit();
	
	img.setAttribute('width','32');
	img.setAttribute('height','32');
	img.setAttribute('src','i/loader-blue.gif');
	
	para1.appendChild(img);
	para2.appendChild(waiting);
	
	btnSubmit.parentNode.insertBefore(para1,btnSubmit);
	btnSubmit.parentNode.insertBefore(para2,btnSubmit);
	btnSubmit.style.display = 'none';
	return true;
}
addEvent(window,'load',loadSubmitting);