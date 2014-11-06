/*
normally, I follow structured programming (one exit at the end),
but I make an exception for criteria checks (making sure the subjects of the action exist(
In this case, none of the scripts on this page run unless the file content matches the database content
(this because CF code won't write the sysfile-edit portion unless it does
*/

//Show file edit and hide file view
function fileShowEdit() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('sysfile-view') ) {return false;}
	if ( !document.getElementById('sysfile-edit') ) {return false;}
	
	var viewBox = document.getElementById('sysfile-view');
	var editBox = document.getElementById('sysfile-edit');
	
	viewBox.style.display = 'none;'
	editBox.style.display = 'block;'
}
function fileShowView() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('sysfile-view') ) {return false;}
	if ( !document.getElementById('sysfile-edit') ) {return false;}
	
	var viewBox = document.getElementById('sysfile-view');
	var editBox = document.getElementById('sysfile-edit');
	
	viewBox.style.display = 'block;'
	editBox.style.display = 'none;'
}
/*
Here I add some functionality (while following the doctrine of progressive enhancement as well as sticking to DOM functionality)
I add links for visual hooks to the functionality (add through JS so that non-JS folks aren't bothered with it)
Users without JavaScript will see the view and the edit both on the page (progressive enhancement says the page must still work)
*/
function loadFileEdit() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('sysfile-view') ) {return false;}
	if ( !document.getElementById('sysfile-edit') ) {return false;}
	
	var viewBox = document.getElementById('sysfile-view');
	var editBox = document.getElementById('sysfile-edit');
	
	var editPara = document.createElement('p');
	var editLink = document.createElement('a');
	var editLinkText = document.createTextNode('edit');
	var editParaText = document.createTextNode(' (only once per file per review)');
	
	var viewPara = document.createElement('p');
	var viewLink = document.createElement('a');
	var viewLinkText = document.createTextNode('view');
	
	editLink.appendChild(editLinkText);
	editLink.setAttribute("href","#");//Even if not using it, an href is needed for a browser to treat it like a link
	editLink.setAttribute("title","Edit this file.");//Trying to mitigate the confusion of the above href
	editLink.onclick = function() {
		fileShowEdit();
		return false;//Must return false to stop the browser from following the href
	}
	editPara.appendChild(editLink);
	editPara.appendChild(editParaText);
	viewBox.appendChild(editPara);
	
	viewLink.appendChild(viewLinkText);
	viewLink.setAttribute("href","#");//Even if not using it, an href is needed for a browser to treat it like a link
	viewLink.setAttribute("title","View this file.");//Trying to mitigate the confusion of the above href
	viewLink.onclick = function() {
		fileShowView();
		return false;//Must return false to stop the browser from following the href
	}
	viewPara.appendChild(viewLink);
	editBox.appendChild(viewPara);
	
	fileShowView();//By default, I want to show the view and not the edit (rare that users will need this little extra)
	
	
}
addEvent(window,'load',loadFileEdit);