<cfcomponent displayname="tag" output="no">

<cfset tab = "	">
<cfset cr = CreateObject("java","java.lang.System").getProperty("line.separator")>
<cfset cr = "
">

<cffunction name="init" access="public" returntype="any" output="no" hint="I instantiate and return this object.">
	
	<cfscript>
	variables.schPrefix = getSchemaPrefix();
	variables.vtm = XmlParse(vtml());
	variables.TagName = getTagName();
	variables.AttributeParams = getAttributeParams();
	variables.Attributes = StructNew();
	variables.Contents = "";
	variables.aContents = ArrayNew(1);
	variables.indent = tab;
	
	variables.settings = variables.vtm.tag.XmlAttributes;
	variables.tagformat = XmlSearch(vtm,"/tag/tagformat");
	variables.format = variables.tagformat[1].XmlAttributes;
	variables.hasEndTag = false;
	</cfscript>
	
	<cfreturn this>
</cffunction>

<cffunction name="addContents" access="public" returntype="void" output="no" hint="I add contents to this tag.">
	<cfargument name="contents" type="string" required="yes">
	
	<cfset ArrayAppend(variables.aContents,arguments.Contents)>
	
</cffunction>

<cffunction name="addTag" access="public" returntype="void" output="no" hint="I add a tag between the opening and closing tags of this element.">
	<cfargument name="tag" type="tag" required="yes">
	
	<cfset ArrayAppend(variables.aContents,arguments.tag)>
	
</cffunction>

<cffunction name="execute" access="public" returntype="string" output="no" hint="I execute this tag.">
	
	<cfset var ExecPath = GetDirectoryFromPath(GetCurrentTemplatePath())>
	<cfset var UUID = CreateUUID()>
	<cfset var result = "">
	
	<cffile action="WRITE" file="#ExecPath##UUID#.cfm" output="#write()#">
	
	<cfsavecontent variable="result"><cfinclude template="#UUID#.cfm"></cfsavecontent>
	
	<cffile action="DELETE" file="#ExecPath##UUID#.cfm">
	
	<cfreturn result>
</cffunction>

<cffunction name="getAttributeParams" access="public" returntype="struct" output="no" hint="I return a structure of possible attributes for this tag with keys indicating datatype,required and default value.">
	
	<cfset var sch = XmlParse(schema())>
	<cfset var atts = XmlSearch(sch,"//#variables.schPrefix#attribute")>
	<cfset var result = StructNew()>
	<cfset var i = 0>
	
	<cfloop index="i" from="1" to="#ArrayLen(atts)#" step="1">
		<cfif StructKeyExists(atts[i],"XmlAttributes") AND StructKeyExists(atts[i].XmlAttributes,"name")>
			<cfset result[atts[i].XmlAttributes["name"]] = atts[i].XmlAttributes>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="getAttributesList" access="public" returntype="string" output="no" hint="I return an ordered list of possible attributes.">
	
	<cfset var sch = XmlParse(schema())>
	<cfset var atts = XmlSearch(sch,"//#variables.schPrefix#attribute")>
	<cfset var result = "">
	<cfset var i = 0>
	
	<cfloop index="i" from="1" to="#ArrayLen(atts)#" step="1">
		<cfif StructKeyExists(atts[i],"XmlAttributes") AND StructKeyExists(atts[i].XmlAttributes,"name")>
			<cfset result = ListAppend(result,atts[i].XmlAttributes["name"])>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="getLinesAfterContents" access="public" returntype="numeric" output="no" hint="I get the number of lines reserved after this tag.">
	
	<cfset var result = 0>
	
	<cfif StructKeyExists(variables.format,"nlaftercontents") AND isNumeric(variables.format.nlaftercontents) AND variables.format.nlaftercontents gt 0>
		<cfset result = format.nlaftercontents>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getLinesAfterTag" access="public" returntype="numeric" output="no" hint="I get the number of lines reserved after this tag.">
	
	<cfset var result = 0>
	
	<cfif StructKeyExists(variables.format,"nlaftertag") AND isNumeric(variables.format.nlaftertag) AND variables.format.nlaftertag gt 0>
		<cfset result = format.nlaftertag>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getLinesBeforeContents" access="public" returntype="numeric" output="no" hint="I get the number of lines reserved before this tag.">
	
	<cfset var result = 0>
	
	<cfif StructKeyExists(variables.format,"nlbeforecontents") AND isNumeric(variables.format.nlbeforecontents) AND variables.format.nlbeforecontents gt 0>
		<cfset result = format.nlbeforecontents>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getLinesBeforeTag" access="public" returntype="numeric" output="no" hint="I get the number of lines reserved before this tag.">
	
	<cfset var result = 0>
	
	<cfif StructKeyExists(variables.format,"nlbeforetag") AND isNumeric(variables.format.nlbeforetag) AND variables.format.nlbeforetag gt 0>
		<cfset result = format.nlbeforetag>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getTagName" access="public" returntype="string" output="no" hint="I return the name of this tag.">
	
	<cfset var result = "Tag">
	
	<cfset result = variables.vtm.tag.XmlAttributes.name>
	
	<cfreturn result>
