<cfcomponent displayname="Code Check Settings Manager">

<cffunction name="init" access="public" returntype="any" output="no" hint="I instantiate and return this component.">
	<cfargument name="DatasourceMgr" type="any" required="yes">
	<cfargument name="inipath" type="string" required="yes">
	
	<cfset variables.DatasourceMgr = arguments.DatasourceMgr>
	<cfset variables.inipath = arguments.inipath>
	
	<cfset variables.keys = "datasource,database,mailserver">
	
	<cfreturn this>
</cffunction>

<cffunction name="getSettings" access="public" returntype="struct" output="no" hint="I get settings from the ini file.">
	
	<cfset var SettingsData = StructNew()>
	<cfset var key = "">
	
	<cfloop index="key" list="#variables.keys#">
		<cfset SettingsData[key] = GetProfileString(variables.inipath, "Settings", key)>
	</cfloop>
	
	<cfreturn SettingsData>
</cffunction>

<cffunction name="saveSettings" access="public" returntype="void" output="no" hint="I save settings from the arguments that are passed in.">
	
	<cfset var arg = "">
	<cfset var errData = StructNew()>
	<cfset var errMessage = "">
	
	<cfif StructKeyExists(arguments,"datasource") AND NOT StructKeyExists(arguments,"database")>
		<cfset arguments.database = variables.DatasourceMgr.getDatabase(arguments.datasource)>
	</cfif>
	
	<cfloop collection="#arguments#" item="arg">
		<cfif ListFindNoCase(variables.keys,arg)>
			<cfset SetProfileString(variables.inipath, "Settings", arg, arguments[arg])>
		</cfif>
	</cfloop>
	
	<!--- Check if settings were changed --->
	<cfloop collection="#arguments#" item="arg">
		<cfif ListFindNoCase(variables.keys,arg)>
			<cfif GetProfileString(variables.inipath, "Settings", arg) neq arguments[arg]>
				<cfset errData[arg] = arguments[arg]>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- Throw error if settings weren't changed --->
	<cfif StructCount(errData)>
		<cfset errMessage = "Open config.cfm and enter the following settings:<br/>">
		<cfloop collection="#errData#" item="arg">
			<cfset errMessage = "#errMessage#<br/>#LCase(arg)#=#errData[arg]#">
		</cfloop>
		<cfset errMessage = "#errMessage#<br/><br/>The CodeCop folder and the CodeCop/sys/custom/ folder should be writable. ">
		<cfthrow message="CodeCop failed to update settings." type="CodeCop" detail="#errMessage#">
	</cfif>
	
</cffunction>

</cfcomponent>