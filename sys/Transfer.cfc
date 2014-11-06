<cfcomponent displayname="Transfer">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="FileMgr" type="any" required="yes">
	<cfargument name="Packages" type="any" required="yes">
	<cfargument name="Rules" type="any" required="yes">
	<cfargument name="Severities" type="any" required="yes">
	<cfargument name="Extensions" type="any" required="yes">
	<cfargument name="Categories" type="any" required="yes">
	
	<cfset variables.FileMgr = arguments.FileMgr>
	<cfset variables.Packages = arguments.Packages>
	<cfset variables.Rules = arguments.Rules>
	<cfset variables.Severities = arguments.Severities>
	<cfset variables.Extensions = arguments.Extensions>
	<cfset variables.Categories = arguments.Categories>
	
	<cfreturn this>
</cffunction>

<cffunction name="exportPackage" access="public" returntype="string" output="no" hint="I return the xml to export the given package.">
	<cfargument name="PackageID" type="numeric" required="yes">
	
	<cfset var qPackage = variables.Packages.getPackage(arguments.PackageID)>
	<cfset var qRules = variables.Rules.getRules(arguments.PackageID)>
	<cfset var output = "">
	<cfset var qLinks = 0>

<!--- Write XML for the package (in a format this component can digest) --->
<cfsavecontent variable="output"><?xml version="1.0"?><cfoutput>
<package name="#XmlFormat(qPackage.PackageName)#"><cfloop query="qRules"><cfset qLinks = variables.Rules.getLinks(RuleID)><!--- Normally I argue against calling a method or query from without a loop, but to avoid this, I would have to write a separate query just for this purpose. --->
	<rule name="#XmlFormat(RuleName)#" severity="#XmlFormat(SeverityName)#" uuid="#XmlFormat(UUID)#" type="#XmlFormat(RuleType)#" tagname="#XmlFormat(TagName)#" regex="#XmlFormat(Regex)#" description="#XmlFormat(Description)#" allExtensions="#XmlFormat(allExtensions)#" customcode="#XmlFormat(CustomCode)#" extensions="#XmlFormat(ExtensionNames)#" category="#XmlFormat(CategoryName)#"><cfloop query="qLinks">
		<link text="#LinkText#" url="#LinkURL#"/></cfloop>
	</rule></cfloop>
</package>
</cfoutput></cfsavecontent>

	<!--- <cfset variables.FileMgr.writeFile("package-#qPackage.PackageID#.xml",output)> --->
	
	<cfreturn output>
</cffunction>

<cffunction name="importPackage" access="public" returntype="any" output="no" hint="I import a package using the given XML.">
	<cfargument name="xmlstring" type="string" required="yes">
	<cfargument name="seedonly" type="boolean" default="false">

	<cfset var XmlPackage = XmlParse(xmlstring)>
	<cfset var Package = XmlPackage.package.XmlAttributes>
	<cfset var RuleID = 0>
	<cfset var rules = ""><!--- A list of rules associated with this package --->
	<cfset var RuleData = 0><!--- data for a rule --->
	<cfset var i = 0>
	<cfset var j = 0>
	<cfset var LinkData = 0><!--- data for a link --->
	<cfset var PackageID = variables.Packages.getPackageID(package["name"])>
	
	<!--- Run import if this isn't seed only data or if the package doesn't exist --->
	<cfif NOT arguments.seedonly OR NOT PackageID>
		<!--- Loop over all of the rules --->
		<cfloop index="i" from="1" to="#ArrayLen(XmlPackage.package.rule)#" step="1">
			<!--- Save rule data --->
			<cfset RuleData = XmlPackage.package.rule[i].XmlAttributes>
			<cfset RuleData["SeverityID"] = variables.Severities.getSeverityID(RuleData.severity)>
			<cfset RuleData["RuleName"] = RuleData.name>
			<cfset RuleData["RuleType"] = RuleData.type>
			<cfset RuleData["Extensions"] = variables.Extensions.saveExtensionList(RuleData.extensions)>
			<cfset RuleData["CategoryID"] = variables.Categories.saveCategory(CategoryName=RuleData.category)>
			<!--- Save the rule. If an identical rule exists, it won't be duplicated ( due to the nature of the underlying saveRecord() ) --->
			<cfset RuleID = variables.Rules.saveRule(argumentCollection=RuleData)>
			<!--- Add this rule to the list of rules for this package --->
			<cfset rules = ListAppend(rules,RuleID)>
			<!--- Any links for this rule? --->
			<cfif StructKeyExists(XmlPackage.package.rule[i],"link")>
				<!--- Loop over all of the links for this rule --->
				<cfloop index="j" from="1" to="#ArrayLen(XmlPackage.package.rule[i])#" step="1">
					<!--- Save link data --->
					<cfset LinkData = XmlPackage.package.rule[i].link[j].XmlAttributes>
					<cfset LinkData["LinkText"] = LinkData.text>
					<cfset LinkData["LinkURL"] = LinkData.url>
					<cfset LinkData["RuleID"] = RuleID>
					<!--- Save the link --->
					<cfset variables.Rules.saveLink(argumentCollection=LinkData)>
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- Store the package data in a structure --->
		<cfset package["Rules"] = rules>
		<cfset package["PackageName"] = package["name"]>
		
		<!--- Save the package --->
		<cfset variables.Packages.savePackage(argumentCollection=package)>
	</cfif>
	
</cffunction>

<cffunction name="importPackageFile" access="public" returntype="any" output="no" hint="I import a package from a file">
	<cfargument name="PackageFile" type="string" required="yes">
	
	<cfset var FileContents = variables.FileMgr.readFile(arguments.PackageFile)>
	
	<!--- Pass the XML from the file to the importPackage method --->
	<cfset importPackage(FileContents)>
	
	<!--- The file is no longer needed, so ditch it --->
	<cfset variables.FileMgr.deleteFile(arguments.PackageFile)>
	
</cffunction>

</cfcomponent>