</cffunction>

<cffunction name="setAttribute" access="public" returntype="void" output="no" hint="I set an attribute for this tag.">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="value" type="any" required="yes">
	
	<cfset var hasAny = hasAnyAttribute()>
	<cfset var errPrefix = "The value of the '#arguments.name#' attribute must be">
	<cfset var expr = "">
	
	<!--- If this is a defined attribute of this element --->
	<cfif StructKeyExists(variables.AttributeParams,arguments.name)>
		<!--- Validate by type --->
		<cfif StructKeyExists(variables.AttributeParams[arguments.name],"type")>
			<cfset expr = ReplaceNoCase(variables.AttributeParams[arguments.name].type, variables.schPrefix, "")>
			<cfswitch expression="#expr#">
				<cfcase value="decimal">
					<cfif NOT isNumeric(arguments.value)>
						<cfthrow message="#errPrefix# a decimal numeric.">
					</cfif>
				</cfcase>
				<cfcase value="integer">
					<cfif NOT ( isNumeric(arguments.value) AND Int(arguments.value) eq arguments.value )>
						<cfthrow message="#errPrefix# an integer.">
					</cfif>
				</cfcase>
				<cfcase value="boolean">
					<cfif NOT isBoolean(arguments.value)>
						<cfthrow message="#errPrefix# a boolean value.">
					</cfif>
				</cfcase>
				<cfcase value="date">
					<cfif NOT isDate(arguments.value)>
						<cfthrow message="#errPrefix# a date.">
					</cfif>
				</cfcase>
				<!--- Add other verifications as needed --->
			</cfswitch>
		</cfif>
	<cfelse>
		<!--- If this isn't a defined attribute, then this tag must allow any attribute. --->
		<cfif NOT hasAny>
			<cfthrow message="The attribute '#arguments.name#' is not in the list of allowed attributes for #variables.TagName#.">
		</cfif>
	</cfif>
	
	<!--- If we haven't encountered any errors, set the value --->
	<cfset variables.Attributes[name] = value>
	
</cffunction>

