<cfcomponent extends="tag" displayname="cfcomponent" hint="I am cfcomponent. I am a ColdFusion component.">

<cffunction name="addMethod" access="public" returntype="void" output="no">
	<cfargument name="method" type="tag" required="Yes">
	
	<cfset super.addTag(arguments.method)>
	
</cffunction>

<cffunction name="addTag" access="public" returntype="void" output="no">
	<cfargument name="tag" type="tag" required="yes">
	
	<cfset this.addMethod(arguments.tag)>
	
</cffunction>

<cffunction name="vtml" access="public" returntype="string" output="no">
	<cfset var vtmlXML = "">
<cfsavecontent variable="vtmlXML">
<tag name="cfcomponent" endtag="Yes">
	<tagformat indentcontents="no" nlbeforetag="0" nlaftertag="0" nlbeforecontents="1" nlaftercontents="1" />
	<attributes>
		<attrib name="displayname" type="Text"/>
		<attrib name="extends" type="Text"/>
		<attrib name="output" type="Text"/>
		<attrib name="hint" type="Text"/>
	</attributes>
</tag>
</cfsavecontent>
	<cfreturn vtmlXML>
</cffunction>

<cffunction name="schema" access="public" returntype="string" output="no">
	<cfset var SchemaXML = "">
<cfsavecontent variable="SchemaXML">
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<xsd:annotation>
    	<xsd:documentation>
			Creates and defines a component object; encloses functionality that you build in CFML and enclose within cffunction tags. This tag contains one or more cffunction tags that define methods. Code within the body of this tag, other than cffunction tags, is executed when the component is instantiated.
		</xsd:documentation>
	</xsd:annotation>

	<xsd:element name="cfcomponent">
		<xsd:attribute name="displayname" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>A string to be displayed when using introspection to show information about the CFC. The information appears on the heading, following the component name.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="extends" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>Name of parent component from which to inherit methods and properties.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="output" type="xsd:boolean" use="optional">
			<xsd:annotation>
				<xsd:documentation>Specifies whether constructor code in the component can generate HTML output; does not affect output in the body of cffunction tags in the component.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="hint" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>Text to be displayed when using introspection to show information about the CFC. The hint attribute value appears below the component name heading. This attribute can be useful for describing the purpose of the parameter.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:anyAttribute/>
		<xsd:any minOccurs="1" maxOccurs="unbounded" processContents="skip"/>
	</xsd:element>
</xsd:schema>
</cfsavecontent>
	<!--- <cfset SchemaXML = ReplaceNoCase(SchemaXML, "xsd:", "", "ALL")> --->
	<cfreturn SchemaXML>
</cffunction>

</cfcomponent>