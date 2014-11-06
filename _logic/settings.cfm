<!--- Get ColdFusion version --->
<cfset CFVersionFull = SERVER.ColdFusion.ProductVersion>
<cfset CFVersionMajor = ListFirst(CFVersionFull)>

<!--- Determine if this is being run in the CF Admin --->
<cfif CGI.SCRIPT_NAME CONTAINS "/cfide/administrator/">
	<cfset isInAdmin = true>
<cfelse>
	<cfset isInAdmin = false>
</cfif>

<cfset request.ProductName = "CodeCop">

<cfscript>
/**
 * Formats an XML document for readability.
 * update by Fabio Serra to CR code
 * 
 * @param XmlDoc 	 XML document. (Required)
 * @return Returns a string. 
 * @author Steve Bryant (steve@bryantwebconsulting.com) 
 * @version 2, March 20, 2006 
 */
function xmlHumanReadable(XmlDoc) {
	var elem = "";
	var result = "";
	var tab = "	";
	var att = "";
	var i = 0;
	var temp = "";
	var cr = createObject("java","java.lang.System").getProperty("line.separator");
	
	if ( isXmlDoc(XmlDoc) ) {
		elem = XmlDoc.XmlRoot;//If this is an XML Document, use the root element
	} else if ( IsXmlElem(XmlDoc) ) {
		elem = XmlDoc;//If this is an XML Document, use it as-as
	} else if ( NOT isXmlDoc(XmlDoc) ) {
		XmlDoc = XmlParse(XmlDoc);//Otherwise, try to parse it as an XML string
		elem = XmlDoc.XmlRoot;//Then use the root of the resulting document
	}
	//Now we are just working with an XML element
	result = "<#elem.XmlName#";//start with the element name
	if ( StructKeyExists(elem,"XmlAttributes") ) {//Add any attributes
		for ( att in elem.XmlAttributes ) {
			result = '#result# #att#="#XmlFormat(elem.XmlAttributes[att])#"';
		}
	}
	if ( Len(elem.XmlText) OR (StructKeyExists(elem,"XmlChildren") AND ArrayLen(elem.XmlChildren)) ) {
		result = "#result#>#cr#";//Add a carriage return for text/nested elements
		if ( Len(Trim(elem.XmlText)) ) {//Add any text in this element
			result = "#result##tab##XmlFormat(Trim(elem.XmlText))##cr#";
		}
		if ( StructKeyExists(elem,"XmlChildren") AND ArrayLen(elem.XmlChildren) ) {
			for ( i=1; i lte ArrayLen(elem.XmlChildren); i=i+1 ) {
				temp = Trim(XmlHumanReadable(elem.XmlChildren[i]));
				temp = "#tab##ReplaceNoCase(trim(temp), cr, "#cr##tab#", "ALL")#";//indent
				result = "#result##temp##cr#";
			}//Add each nested-element (indented) by using recursive call
		}
		result = "#result#</#elem.XmlName#>";//Close element
	} else {
		result = "#result# />";//self-close if the element doesn't contain anything
	}
	
	return result;
}
</cfscript>

<cffunction name="addAdminMenu">
	
	<cfset var FilePath = ExpandPath('/CFIDE/administrator/custommenu.xml')>
	<cfset var MenuXml = "">
	<cfset var xMenu = 0>
	<cfset var aFind = 0>
	<cfset var xSubMenu = 0>
	<cfset var xMenuItem = 0>
	
	<cffile action="read" file="#FilePath#" variable="MenuXml">
	<cfset xMenu = XmlParse(MenuXml)>
	
	<cfset aFind = XmlSearch(xMenu,"/menu/submenu[@label='CodeCop']")>
	<cfif NOT ArrayLen(aFind)>
		<cfset xSubMenu = XmlElemNew(xMenu,"submenu")>
		<cfset xSubMenu.XmlAttributes["label"] = "CodeCop">
		
		<cfset ArrayAppend(xMenu.menu.XmlChildren, xSubMenu)>
		
		<cfset xMenuItem = XmlElemNew(xMenu,"menuitem")>
		<cfset xMenuItem.XmlAttributes["href"] = "CodeCop/index.cfm">
		<cfset xMenuItem.XmlAttributes["target"] = "content">
		<cfset xMenuItem.XmlText = "CodeCop">
		
		<cfset ArrayAppend(xMenu.menu.submenu[1].XmlChildren, xMenuItem)>
		
		<cffile action="write" file="#FilePath#" output="#ToString(xMenu)#">
	</cfif>
</cffunction>
