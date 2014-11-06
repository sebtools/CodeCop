<!--- Make sure no debug output on this page to screw up the display --->
<cfsetting showdebugoutput="NO">

<cfinclude template="_logic/settings.cfm">
<cfset request.CCrootpath = GetDirectoryFromPath(GetCurrentTemplatePath())>
<cfset UploadPath = ExpandPath("sys/custom/")><!--- Get the upload path --->


<!---
Take advantage of cfadmin security and functionality.
In CF7+, this gives us variables.Factory which includes the Admin API (so we can use it without knowing the username/password)
--->
<cfif isInAdmin>
	<cfinclude template="../Application.cfm">
<cfelse>
	<cfapplication name="CodeCop">
</cfif>


<!--- Used to force reload of components --->
<cfparam name="URL.reinit" default="0" type="boolean">

<!--- To handle settings not properly stored in a database. --->
<cfif URL.reinit OR NOT ( StructKeyExists(Application,"CodeCop") AND StructKeyExists(Application["CodeCop"],"SettingsMgr") )>
	<!--- So that I can use the cfapplication from the CF Admin without worrying about stomping all over variables that other programs might need. --->
	<cfset Application["CodeCop"] = StructNew()>
	<cfset Application["CodeCop"].InstallSQL = "">
	<cfset Application["CodeCop"].ConfigSite = CreateObject("component","com.sebtools.Config").init(CGI,request.CCrootpath)>
	<cfset Application["CodeCop"].ConfigApp = CreateObject("component","sys.Config_CodeCop").init()>
	
	<cfset TempDataMgr = CreateObject("component","com.sebtools.DataMgr").init("")>
	<!--- Load up the datasource manager component to get datasources and determine associated databases --->
	<cfinvoke returnvariable="Application.CodeCop.DatasourceMgr" component="sys.DatasourceMgr" method="init">
		<cfinvokeargument name="DataMgr" value="#TempDataMgr#">
		<cfif StructKeyExists(variables,"Factory")>
			<cfinvokeargument name="Factory" value="#variables.Factory#">
		</cfif>
	</cfinvoke>
	<!--- Load the settings component to handle settings for CodeCop --->
	<cfset Application["CodeCop"].SettingsMgr = CreateObject("component","sys.Settings").init(Application["CodeCop"].DatasourceMgr,ExpandPath("config.cfm"))>
</cfif>

<cfset request.Paths = Application["CodeCop"].ConfigSite.getPaths()>

<cfset SettingsData = Application["CodeCop"].SettingsMgr.getSettings()><!--- Get settings data --->

<!--- Either load the components or take the user to the settings page so they can provide the needed info. --->
<cfif NOT ListFindNoCase(CGI.SCRIPT_NAME,"install","/") AND NOT ListLast(CGI.SCRIPT_NAME,"/") EQ "about.cfm">
	<cfif Len(Trim(SettingsData.datasource)) AND Len(Trim(SettingsData.database))>
		<!--- If url indicates initialize or if CodeCop hasn't already been successfully initialized, initilize it. --->
		<cfif URL.reinit OR NOT ( StructKeyExists(Application["CodeCop"],"installed") AND isBoolean(Application["CodeCop"].installed) AND Application["CodeCop"].installed ) >
			<!--- <cfset Application["CodeCop"].DataMgr = CreateObject("component","com.sebtools.DataMgr_#SettingsData.database#").init(SettingsData.datasource)> --->
			<cfset Application["CodeCop"].DataMgr = CreateObject("component","com.sebtools.DataMgr").init(SettingsData.datasource,SettingsData.database)>
			<cfset Application["CodeCop"].FileMgr = CreateObject("component","com.sebtools.FileMgr").init(UploadPath)>
			<cftry>
				<cfset Application["CodeCop"].CodeCop = CreateObject("component","sys.CodeCop").init(Application["CodeCop"].ConfigApp,Application["CodeCop"].DataMgr,Application["CodeCop"].FileMgr,ExpandPath("default-package.xml"))>
				<cfset Application["CodeCop"].installed = true>
			<cfcatch type="CodeCop">
				<cfset Application["CodeCop"].InstallSQL = CFCATCH.Detail>
				<cfset Application["CodeCop"].installed = false>
			</cfcatch>
			</cftry>
			
			<cfif NOT Application["CodeCop"].installed>
				<cflocation url="install/" addtoken="No">
			</cfif>
		</cfif>
		<!--- <cfset Application["CodeCop"].DataMgr.startLogging()> --->
		<cfset CodeCop = Application["CodeCop"].CodeCop>
	<cfelse>
		<cflocation url="install/settings.cfm" addtoken="No">
	</cfif>
</cfif>


<!--- Universal settings for "seb" tags. Basically this sets default values for attributes --->
<cfinclude template="_logic/sebtags.cfm">


<!---
Load the layout component.
http://coldfusion.sys-con.com/read/154231.htm
I could have loaded the default and then used switchLayout(), but this is a little more efficient.
This allows CodeCop to look right in the CF6 or Cf7 admin and have a separate look when run on its own.
--->
<cfif isInAdmin>
	<cfif CFVersionFull gte 7>
		<cfset layout = CreateObject("component","layouts.CFAdmin7").init(CGI.SCRIPT_NAME,Application["CodeCop"].ConfigSite)>
	<cfelse>
		<cfset layout = CreateObject("component","layouts.CFAdmin6").init(CGI.SCRIPT_NAME,Application["CodeCop"].ConfigSite)>
	</cfif>
<cfelse>
	<cfset layout = CreateObject("component","layouts.Default").init(CGI.SCRIPT_NAME,Application["CodeCop"].ConfigSite)>
</cfif>

<!---
Switch to different format based on URL parameter
This is general functionality to allow different output modes.
--->
<cfparam name="url.format" default="HTML">
<cfscript>
switch (url.format) {
	case "Excel":
		layout = layout.switchLayout("Excel");
		break;
	case "PDF":
		layout = layout.switchLayout("PDF");
		break;
	case "Word":
		layout = layout.switchLayout("Word");
		break;
}
</cfscript>
