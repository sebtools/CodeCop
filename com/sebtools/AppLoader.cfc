

<cfcomponent displayname="Component Loader">
<cfset cr = "
">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="SysXML" type="string" required="no">
	<cfargument name="XmlFilePath" type="string" required="no">
	
	<cfset variables.instance = StructNew()>
	<cfset variables.args = StructNew()>
	
	<cfif StructKeyExists(arguments,"XmlFilePath")>
		<cfset variables.XmlFilePath = arguments.XmlFilePath>
	</cfif>
	<cfif StructKeyExists(arguments,"SysXml")>
		<cfset variables.SysXml = arguments.SysXml>
	<cfelseif StructKeyExists(arguments,"XmlFilePath")>
		<cffile action="READ" file="#variables.XmlFilePath#" variable="variables.SysXml">
		<!--- <cfif Left(variables.SysXml,5) eq "<?xml">
			<cfset variables.SysXml = ListRest(variables.SysXml,cr)>
		</cfif> --->
	</cfif>
	
	<cfreturn this>
</cffunction>

<cffunction name="setArgs" access="public" returntype="void" output="no">
	
	<cfif ArrayLen(arguments)>
		<cfset StructAppend(variables.args,arguments,true)>
	</cfif>
	
</cffunction>

<cffunction name="load" access="public" returntype="void" output="no">
	<cfargument name="SysXML" type="string" default="#variables.SysXml#">
	<cfargument name="refresh" type="string" required="yes">
	<cfargument name="prefix" type="string" default="">
	
	<cfset var Sys = XmlParse(arguments.SysXml,"no")>
	<cfset var arrComponents = Sys.site.components.component>
	<cfset var arrPostActions = ArrayNew(1)>
	<cfset var i = 0>
	<cfset var j = 0>
	<cfset var Comp = StructNew()>
	<cfset var Action = StructNew()>
	<cfset var Arg = StructNew()>
	<cfset var refreshed = "">
	
	<cfif Len(arguments.prefix) AND NOT Right(arguments.prefix,1) EQ ".">
		<cfset arguments.prefix = "#arguments.prefix#.">
	</cfif>
	
	<cfset StructAppend(variables.args, Duplicate(arguments), true)>
	
	<cfif StructKeyExists(Sys.site,"postactions") AND StructKeyExists(Sys.site.postactions,"action")>
		<cfset arrPostActions = Sys.site.postactions.action>
	</cfif>

	<!--- %%Need to check for required arguments --->
	<!--- %%Need to make sure that dependent components are loaded after the components on which the depend --->
	
	<!--- Make sure that dependent components are refreshed if the components on which they depend or refreshed --->
	<cfset arguments.refresh = recurseRefresh(arguments.SysXml,arguments.refresh)>
	
	<cfloop index="i" from="1" to="#ArrayLen(arrComponents)#" step="1">
		<cfset Comp = arrComponents[i].xmlAttributes>
		<!---  If component has name and path --->
		<cfif StructKeyExists(Comp,"name") AND StructKeyExists(Comp,"path")>
			<!---  If refresh includes this component or is true or if this component doesn't yet exist --->
			<cfif checkRefresh(Comp.name,arguments.refresh)>
				<cfinvoke method="loadComponent">
					<cfinvokeargument name="componentPath" value="#arguments.prefix##Comp.path#">
					<cfinvokeargument name="method" value="init">
					<cfif StructKeyExists(arrComponents[i],"xmlChildren") AND ArrayLen(arrComponents[i].xmlChildren)>
						<cfinvokeargument name="args" value="#arrComponents[i].xmlChildren#">
					</cfif>
					<cfinvokeargument name="returncomp" value="#comp.name#">
				</cfinvoke>
				<cfset refreshed = ListAppend(refreshed,Comp.name)>
			</cfif>
			<!--- /If refresh includes this component or is true or if this component doesn't yet exist --->
			<cfset this[Comp.name] = Application[Comp.name]>
		</cfif>
		<!--- /If component has name and path --->
	</cfloop>
	
	<cfif ArrayLen(arrPostActions)>
		<cfloop index="i" from="1" to="#ArrayLen(arrPostActions)#" step="1">
			<cfset Action = arrPostActions[i].xmlAttributes>
			<!---  If any of the onload components are being loaded --->
			<cfif StructKeyExists(Action,"onload") AND ListFindOneOf(refreshed,Action.onload)><!---  checkRefresh(Action.onload,arguments.refresh) --->
				<!--- Load the component method --->
				<cfinvoke method="loadComponent">
					<cfinvokeargument name="componentName" value="#Action.component#">
					<cfinvokeargument name="method" value="#Action.method#">
					<cfif StructKeyExists(arrPostActions[i],"xmlChildren") AND ArrayLen(arrPostActions[i].xmlChildren)>
						<cfinvokeargument name="args" value="#arrPostActions[i].xmlChildren#">
					</cfif>
				</cfinvoke>
			</cfif>
			<!--- /If any of the onload components are being loaded --->
		</cfloop>
	</cfif>
	