<cffunction name="validate" access="public" returntype="struct" output="no" hint="I validate this element against the schema.">
	<cfset var result = 0>
	
	<cfif Val(Server.ColdFusion.ProductVersion) gte 7>
		<cfif Len(schema())>
			<cfset result = XmlValidate(write(), schema())>
		<cfelse>
			<cfset result = XmlValidate(write())>
		</cfif>
	<cfelse>
		<cfthrow message="validate method of tag is only available in CFMX 7 or above.">
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="write" access="public" returntype="string" output="no" hint="I write the results of this element.">
	
	<cfset var output = "">
	<cfset var att = "">
	<cfset var i = 0>
	
	<cfif StructKeyExists(settings,"endtag") AND isBoolean(settings.endtag) AND settings.endtag>
		<cfset hasEndTag = true>
	</cfif>
	
	<!--- Use vtml nlbeforetag for crs before tag --->
	<cfif StructKeyExists(format,"nlbeforetag") AND isNumeric(format.nlbeforetag) AND format.nlbeforetag gt 0>
		<cfloop index="i" from="1" to="#format.nlbeforetag#" step="1"><cfset output = cr & output></cfloop>
	</cfif>
	
	<!--- Start tag --->
	<cfset output = output & "<#variables.TagName#">
	
	<!--- Add attributes, in order --->
	<cfif NOT StructIsEmpty(variables.Attributes)>
		<cfset output = writeAttributes(output)>
	</cfif>
	
	<!--- Add closing slash if end tag is required and no contents --->
	<cfif hasEndTag AND NOT ArrayLen(variables.aContents)>
		<cfset output = output & " /">
	</cfif>
	
	<!--- Close tag --->
	<cfset output = output & ">">
	
	<!--- Add contents if exists --->
	<cfif ArrayLen(variables.aContents)>
		<!--- Add contents to output --->
		<cfset output = output & writeContents()>
		
		<!--- Close tag --->
		<cfset output = output & "</#variables.TagName#>">
	</cfif>
	
	<!--- Use vtml nlaftertag for crs after tag --->
	<cfif StructKeyExists(format,"nlaftertag") AND isNumeric(format.nlaftertag) AND format.nlaftertag gt 0>
		<cfloop index="i" from="1" to="#format.nlaftertag#" step="1"><cfset output = output & cr></cfloop>
	</cfif>
	
	<cfreturn output>
</cffunction>

<cffunction name="getSchemaPrefix" access="public" returntype="string" output="no" hint="I get the name-space prefix used in the schema.">
	<cfset var schem = schema()>
	<cfset var result = Left(schem,FindNoCase("schema",schem)-1)>
	
	<cfset result = ReplaceNoCase(result, "<", "")>
	
	<cfreturn Trim(result)>
</cffunction>

<cffunction name="countCR" access="private" returntype="numeric" output="no">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="where" type="string" required="yes">
	
	<cfset var result = 0>
	<cfset var i = 0>
	<cfset var crlen = Len(CR)>
	
	<cfif arguments.where eq "back">
		<cfset arguments.str = reverse(arguments.str)>
	</cfif>
	
	<cfloop index="i" from="1" to="#Len(str)#" step="#crlen#">
		<cfif Mid(arguments.str,i,crlen) eq cr>
			<cfset result = result + 1>
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="TrimCR" access="private" returntype="string" output="no">
	<cfargument name="str" type="string" required="yes">
	<cfargument name="where" type="string" required="yes">
	
	<cfset var result = arguments.str>
	<cfset var crlen = Len(CR)>
	<cfset var noncrs = Len(result)-(countCR(result,arguments.where)*crlen)>
	
	<cfif Len(result) AND noncrs gt 0>
		<cfif where eq "front">
			<cfset result = Right(result,noncrs)>
		</cfif>
		<cfif where eq "back">
			<cfset result = Left(result,noncrs)>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="hasAnyAttribute" access="private" returntype="boolean" output="no" hint="I indicate if the element will allow attributes other than those enumerated in the schema.">
	
	<cfset var sch = XmlParse(schema())>
	<cfset var result = false>
	
	<cfif ArrayLen(XmlSearch(sch,"//#variables.schPrefix#anyAttribute"))>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="writeAttributes" access="private" returntype="string" output="no" hint="I write the attributes of this element to the tag.">
	<cfargument name="output" type="string" required="yes">
	
	<cfset var AttList = getAttributesList()>
	<cfset var att = "">
	<cfset var hasAny = hasAnyAttribute()>
	
	<cfif NOT StructIsEmpty(variables.Attributes)>
		<!--- Add atts in order --->
		<cfloop index="att" list="#AttList#">
			<cfif StructKeyExists(variables.Attributes,att) AND Len(variables.Attributes[att])>
				<cfset output = output & ' #att#="#variables.Attributes[att]#"'>
			</cfif>
		</cfloop>
		<!--- Add all other atts if "anyAttribute" exists --->
		<cfif hasAny>
			<cfloop collection="#variables.Attributes#" item="att">
				<cfif Len(variables.Attributes[att]) AND NOT ListFindNoCase(AttList,att)>
					<cfset output = output & ' #att#="#variables.Attributes[att]#"'>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	
	<cfreturn output>
</cffunction>

