<cfcomponent displayname="CodeCop" output="no">
<!---
I wanted to have a single component through which to access all functionality of the CodeCop
without having all of the code in one component.
By way of a compromise, I made this component a sort of factory.
This will allow me to keep the interface the same but add or change component architecture (slightly) as I go.
Keeping in mind, of course, that any existing components and methods must continue to be supported.

In following my "A thing should be what it seems to be approach":
CodeCop seems to be a single program, so it should be one CFC.
But it is made up of multiple parts, so it should contain more than one CFC.
For me, this means on CFC as the wrapper for others.
That way it seems like one program, but I don't have to have it all in one file.
--->
<cffunction name="init" access="public" returntype="any" output="no" hint="I instantiate and return this component.">
	<cfargument name="Config" type="any" required="yes">
	<cfargument name="DataMgr" type="any" required="yes">
	<cfargument name="FileMgr" type="any" required="yes">
	<cfargument name="PackageFile" type="string" required="no">
	
	<cfset var PackageXML = "">
	
	<cfset variables.Config = arguments.Config>
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.FileMgr = arguments.FileMgr>
	<cfif StructKeyExists(arguments,"PackageFile")>
		<cfset variables.PackageFile = arguments.PackageFile>
	</cfif>
	
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cftry>
		<cfset variables.DataMgr.loadXML(variables.Config.getDbXml(),true,true)><!--- Make sure needed tables/columns exist --->
		<cfcatch type="DataMgr">
			<cfset variables.isInstalled = false>
			<cfif CFCATCH.errorcode eq "LoadFailed">
				<cfset variables.InstallSQL = CFCATCH.detail>
				<cfthrow message="Unable to install tables on database. You will need to run SQL to install on your database." type="CodeCop" detail="#CFCATCH.Detail#" errorcode="SQLInstallFailed">
			<cfelse>
				<cfrethrow>
			</cfif>
		</cfcatch>
	</cftry>
	
	<!--- <cfif variables.isInstalled> --->
		<!--- Load up all of the included components --->
		<cfscript>
		component("Severities");
		component("Rules");
		component("Packages");
		component("Links");
		component("Extensions");
		component("Categories");
		component(name="Issues",DataMgr=variables.DataMgr,Rules=this.Rules);
		component(name="Files",DataMgr=variables.DataMgr,FileMgr=variables.FileMgr);
		component(name="CodeViewer",Files=this.Files);
		component(name="Reviews",DataMgr=variables.DataMgr,FileMgr=variables.FileMgr,Extensions=this.Extensions,Rules=this.Rules,Files=this.Files,Issues=this.Issues);
		component(name="Transfer",FileMgr=variables.FileMgr,Packages=this.Packages,Rules=this.Rules,Severities=this.Severities,Extensions=this.Extensions,Categories=this.Categories);
		</cfscript>
		
		<!--- If a package is passed in, import it (this should be the default package but allows easy distribution of CodeCop with custom package) --->
		<cfif StructKeyExists(variables,"PackageFile") AND FileExists(variables.PackageFile)>
			<cffile action="READ" file="#variables.PackageFile#" variable="PackageXML">
			<cfset this.Transfer.importPackage(PackageXML,true)><!--- Import default package as seed only so that it doesn't overwrite changed data. --->
		</cfif>
		
		<!--- Perform any upgrade tasks --->
		<cfset upgrade()>
	<!--- </cfif> --->
	
	<cfreturn this>
</cffunction>

<cffunction name="runReview" access="public" returntype="numeric" output="no" hint="I am basically a facade for Reviews.runReview. I can perform other tasks based on the form as well.">
	<cfargument name="Folder" type="string" required="yes">
	<cfargument name="PackageID" type="numeric" required="yes">
	<cfargument name="allExtensions" type="string" required="no">
	<cfargument name="Extensions" type="string" default="">
	<cfargument name="MoreExtensions" type="string" default="">
	
	<cfset var result = 0>
	
	<!--- Add any new extensions to the system  --->
	<cfif Len(arguments.MoreExtensions)>
		<cfset arguments.Extensions = ListAppend(arguments.Extensions,this.Extensions.saveExtensionList(arguments.MoreExtensions))>
	</cfif>
	
	<!--- Run the actual runReview method (in the Reviews component) --->
	<cfinvoke returnvariable="result" component="#this.Reviews#" method="runReview">
		<cfinvokeargument name="Folder" value="#arguments.Folder#">
		<cfinvokeargument name="PackageID" value="#arguments.PackageID#">
		<!--- Pass in list of extensions to check if user didn't select all extensions --->
		<cfif NOT StructKeyExists(arguments,"allExtensions") OR NOT isBoolean(arguments.allExtensions) OR NOT arguments.allExtensions>
			<cfinvokeargument name="Extensions" value="#arguments.Extensions#">
		</cfif>
	</cfinvoke>
	
	<cfreturn result>
</cffunction>

<cffunction name="component" access="private" returntype="any" output="no" hint="I load a component into memory in this component.">
	<cfargument name="name" type="string" required="yes">
	
	<cfif StructCount(arguments) eq 1>
		<cfset this[arguments.name] = CreateObject("component",name).init(variables.DataMgr,variables.FileMgr)>
	<cfelse>
		<cfinvoke component="#name#" method="init" returnvariable="this.#name#" argumentCollection="#arguments#"></cfinvoke>
	</cfif>
	
</cffunction>

<cffunction name="upgrade" access="private" returntype="void" output="no" hint="I handle any tasks to upgrade this component to current version.">
	
	<cfset var qRules2Packages = 0>
	<cfset var DefaultPackageID = this["Packages"].getDefaultPackageID()>
	
	<!---
	This method will always be run on instantiation.
	It will make sure that it has everything needed for the current version to run.
	DataMgr will make sure that all of the needed tables and columns exist, but this method will handle any other tasks.
	The contents of this method may grow from version to version and may even end up calling other private functions within it.
	For example, to keep this method short I may add a private upgradeToBuild20 method and call it from here.
	--->
	
	<!--- Make sure default pack has some rules (if it doesn't, give it all rules --->
	<cfquery name="qRules2Packages" datasource="#variables.datasource#">
	SELECT	*
	FROM	chkRules2Packages
	</cfquery>
	
	<cfif NOT qRules2Packages.RecordCount>
		<cfquery name="qRules2Packages" datasource="#variables.datasource#">
		INSERT INTO	chkRules2Packages
		SELECT		RuleID,#DefaultPackageID# AS PackageID
		FROM		chkRules
		</cfquery>
	</cfif>
	
</cffunction>

</cfcomponent>