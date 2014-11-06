<cfcomponent extends="tag" displayname="cffunction" hint="I am cffunction. I am a UDF or component method.">

<cffunction name="vtml" access="public" returntype="string" output="no">
	<cfset var vtmlXML = "">
<cfsavecontent variable="vtmlXML">
<tag name="cffunction" endtag="Yes">
	<tagformat indentcontents="yes" nlbeforetag="2" nlaftertag="2" nlbeforecontents="1" nlaftercontents="1" />
	<attributes>
		<attrib name="name" type="Text"/>
		<attrib name="returntype" type="Text"/>
		<attrib name="roles" type="Text"/>
		<attrib name="access" type="Enumerated">
			<attriboption value="private"/>
			<attriboption value="package"/>
			<attriboption value="public"/>
			<attriboption value="remote"/>
		</attrib>
		<attrib name="output" type="Text"/>
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
			Defines a function that you can call in CFML. Required to defined ColdFusion component methods.
		</xsd:documentation>
	</xsd:annotation>

	<xsd:element name="cffunction">
		<xsd:attribute name="name" type="xsd:string" use="required">
			<xsd:annotation>
				<xsd:documentation>A string; a component method that is used within the cfcomponent tag.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="returntype" type="xsd:string" default="any">
			<xsd:annotation>
				<xsd:documentation>String; a type name; data type of the function return value.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="roles" type="xsd:string" default="">
			<xsd:annotation>
				<xsd:documentation>A comma-delimited list of ColdFusion security roles that can invoke the method. Only users who are logged in with the specified roles can execute the function. If this attribute is omitted, all users can invoke the method.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="access" default="public">
			<xsd:restriction base="xsd:string">
				<xsd:enumeration value="private"/>
				<xsd:enumeration value="package"/>
				<xsd:enumeration value="public"/>
				<xsd:enumeration value="remote"/>
			</xsd:restriction>
			<xsd:annotation>
				<xsd:documentation>The client security context from which the method can be invoked.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="output" type="xsd:boolean" use="optional">
			<xsd:annotation>
				<xsd:documentation>Specifies under which conditions the function can generate HTML output.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="displayname" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>Meaningful only for CFC method parameters. A value to be displayed in parentheses following the function name when using introspection to show information about the CFC.</xsd:documentation>
			</xsd:annotation>
		</xsd:attribute>
		<xsd:attribute name="hint" type="xsd:string" use="optional">
			<xsd:annotation>
				<xsd:documentation>Meaningful only for CFC method parameters. Text to be displayed when using introspection to show information about the CFC. The hint attribute value follows the syntax line in the function description.</xsd:documentation>
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