<cfcomponent extends="cfcomponent" displayname="layout" hint="I am layout. I make a layout component.">

<cfif NOT isDefined("variables.methods")>
	<cfset variables.methods = StructNew()>
	<cfset variables.methods.other = ArrayNew(1)>
</cfif>

<cffunction name="setHead" access="public" returntype="void" output="no">
	<cfargument name="contents" type="string" default="##super.head(arguments.title)##">
	
	<cfset oHead = CreateObject("component","com.sebtools.gen.cffunction").init()>
	<cfset oTitle = CreateObject("component","com.sebtools.gen.cfargument").init()>
	
	<cfscript>
	oTitle.setAttribute("name","title");
	oTitle.setAttribute("type","string");
	oTitle.setAttribute("required",true);
	
	oHead.setAttribute("name","head");
	oHead.setAttribute("access","public");
	oHead.setAttribute("output","true");
	oHead.addTag(oTitle);
	oHead.addContents(contents);
	
	variables.methods.head = oHead;
	</cfscript>
	
</cffunction>

<cffunction name="setBody" access="public" returntype="void" output="no">
	<cfargument name="contents" type="string" default="##super.body()##">
	
	<cfset oBody = CreateObject("component","com.sebtools.gen.cffunction").init()>
	
	<cfscript>
	oBody.setAttribute("name","body");
	oBody.setAttribute("access","public");
	oBody.setAttribute("output","true");
	oBody.addContents(contents);
	
	variables.methods.body = oBody;
	</cfscript>
	
</cffunction>

<cffunction name="setEnd" access="public" returntype="void" output="no">
	<cfargument name="contents" type="string" default="##super.end()##">
	
	<cfset oEnd = CreateObject("component","com.sebtools.gen.cffunction").init()>
	
	<cfscript>
	oEnd.setAttribute("name","end");
	oEnd.setAttribute("access","public");
	oEnd.setAttribute("output","true");
	oEnd.addContents(contents);
	
	variables.methods.end = oEnd;
	</cfscript>
	
</cffunction>

<cffunction name="create" access="public" returntype="void" output="no">
	
	<cfscript>
	setAttribute("extends","layout");
	if ( NOT StructKeyExists(variables.methods,"head") ) {
		variables.methods.head = setHead();
	}
	if ( NOT StructKeyExists(variables.methods,"body") ) {
		variables.methods.body = setBody();
	}
	if ( NOT StructKeyExists(variables.methods,"end") ) {
		variables.methods.end = setEnd();
	}
	addMethod(variables.methods.head);
	addMethod(variables.methods.body);
	addMethod(variables.methods.end);
	</cfscript>
	
</cffunction>

</cfcomponent>