</cffunction>

<cffunction name="loadComponent" access="private" returntype="any" output="no">
	<cfargument name="componentName" type="any" required="no">
	<cfargument name="componentPath" type="any" required="no">
	<cfargument name="method" type="string" required="yes">
	<cfargument name="args" type="any" required="no">
	<cfargument name="returncomp" type="string" default="none">
	
	<cfset var j = 0>
	<cfset var Arg = StructNew()>
	<cfset var component = "">
	<cfset var compName = "">
	
	<cfif StructKeyExists(arguments,"componentPath")>
		<cfset component = arguments.componentPath>
		<cfset compName = arguments.componentPath>
	<cfelseif StructKeyExists(arguments,"componentName")>
		<cfset component = Application[arguments.componentName]>
		<cfset compName = arguments.componentName>
	</cfif>
	
	<!--- <cftry> --->
	
	<cfinvoke component="#component#" method="#arguments.method#" returnvariable="Application.#arguments.returncomp#">
		<cfif StructKeyExists(arguments,"args") AND ArrayLen(arguments.args)>
			<cfloop index="j" from="1" to="#ArrayLen(arguments.args)#" step="1">
				<cfset Arg = args[j].xmlAttributes>
				<!---  If argument has name and one of value,variable,component --->
				<cfif StructKeyExists(Arg,"name") AND (StructKeyExists(Arg,"value") OR StructKeyExists(Arg,"arg") OR StructKeyExists(Arg,"component"))>
					<cfif StructKeyExists(Arg,"value")>
						<cfinvokeargument name="#Arg.name#" value="#Arg.Value#">
					<cfelse>
						<cfif StructKeyExists(Arg,"component")>
							<cfinvokeargument name="#Arg.name#" value="#Application[Arg.component]#">
						<cfelseif StructKeyExists(Arg,"arg")>
							<cfinvokeargument name="#Arg.name#" value="#variables.args[Arg.arg]#">
						<cfelse>
							<cfinvokeargument name="#Arg.name#" value="#Evaluate(Arg.variable)#">
						</cfif>
					</cfif>
				</cfif>
				<!--- /If argument has name and one of value,variable,component --->
			</cfloop>
		</cfif>
	</cfinvoke>
	
	<!--- <cfcatch type="Any">
		<cfif StructKeyExists(CFCATCH,"Detail")>
			<cfthrow message="Error running #arguments.method# method of #compName#: #CFCATCH.Message#" detail="#CFCATCH.Detail#">
		<cfelse>
			<cfthrow message="Error running #arguments.method# method of #compName#: #CFCATCH.Message#">
		</cfif>
	</cfcatch>
	
	</cftry> --->
	
</cffunction>

