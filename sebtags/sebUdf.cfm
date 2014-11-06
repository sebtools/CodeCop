<!---
sebUdf build 008
Steve Bryant 2004-06-01
--->
<cfscript>
cr = "
";
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
</cfscript>