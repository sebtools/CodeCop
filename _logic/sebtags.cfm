<cfscript>
request.cftags = StructNew();
request.cftags.sebtags = StructNew();
//Set the appropriate skin based on where this is running.
if ( isInAdmin ) {
	request.cftags.sebtags.skin = "cfadmin";
} else {
	request.cftags.sebtags.skin = "slateTeal";//try graybar,halo,panels,silver,tim
}
/*
Normally I use "/lib/"
In this case I have to back-figure the current directory so that CodeCop can be installed anywhere.
*/
request.cftags.sebtags.librarypath = "#request.Paths.Web.Root#lib/";
//By default my sebtags output valid xhtml, but the CF Admin isn't valid xhtml. So, no love on that.
request.cftags.sebtags.xhtml = false;
</cfscript>