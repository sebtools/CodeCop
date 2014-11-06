<cfcomponent extends="tag" displayname="cfargument" hint="I am cfargument.">

<cffunction name="vtml" access="public" returntype="string" output="no">
	<cfset var vtmlXML = "">
<cfsavecontent variable="vtmlXML">
<tag name="cfargument" endtag="no">
	<tagformat indentcontents="no" nlbeforetag="1" nlaftertag="1" nlbeforecontents="0" nlaftercontents="0" />
	<attributes>
		<attrib name="name" type="Text"/>
		<attrib name="type" type="Enumerated">
			<attriboption value="any"/>
			<attriboption value="array"/>
			<attriboption value="binary"/>
			<attriboption value="boolean"/>
			<attriboption value="date"/>
			<attriboption value="guid"/>
			<attriboption value="numeric"/>
			<attriboption value="query"/>
			<attriboption value="string"/>
			<attriboption value="uuid"/>
		</attrib>
		<attrib name="default" type="Text"/>
		<attrib name="displayname" type="Text"/>
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
			Creates a parameter definition within a component definition. Defines a function argument. Used within a cffunction tag.
		</xsd:documentation>
	</xsd:annotation>

	<xsd:element name="cfargument">
		<xsd:attribute name="name" type="xsd:string" use="required">
			<xsd:annotation>
				<xsd:documentation>String; an argument name.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="type" type="xsd:string" default="any">
			<xsd:annotation>
				<xsd:documentation>String; a type name; data type of the argument.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="required" type="xsd:boolean" default="no">
			<xsd:annotation>
				<xsd:documentation>A comma-delimited list of ColdFusion security roles that can invoke the method. Only users who are logged in with the specified roles can execute the function. If this attribute is omitted, all users can invoke the method.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="default" type="xsd:default" use="optional">
			<xsd:annotation>
				<xsd:documentation>If no argument is passed, specifies a default argument value.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="displayname" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>Meaningful only for CFC method parameters. A value to be displayed when using introspection to show information about the CFC.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="hint" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>Meaningful only for CFC method parameters. Text to be displayed when using introspection to show information about the CFC. The hint attribute value follows the displayname attribute value in the parameter description line. This attribute can be useful for describing the purpose of the parameter.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
	</xsd:element>
</xsd:schema>
</cfsavecontent>
	<!--- <cfset SchemaXML = ReplaceNoCase(SchemaXML, "xsd:", "", "ALL")> --->
	<cfreturn SchemaXML>
</cffunction>

</cfcomponent>