<cffunction name="checkRefresh" access="public" returntype="boolean" output="no">
	<cfargument name="components" type="string" required="yes">
	<cfargument name="refresh" type="string" required="yes">
	
	<cfset var result = false>
	<cfset var component = "">
	
	<!--- If refresh is true, then refresh all components --->
	<cfif isBoolean(arguments.refresh) AND arguments.refresh>
		<cfset result = true>
	<cfelse>
		<!--- Otherwise, compare refresh to each component being checked - one match will do. --->
		<cfloop index="component" list="#arguments.components#">
			<!--- If refresh includes component or component doesn't exist, refresh it. --->
			<cfif ListFindNoCase(arguments.refresh,component) OR NOT StructKeyExists(Application,component)>
				<cfset result = true>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="register" access="public" returntype="any" output="no" hint="I register a component with the Component Loader.">
	<cfargument name="ComponentXML" type="string" required="yes">
	
	<cfset var xSys = XmlParse(variables.SysXml)>
	<cfset var xComponent = XmlParse(arguments.ComponentXML)>
	<cfset var xComponents = XmlSearch(xComponent,"//component")>
	
	<cfset var jj = 0>
	<cfset var ii = 0>
	<cfset var exists = false>
	<cfset var tab = "	">
	<cfset var isUpdated = false>
	
	<cfloop index="jj" from="1" to="#ArrayLen(xComponents)#" step="1">
		<cfset xComponent = xComponents[jj]>
		<cfset ComponentXML = Trim(ToString(xComponent))>
		
		<!--- Check to see if this component already exists --->
		<cfif StructKeyExists(xSys.site.components,"XmlChildren") AND ArrayLen(xSys.site.components.XmlChildren)>
			<cfloop index="ii" from="1" to="#ArrayLen(xSys.site.components.XmlChildren)#" step="1">
				<cfif xSys.site.components.XmlChildren[ii].XmlAttributes.name eq xComponent.XmlAttributes.name>
					<cfif xSys.site.components.XmlChildren[ii].XmlAttributes.path eq xComponent.XmlAttributes.path>
						<cfset exists = true>
					<cfelse>
						<cfthrow message="Another component of the same name already exists.">
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- If component doesn't exist, add it --->
		<cfif NOT exists>
			<!--- <cfset xSys.site.components = XmlAppendElem(xSys,xSys.site.components,xComponent.XmlRoot)> --->
			<!--- %%Need to check for existence of argument variables --->
			
			<cfset ComponentXML = ReplaceNoCase(ComponentXML,cr,"#cr##tab##tab#","ALL")>
			<cfset variables.SysXml = ReplaceNoCase(variables.SysXml, "</components>", "#tab##ComponentXML##cr##tab#</components>")>
			<cfset xSys = XmlParse(variables.SysXml)>
			<!--- <cfdump var="#variables.SysXml#">
			<cfabort> --->
			<cfset isUpdated = true>
		</cfif>
	</cfloop>
	
	<cfif isUpdated>
		<cfset updateXmlFile(variables.SysXml)>
		
		<cfset load(refresh=false)>
	</cfif>
	
	
	<cfreturn xSys>
</cffunction>

<cffunction name="updateXmlFile" access="public" returntype="void" output="yes">
	<cfargument name="SysXml" type="string" required="yes">
	
	<cfset var FileContent = "">
	
	<cfif isDefined("variables.XmlFilePath")>
		<cffile action="READ" file="#variables.XmlFilePath#" variable="FileContent">
		<cffile action="WRITE" file="#variables.XmlFilePath#" output="#XmlHumanReadable(SysXml)#" addnewline="No">
		<!--- <cfif isXmlDoc(FileContent)>
			<cffile action="WRITE" file="#variables.XmlFilePath#" output="#SysXml#" addnewline="No">
		<cfelse>
			<cfthrow message="I can't yet replace the XML string from within a file that isn't a pure XML document yet, sorry.">
		</cfif> --->
	</cfif>
	
</cffunction>

