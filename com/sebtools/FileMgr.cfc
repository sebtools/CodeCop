<cfcomponent displayname="File Manager">
<!--- %%Handle folders w/o write permission --->
<cffunction name="init" access="public" returntype="FileMgr" output="no" hint="I instantiate and return this object.">
	<cfargument name="UploadPath" type="string" required="yes">
	
	<cfset variables.UploadPath = arguments.UploadPath>
	<cfset variables.dirdelim = CreateObject("java", "java.io.File").separator>
	
	<cfset makedir(variables.UploadPath)>
	
	<cfreturn this>
</cffunction>

<cffunction name="deleteFile" access="public" returntype="any" output="no" hint="I delete the given file.">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="Folder" type="string" required="no">

	<cfset var destination = variables.UploadPath>
	<cfset var result = "">
	
	<cfif StructKeyExists(arguments,"Folder")>
		<cfset destination = ListAppend(destination,arguments.Folder,variables.dirdelim)>
	</cfif>
	<cfset destination = ListAppend(destination,arguments.FileName,variables.dirdelim)>
	
	<cffile action="DELETE" file="#destination#">
	
</cffunction>
<!---
 Mimics the cfdirectory, action=&quot;list&quot; command.
 Updated with final CFMX var code.
 Fixed a bug where the filter wouldn't show dirs.
 
 @param directory 	 The directory to list. (Required)
 @param filter 	 Optional filter to apply. (Optional)
 @param sort 	 Sort to apply. (Optional)
 @param recurse 	 Recursive directory list. Defaults to false. (Optional)
 @return Returns a query. 
 @author Raymond Camden (ray@camdenfamily.com) 
 @version 2, April 8, 2004 
--->
<cffunction name="directoryList" output="false" returnType="query" hint="Mimics the cfdirectory list.">
	<cfargument name="directory" type="string" required="true">
	<cfargument name="filter" type="string" required="false" default="">
	<cfargument name="sort" type="string" required="false" default="">
	<cfargument name="recurse" type="boolean" required="false" default="false">
	<!--- temp vars --->
	<cfargument name="dirInfo" type="query" required="false">
	<cfargument name="thisDir" type="query" required="false">
	
	<cfset var path = "">
    <cfset var temp = "">
	
	<cfif not recurse>
		<cfdirectory name="temp" directory="#directory#" filter="#filter#" sort="#sort#">
		<cfreturn temp>
	<cfelse>
		<!--- We loop through until done recursing drive --->
		<cfif not isDefined("dirInfo")>
			<cfset dirInfo = queryNew("attributes,datelastmodified,mode,name,size,type,directory")>
		</cfif>
		<cfset thisDir = directoryList(directory,filter,sort,false)>
		<cfif server.os.name contains "Windows">
			<cfset path = "\">
		<cfelse>
			<cfset path = "/">
		</cfif>
		<cfloop query="thisDir">
			<cfset queryAddRow(dirInfo)>
			<cfset querySetCell(dirInfo,"attributes",attributes)>
			<cfset querySetCell(dirInfo,"datelastmodified",datelastmodified)>
			<cfset querySetCell(dirInfo,"mode",mode)>
			<cfset querySetCell(dirInfo,"name",name)>
			<cfset querySetCell(dirInfo,"size",size)>
			<cfset querySetCell(dirInfo,"type",type)>
			<cfset querySetCell(dirInfo,"directory",directory)>
			<cfif type is "dir">
				<!--- go deep! --->
				<cfset directoryList(directory & path & name,filter,sort,true,dirInfo)>
			</cfif>
		</cfloop>
		<cfreturn dirInfo>
	</cfif>
</cffunction>

<cffunction name="makedir" access="public" returntype="any" output="no" hint="I make a directory (if it doesn't exist already).">
	<cfargument name="Directory" type="string" required="yes">
	
	<cfset var thisDir = "">
	<cfset var parent = "">
	
	<cfif NOT DirectoryExists(arguments.Directory)>
		<cfset parent = ListDeleteAt(arguments.Directory,ListLen(arguments.Directory,variables.dirdelim),variables.dirdelim)>
		<cfif NOT DirectoryExists(parent)>
			<cfset makedir(parent)>
		</cfif>
		<cfdirectory action="CREATE" directory="#arguments.Directory#">
	</cfif>
	
</cffunction>

<cffunction name="readFile" access="public" returntype="string" output="no" hint="I return the contents of a file.">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="Folder" type="string" required="no">
	
	<cfset var destination = variables.UploadPath>
	<cfset var result = "">
	
	<cfif StructKeyExists(arguments,"Folder")>
		<cfset destination = ListAppend(destination,arguments.Folder,variables.dirdelim)>
	</cfif>
	<cfset destination = ListAppend(destination,arguments.FileName,variables.dirdelim)>
	
	<cffile action="READ" file="#destination#" variable="result">
	
	<cfreturn result>
</cffunction>

<cffunction name="writeFile" access="public" returntype="void" output="no" hint="I save a file.">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="Contents" type="string" required="yes">
	<cfargument name="Folder" type="string" required="no">
	
	<cfset var destination = variables.UploadPath>
	
	<cfif StructKeyExists(arguments,"Folder")>
		<cfset destination = ListAppend(destination,arguments.Folder,variables.dirdelim)>
	</cfif>
	
	<!--- Make sure the folder exists --->
	<cfset makedir(destination)>
	
	<cfset destination = ListAppend(destination,arguments.FileName,variables.dirdelim)>
	
	<cffile action="WRITE" file="#destination#" output="#arguments.Contents#" addnewline="no">
	
</cffunction>

<cffunction name="uploadFile" access="public" returntype="struct" output="no" hint="I upload a file.">
	<cfargument name="FieldName" type="string" required="yes">
	<cfargument name="Folder" type="string" required="no">
	<cfargument name="NameConflict" type="string" default="Error">
	
	<cfset var destination = variables.UploadPath>
	<cfset var CFFILE = StructNew()>
	<cfset var result = StructNew()>
	
	<cfif StructKeyExists(arguments,"Folder")>
		<cfset destination = ListAppend(destination,arguments.Folder,variables.dirdelim)>
	</cfif>
	
	<!--- Make sure the folder exists --->
	<cfset makedir(destination)>
	
	<cffile action="UPLOAD" filefield="#arguments.FieldName#" destination="#destination#" nameconflict="#arguments.NameConflict#">
	<cfset result = CFFILE>
	
	<cfreturn result>
</cffunction>

</cfcomponent>