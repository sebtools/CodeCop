function showExtensions() {showOptions('Extensions');}//effectively extending the showOptions() function in all.js
function changeType() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('RuleType') ) {return false;}
	
	var oType = document.getElementById('RuleType');
	var type = oType.options[oType.selectedIndex].value;
	//alert(type);
	
	if ( type == 'Tag' ) {
		toggleField('TagName','show');
		jsfrmSebform.TagName.required = true;
		jsfrmSebform.Regex.required = false;
		toggleField('Regex','hide');
		document.getElementById('regex-help').style.display = 'none';
	} else {
		toggleField('Regex','show');
		jsfrmSebform.Regex.required = true;
		jsfrmSebform.TagName.required = false;
		toggleField('TagName','hide');
		document.getElementById('regex-help').style.display = 'block';
	}
	
}
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
	addEventToId('RuleType','change',changeType);
	
	showExtensions();
	changeType();
}
addEvent(window,'load',loadClicks);