<cffunction name="recurseRefresh" access="private" returntype="string" output="no">
	<cfargument name="SysXML" type="string" default="#variables.SysXml#">
	<cfargument name="refresh" type="string" required="yes">
	
	<cfset var Sys = XmlParse(arguments.SysXml,"no")>
	<cfset var arrComponents = Sys.site.components.component>
	<cfset var i = 0>
	<cfset var j = 0>
	<cfset var Comp = StructNew()>
	<cfset var Arg = StructNew()>
	<cfset var result = arguments.refresh>
	
	<cfif isBoolean(arguments.refresh) AND arguments.refresh>
		<cfreturn result>
	</cfif>
	
	<cfloop index="i" from="1" to="#ArrayLen(arrComponents)#" step="1">
		<cfset Comp = arrComponents[i].xmlAttributes>
		<!---  If component has name and path --->
		<cfif StructKeyExists(Comp,"name") AND StructKeyExists(Comp,"path")>
			<!---  If this component isn't set to be refreshed --->
			<cfif NOT checkRefresh(Comp.name,arguments.refresh)>
				<cfif StructKeyExists(arrComponents[i],"XmlChildren") AND ArrayLen(arrComponents[i].xmlChildren)>
					<!---  Loop over arguments --->
					<cfloop index="j" from="1" to="#ArrayLen(arrComponents[i].XmlChildren)#" step="1">
						<cfset Arg = arrComponents[i].XmlChildren[j].XmlAttributes>
						<!---  If argument is a component that is being refreshed --->
						<cfif StructKeyExists(Arg,"Component") AND ListFindNoCase(result,Arg.Component)>
							<!--- Refresh this component --->
							<cfset result = ListAppend(result,Comp.name)>
						</cfif>
						<!--- /If argument is a component that is being refreshed --->
					</cfloop>
					<!--- /Loop over arguments --->
				</cfif>
			</cfif>
			<!--- /If this component isn't set to be refreshed --->
		</cfif>
		<!--- /If component has name and path --->
	</cfloop>
	
	<!--- If refresh list changed, check again --->
	<cfif result neq arguments.refresh>
		<cfset result = recurseRefresh(arguments.SysXml,result)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="XmlAppendElem" access="private" returntype="any" output="no">
	<cfargument name="XmlDoc">
	<cfargument name="parentnode">
	<cfargument name="newelem">
	
	<cfset var currElem = 0>
	<cfset var i = 0>
	
	<cfset ArrayAppend(parentnode.XmlChildren,XmlElemNew(XmlDoc,newelem.XmlName))>
	<cfset currElem = parentnode.XmlChildren[ArrayLen(parentnode.XmlChildren)]>
	<cfset currElem.XmlAttributes = newelem.XmlAttributes>
	
	<cfif StructKeyExists(newelem,"XmlChildren") AND ArrayLen(newelem.XmlChildren)>
		<cfloop index="i" from="1" to="#ArrayLen(newelem.XmlChildren)#" step="1">
			<cfset currElem = XmlAppendElem(XmlDoc,currElem,newelem.XmlChildren[i])>
		</cfloop>
	</cfif>
	
	<cfreturn parentnode>
</cffunction>

<!---
 returns true if one of the values in the values list is found in the list.
 
 @param list 	 List of to search. (Required)
 @param values 	 List of values to search for. (Required)
 @param delimiters 	 List delimiter. Defaults to a comma. (Optional)
 @return Returns a boolean. 
 @author Sam Curren (telegramsam@byu.edu) 
 @version 1, August 5, 2005 
--->
<cffunction name="listFindOneOf" access="private" returntype="boolean" output="false">
	<cfargument name="list" type="string" required="yes"/>
	<cfargument name="values" type="string" required="yes"/>
	<cfargument name="delimiters" type="string" required="no" default=","/>
	<cfset var value = 0/>
	<cfloop list="#arguments.values#" index="value" delimiters="#arguments.delimiters#">
		<cfif ListFind(arguments.list, value, arguments.delimiters)>
			<cfreturn true />
		</cfif>
	</cfloop>
	<cfreturn false />
</cffunction>

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
			if ( NOT ( att EQ "xmlns" AND elem.XmlAttributes[att] EQ "" ) ) {
				result = '#result# #att#="#XmlFormat(elem.XmlAttributes[att])#"';
			}
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


</cfcomponent>
