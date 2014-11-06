<!---
1.0 RC2 (Build 111)
Last Updated: 2008-09-04
--->
<cfscript>
cr = "
";
//Coop hook
if ( StructKeyExists(caller,'root') ) {
	root = caller.root;
} else {
	root = caller;
}
if ( StructKeyExists(root,"coop") AND isObject(root.coop) AND StructKeyExists(root.coop,"mergeattributes") ) {
	attributes = root.coop.mergeattributes(attributes,root);
}
function fixAbsoluteLinks(string) {
	var result = arguments.string;
	var reRoot = "https?://#CGI.HTTP_HOST#(:#CGI.SERVER_PORT#)?/";
	var sRegexs = StructNew();
	var findat = 0;
	var ii = 0;
	var jj = 0;
	var atts = "href,src";
	var att = "";
	
	for ( jj=1; jj LTE ListLen(atts); jj=jj+1 ) {
		att = ListGetAt(atts,jj);
		sRegexs[att] = "#att#=#chr(34)##reRoot#";
		
		findat = REFindNoCase(sRegexs[att], result,1,1);
		//result = Mid(result,findat.pos[1],findat.len[1]);
		//result = reHref;
		
		while ( findat.pos[1] GT 0 AND ii LTE 10000 ) {
			//result = result + 1;
			result = ReplaceNoCase(result,Mid(result,findat.pos[1],findat.len[1]),"#att#=#chr(34)#/","ALL");
			findat = REFindNoCase(sRegexs[att], result, findat.pos[1]+1,1);
			ii = ii + 1;
		}
	}
	
	return result;
}
function getLibraryServerPath(librarypath) {
	var fileObj = createObject("java", "java.io.File");
	var dirdelim = fileObj.separator;
	var TemplatePath = ReplaceNoCase(GetBaseTemplatePath(), "\", "/", "ALL");
	var SiteRootTemp = ReplaceNoCase(TemplatePath, CGI.SCRIPT_NAME, "");
	var SiteRootPath = ReplaceNoCase(SiteRootTemp, "/", dirdelim, "ALL");
	var CallingPath = getDirectoryFromPath(GetBaseTemplatePath());
	
	var result = "";
	
	//Make sure Site Root ends with directory delimiter
	if ( Right(SiteRootPath,1) neq dirdelim ) {
		SiteRootPath = SiteRootPath & dirdelim;
	}
	
	//Make sure calling path ends with directory delimiter
	if ( Right(CallingPath,1) neq dirdelim ) {
		CallingPath = CallingPath & dirdelim;
	}
	
	if ( Left(librarypath,1) eq "/" ) {
		result = ReplaceNoCase(librarypath, "/", SiteRootPath, "ONE");
		result = ReplaceNoCase(result, "/", dirdelim, "ALL");
	} else if ( Left(librarypath,7) eq "http://" OR Left(librarypath,8) eq "https://" ) {
		result = librarypath;
	} else {
		result = CallingPath & ReplaceNoCase(librarypath, "/", dirdelim, "ALL");
	}
	
	return result;
}
function setDefaultAtt(varname) {
	var value = "";
	if(arrayLen(Arguments) gt 1) value = Arguments[2];
	if ( Not StructKeyExists(attributes, varname) OR Not Len(attributes[varname]) ) {
		attributes[varname] = value;
	}
	return value;
}
/**
 * Checks passed value to see if it is a properly formatted U.S. social security number.
 * 
 * @param str 	 String you want to validate. (Required)
 * @return Returns a Boolean. 
 * @author Jeff Guillaume (jeff@kazoomis.com) 
 * @version 1, May 8, 2002 
 */
function IsSSN(str) {
  // these may actually be valid, but for business purposes they are not allowed
  var InvalidList = "111111111,222222222,333333333,444444444,555555555,666666666,777777777,888888888,999999999,123456789";
	
  // validation based on info from: http://www.ssa.gov/history/geocard.html
  if (REFind('^([0-9]{3}(-?)[0-9]{2}(-?)[0-9]{4})$', str)) {
    if (Val(Left(str, 3)) EQ 0) return FALSE;
    if (Val(Right(str, 3)) EQ 0) return FALSE;
    if (ListFind(InvalidList, REReplace(str, "[ -]", "", "ALL"))) return FALSE;
    // still here, so SSN is valid
    return True;
  }
  // return default
  return False;
	
}
/**
 * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).
 * Update by David Kearns to support '
 * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.
 * 
 * @param str 	 The string to check. (Required)
 * @return Returns a boolean. 
 * @author Jeff Guillaume (jeff@kazoomis.com) 
 * @version 2, August 15, 2002 
 */
function isEmail(str) {
        //supports new top level tlds
if (REFindNoCase("^['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$",str)) return TRUE;
	else return FALSE;
}
/**
 * Simple Validation for Phone Number syntax.
 * version 2 by Ray Camden - added 7 digit support
 * version 3 by Tony Petruzzi Tony_Petruzzi@sheriff.org
 * 
 * @param valueIn 	 String to check. (Required)
 * @return Returns a boolean. 
 * @author Alberto Genty (agenty@houston.rr.com) 
 * @version 3, September 24, 2002 
 */
function IsValidPhone(valueIn) {
 	var re = "^(([0-9]{3}-)|\([0-9]{3}\) ?)?[0-9]{3}-[0-9]{4}$";
 	return	ReFindNoCase(re, valueIn);
}
/**
 * Tests passed value to see if it is a properly formatted U.S. zip code.
 * 
 * @param str 	 String to be checked. (Required)
 * @return Returns a boolean. 
 * @author Jeff Guillaume (jeff@kazoomis.com) 
 * @version 1, May 8, 2002 
 */
function IsZipUS(str) {
	return REFind('^[[:digit:]]{5}(( |-)?[[:digit:]]{4})?$', str); 
}
/**
 * Creates a unique file name; used to prevent overwriting when moving or copying files from one location to another.
 * v2, bug found with dots in path, bug found by joseph
 * 
 * @param fullpath 	 Full path to file. (Required)
 * @return Returns a string. 
 * @author Marc Esher (marc.esher@cablespeed.com) 
 * @version 2, January 22, 2008 
 */
function createUniqueFileName(fullPath){
	var extension = "";
	var thePath = "";
	var newPath = arguments.fullPath;
	var counter = 0;
	
	if(listLen(fullPath,".") gte 2) extension = listLast(fullPath,".");
	thePath = listDeleteAt(fullPath,listLen(fullPath,"."),".");

	while(fileExists(newPath)){
		counter = counter+1;		
		newPath = thePath & "_" & counter & "." & extension;			
	}
	return newPath;	
}
function sebJSStringFormat(str) {
	return ReReplaceNoCase(str,"'","\'","ALL");
}
</cfscript>

<cffunction name="fixFileName" access="private" returntype="string" output="false">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="dir" type="string" required="yes">
	
	<cfset var dirdelim = CreateObject("java", "java.io.File").separator>
	<cfset var result = ReReplaceNoCase(arguments.name,"[^a-zA-Z0-9_\-\.]","_","ALL")><!--- Remove special characters from file name --->
	<cfset var path = "#dir##dirdelim##result#">
	
	<!--- If corrected file name doesn't match original, rename it --->
	<cfif arguments.name NEQ result>
		<cfset path = createUniqueFileName(path)>
		<cfset result = ListLast(path,dirdelim)>
		<cffile action="rename" source="#arguments.dir##dirdelim##arguments.name#" destination="#result#">
	</cfif>
	
	<cfreturn result>
</cffunction>