<cffunction name="writeContents" access="private" returntype="string" output="no" hint="I write the text of this element to the tag.">
	
	<cfset var entry = 0>
	<cfset var result = "">
	<cfset var entries = ArrayNew(1)>
	
	<cfset var crBefore = getLinesBeforeContents()>
	<cfset var crAfter = getLinesAfterContents()>
	<cfset var minSpaces = 0>
	
	<!--- if text isn't on same line as tag, make sure each entry is on a different line --->
	<cfif crBefore OR crAfter>
		<cfset minSpaces = 1>
	</cfif>
	
	<cfif ArrayLen(variables.aContents)>
		
		<cfloop index="entry" from="1" to="#ArrayLen(variables.aContents)#" step="1">
			<cfset ArrayAppend(entries,StructNew())>
			
			<!--- We'll handle simple text different than tags --->
			<cfif isSimpleValue(variables.aContents[entry])>
				<cfset entries[entry]["text"] = variables.aContents[entry]>
				<cfset entries[entry]["minBefore"] = Max(minSpaces,countCR(variables.aContents[entry],"front"))>
				<cfset entries[entry]["minAfter"] = Max(minSpaces,countCR(variables.aContents[entry],"back"))>
			<cfelse>
				<cfset entries[entry]["text"] = variables.aContents[entry].write()>
				<cfset entries[entry]["minBefore"] = Max(minSpaces,variables.aContents[entry].getLinesBeforeTag())>
				<cfset entries[entry]["minAfter"] = Max(minSpaces,variables.aContents[entry].getLinesAfterTag())>
			</cfif>
			
			<cfset entries[entry]["text"] = TrimCR(entries[entry]["text"],"front")>
			<cfset entries[entry]["text"] = TrimCR(entries[entry]["text"],"back")>
		</cfloop>
		
		<cfset result = result & writeCRs(Max(crBefore,entries[1]["minBefore"])) & entries[1]["text"]>
		<cfloop index="entry" from="2" to="#ArrayLen(entries)#" step="1">
			<cfset result = result & writeCRs(Max(entries[DecrementValue(entry)]["minAfter"],entries[entry]["minBefore"])) & entries[entry]["text"]>
		</cfloop>
		<cfset result = result & writeCRs(Max(crAfter,entries[ArrayLen(entries)]["minAfter"]))>
		
		<!--- Indent contents if setting says to do so --->
		<cfif StructKeyExists(format,"indentcontents") AND isBoolean(format.indentcontents) AND format.indentcontents>
			<cfset result = ReplaceNoCase(result, cr, "#cr##indent#", "ALL")>
			<cfif Right(result,Len(variables.indent)) eq variables.indent>
				<cfset result = Left(result,Len(result)-Len(variables.indent))>
			</cfif>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="writeCRs" access="private" returntype="string" output="no">
	<cfargument name="num" type="numeric" required="yes">
	
	<cfset var result = "">
	<cfset var i = 0>
	
	<cfloop index="i" from="1" to="#arguments.num#" step="1">
		<cfset result = result & cr>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="schema" access="public" returntype="string" output="no" hint="I return the schema for this tag.">
	<cfset var SchemaXML = "">
<cfsavecontent variable="SchemaXML">
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<xsd:annotation>
    	<xsd:documentation>
			These instructions should be replaced with instructions for a specific tag.
		</xsd:documentation>
	</xsd:annotation>

	<xsd:element name="tag">
		<any minOccurs="1" maxOccurs="unbounded" processContents="skip" />
	</xsd:element>
	
</xsd:schema>
</cfsavecontent>
	<cfreturn SchemaXML>
</cffunction>

<cffunction name="vtml" access="public" returntype="string" output="no" hint="I return the VTML for this tag.">
	<cfset var vtmlXML = "">
<cfsavecontent variable="vtmlXML">
<tag name="tag" endtag="Yes">
	<tagformat indentcontents="yes" nlbeforetag="1" nlaftertag="1" nlbeforecontents="0" nlaftercontents="0" />
	<attributes>
		<attrib name="att" datatype="string" required="true"/>
	</attributes>
</tag>
</cfsavecontent>
	<cfreturn vtmlXML>
</cffunction>

</cfcomponent>