<!---
1.0 RC4 Dev 1 (Build 113)
Last Updated: 2008-11-26
Created by Steve Bryant 2004-06-01
Information: sebtools.com
Documentation:
http://www.bryantwebconsulting.com/cftags/cf_sebform.htm
---><cfsilent><cfparam name="request.isQformLoaded" type="boolean" default="false">
<cfset TagName = "cf_sebForm"><cfif NOT isDefined("ThisTag.ExecutionMode")><cfthrow message="#TagName# must be called as a custom tag" type="cftag"></cfif>
<cfif ThisTag.ExecutionMode eq "Start">
	<cfinclude template="sebUdf.cfm">
	<cfscript>
	/* || TAGINFO INITIALIZATION || */
	TagInfo = StructNew();
	TagInfo.TagName = TagName;
	TagInfo.liErrFields = "";
	fieldlist = "sebformsubmit,pkfield,sebForm_forward";
	TagInfo.arrErrors = ArrayNew(1);
	TagInfo.liQFormAPI = "allowSubmitOnError,autodetect,errorColor,librarypath,resetOnInit,showStatusMsgs,useErrorColorCoding,validateAll";
	TagInfo.liQForm = "_allowSubmitOnError,_locked,_showAlerts";
	TagInfo.liHtmlAtts = "id,class,style,title,onsubmit";
	TagInfo.liRequiredAtts = "";
	TagInfo.sValidations = StructNew();
	TagInfo.sValidations["Email"] = "^['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name|jobs|travel))$";
	TagInfo.sValidations["GUID"] = "^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$";
	TagInfo.sValidations["zipcode"] = "^[0-9]{5}(-[0-9]{4})?$";
	TagInfo.sValidations["integer"] = "^[0-9]*$";
	
	
	wysytypes = "xwysiwyg,htmlarea,xstandard";
	
	/* || ATTRIBUTES INITIALIZATION || */
	if ( NOT isDefined("request.sebFormNum") ) {
		setDefaultAtt("name","frmSebform");
		request.sebFormNum = 1;
	} else {
		request.sebFormNum = request.sebFormNum + 1;
		setDefaultAtt("name","frmSebform#request.sebFormNum#");
	}
	setDefaultAtt("formname","#attributes.name#");
	setDefaultAtt("id",attributes.formname);
	if ( NOT StructKeyExists(attributes, "config") ) {
		attributes.config = StructNew();
	}
	if ( NOT StructKeyExists(attributes.config, "Fields") ) {
		attributes.config.Fields = StructNew();
	}
	if ( NOT StructKeyExists(attributes.config, "EmailFields") ) {
		attributes.config.EmailFields = StructNew();
	}
	
	//attributes for this form (by id)
	if ( StructKeyExists(Caller, "sebFormAttributes") ) {
		StructAppend(attributes, Caller.sebFormAttributes, "no");
	}
	if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, TagInfo.TagName) AND StructKeyExists(request.cftags[TagInfo.TagName],attributes.id) ) {
		StructAppend(attributes, request.cftags[TagInfo.TagName][attributes.id], "no");
	}
	if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, TagInfo.TagName) ) {
		StructAppend(attributes, request.cftags[TagInfo.TagName], "no");
	}
	//If it exists, copy the request.cftags.cf_sebForm structure to the attributes structure (not not replace existing attributes variables)
	if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, "sebtags") ) {
		StructAppend(attributes, request.cftags["sebtags"], "no");
		if ( StructKeyExists(request.cftags["sebtags"], "config") ) {
			StructAppend(attributes.config, request.cftags["sebtags"].config, "no");
			if ( StructKeyExists(request.cftags["sebtags"].config, "Fields") ) {
				StructAppend(attributes.config.Fields, request.cftags["sebtags"].config.Fields, "no");
			}
			if ( StructKeyExists(request.cftags["sebtags"].config, "EmailFields") ) {
				StructAppend(attributes.config.EmailFields, request.cftags["sebtags"].config.EmailFields, "no");
			}
		}
	}
	setDefaultAtt("datasource");
	setDefaultAtt("query");
	/*
	if ( Len(attributes.datasource) ) {
		if ( NOT Len(attributes.query) AND NOT (isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_GetMethod")) ) {
			TagInfo.liRequiredAtts = ListAppend(TagInfo.liRequiredAtts, "dbtable");
		}
		TagInfo.liRequiredAtts = ListAppend(TagInfo.liRequiredAtts, "pkfield");
	}
	*/
	setDefaultAtt("method","post");
	//Make form fields work with post or get
	sForm = StructNew();
	if ( attributes.method NEQ "post" AND isStruct(url) ) {
		StructAppend(sForm, URL, "no");
	} else {
		StructAppend(sForm, Form, "no");
	}
	setDefaultAtt("dbtable");
	setDefaultAtt("pkfield");
	setDefaultAtt("pktype","identity"); //identity or GUID
	setDefaultAtt("email");
	setDefaultAtt("emailCC");
	setDefaultAtt("emailBCC");
	if ( Len(attributes.email) AND NOT ( isDefined("attributes.Mailer") AND isObject(attributes.Mailer) )  ) {
		TagInfo.liRequiredAtts = ListAppend(TagInfo.liRequiredAtts, "mailserver");
	}
	setDefaultAtt("mailserver");
	setDefaultAtt("subject","Form Submission");
	setDefaultAtt("emailfrom",attributes.email);
	setDefaultAtt("sendforward",true);
	/* sendback attribute defaults to sending user to whatever page they came from to get here */
	setDefaultAtt("sendback",false);
	if ( attributes.sendback ) {
		if ( StructKeyExists(sForm,"sebForm_Forward") ) {
			setDefaultAtt("forward",sForm["sebForm_Forward"]);
			StructDelete(sForm,"sebForm_Forward");
		} else if ( Len(CGI.HTTP_REFERER) ) {
			setDefaultAtt("forward",CGI.HTTP_REFERER);
		} else {
			setDefaultAtt("forward","#ListLast(CGI.Script_Name, '/')#?#CGI.Query_String#");
		}
	}
	setDefaultAtt("forward","#ListLast(CGI.Script_Name, '/')#?#CGI.Query_String#");
	if ( isDefined("url.id") ) {
		setDefaultAtt("recordid",url.id);
	} else {
		setDefaultAtt("recordid",0);
	}
	setDefaultAtt("altertable",false);
	
	for (i=1; i lte ListLen(TagInfo.liHtmlAtts); i=i+1) {
		thisAtt = ListGetAt(TagInfo.liHtmlAtts, i);
		setDefaultAtt(thisAtt);
	}
	if ( attributes.method EQ "post" ) {
		setDefaultAtt("action", "#CGI.SCRIPT_NAME#?#CGI.Query_String#");
	} else {
		setDefaultAtt("action", "#CGI.SCRIPT_NAME#");
	} 
	setDefaultAtt("enctype");
	setDefaultAtt("target");
	setDefaultAtt("librarypath","/lib/");
	setDefaultAtt("skinpath","#attributes.librarypath#skins/");
	attributes.formname = ReReplaceNoCase(attributes.formname,"[^a-zA-Z]","","ALL");
	setDefaultAtt("objname","js#attributes.formname#");
	setDefaultAtt("skin","");
	setDefaultAtt("format","");
	setDefaultAtt("emailtype","text");
	setDefaultAtt("replyto","");
	setDefaultAtt("CatchErrTypes","");
	setDefaultAtt("debug",false);
	setDefaultAtt("UploadFilePath","");
	setDefaultAtt("UploadBrowserPath","");
	setDefaultAtt("showReqMarkHint",false);
	setDefaultAtt("returnvar","sebForm");
	
	
	Caller[attributes.returnvar] = StructNew();
	Caller[attributes.returnvar].fields = StructNew();
	Caller[attributes.returnvar].sForm = sForm;
	
	/*
	if ( (Len(attributes.datasource) AND Len(attributes.dbtable)) OR (isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_GetMethod")) OR (isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_Method")) ) {
		TagInfo.liRequiredAtts = ListAppend(TagInfo.liRequiredAtts, "pkfield");
	}
	*/
	
	
	ThisTag.output = StructNew();
	
	doSQLDDL = false;
	</cfscript><!--- || CHECK FOR REQUIRED ATTRIBUTES || ---><cfif Len(TagInfo.liRequiredAtts)><cfloop index="thisReqAtt" list="#TagInfo.liRequiredAtts#"><cfif NOT Len(attributes[thisReqAtt])><cfthrow message="#thisReqAtt# is a required attribute for &lt;#TagInfo.TagName#&gt;" type="cftag"></cfif></cfloop></cfif>
	<cfinclude template="sebtools.cfm">
	<cfscript>
	//Use skins attribute for skins definitions
	if ( StructKeyExists(attributes,"skins") AND isStruct(attributes.skins) ) {
		StructAppend(sebtools.skins,attributes.skins,true);
	}
	attributes.forward = ReplaceNoCase(attributes.forward, '&amp;', '&', 'ALL');
	if ( StructKeyExists(sebtools.skins, attributes.skin) AND NOT Len(attributes.format) ) {
		attributes.format = sebtools.skins[attributes.skin].format;
	}
	if ( NOT Len(attributes.format) ) {
		attributes.format = "semantic";
	}
	// || ADJUST INCOMING ATTRIBUTES ||
	
	/* Make sure library path ends with "/" */
	if ( right(attributes.librarypath, 1) neq "/" ) {
		attributes.librarypath = attributes.librarypath & "/";
	}
	if ( Len(attributes.class) ) {
		attributes.class = "seb sebform #attributes.class#";
	} else {
		attributes.class = "seb sebform";
	}
	
	//Clean up all forms for Mac
	//FixMacPost()
	if (findNoCase("mac", cgi.HTTP_USER_AGENT) AND findNoCase("msie", cgi.HTTP_USER_AGENT)) {
		for (aField in sForm) {
			if ((len(sForm[aField]) GTE 2) AND NOT findNoCase(getTempDirectory(), sForm[aField])) {
				sForm[aField] = trim(sForm[aField]);
			}
		}
	}
	
	if ( attributes.pktype eq "GUID" AND Len(attributes.recordid) neq 36 AND NOT (isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_GetMethod")) ) {
		attributes.recordid = '';
	}
	if ( attributes.pktype eq "GUID"  ) {
		datatype = "CF_SQL_IDSTAMP";
	} else {
		datatype = "CF_SQL_INTEGER";
	}
	attributes.datatype = datatype;
	//Add any specified validations
	if ( StructKeyExists(attributes,"validations") AND isStruct(attributes.validations) ) {
		StructAppend(attributes.validations,TagInfo.sValidations,false);
	} else {
		attributes.validations = TagInfo.sValidations;
	}
	</cfscript>
	<cfif attributes.altertable and (NOT StructKeyExists(attributes,"dbtype") OR NOT Len(attributes.dbtype)) >
		<cfthrow message="You must specify a dbtype (msa,mys,sql) if you set altertable to true." type="cftag">
	</cfif>
	
	<!--- Get form defaults from component --->
	<cfif
			isDefined("attributes.CFC_Component")
		AND (
					StructKeyExists(attributes.CFC_Component,"getFieldsStruct")
				OR	getMetaData(attributes.CFC_Component).extends.name EQ "_framework.PageController"
				OR	getMetaData(attributes.CFC_Component).extends.name CONTAINS "Master"
			)
	>
		<cftry>
			<cfset sCompMeta = attributes.CFC_Component.getMetaStruct()>
			<cfif isDefined("sCompMeta") AND isStruct(sCompMeta)>
				<cfif StructKeyExists(sCompMeta,"arg_pk") AND Len(sCompMeta.arg_pk) AND NOT Len(attributes.pkfield)>
					<cfset attributes.pkfield = sCompMeta.arg_pk>
				</cfif>
				<cfif StructKeyExists(sCompMeta,"method_save") AND Len(sCompMeta.method_save) AND NOT isDefined("attributes.CFC_Method")>
					<cfset attributes.CFC_Method = sCompMeta.method_save>
				</cfif>
				<cfif StructKeyExists(sCompMeta,"method_get") AND Len(sCompMeta.method_get) AND NOT isDefined("attributes.CFC_GetMethod")>
					<cfset attributes.CFC_GetMethod = sCompMeta.method_get>
				</cfif>
				<cfif StructKeyExists(sCompMeta,"method_delete") AND Len(sCompMeta.method_delete) AND NOT isDefined("attributes.CFC_DeleteMethod")>
					<cfset attributes.CFC_DeleteMethod = sCompMeta.method_delete>
				</cfif>
				<cfif StructKeyExists(sCompMeta,"catch_types") AND Len(sCompMeta.catch_types) AND NOT ListFindNoCase(attributes.CatchErrTypes,sCompMeta.catch_types)>
					<cfset attributes.CatchErrTypes = ListAppend(attributes.CatchErrTypes,sCompMeta.catch_types)>
				</cfif>
			</cfif>
		<cfcatch>
		</cfcatch>
		</cftry>
	</cfif>
	
	<!--- Get field defaults from component --->
	<!--- <cfdump var="#getMetaData(attributes.CFC_Component)#">
	<cfabort> --->
	<cfif
			isDefined("attributes.CFC_Component")
		AND (
					StructKeyExists(attributes.CFC_Component,"getFieldsStruct")
				OR	getMetaData(attributes.CFC_Component).extends.name EQ "_framework.PageController"
				OR	getMetaData(attributes.CFC_Component).extends.name CONTAINS "Master"
			)
	>
		<cftry>
			<cfset attributes.sFields = attributes.CFC_Component.getFieldsStruct(transformer="sebField")>
			<!--- If component has getFieldStruct, make sure to catch "Master" errors --->
			<cfif NOT ListFindNoCase(attributes.CatchErrTypes,"Master")>
				<cfset attributes.CatchErrTypes = ListAppend(attributes.CatchErrTypes,"Master")>
			</cfif>
		<cfcatch>
		</cfcatch>
		</cftry>
	</cfif>
	
	<!--- || HTML CONFIGURATION || --->
	<cfset ThisTag.config = StructNew()>
	<cfset ThisTag.config.Fields = StructNew()>
	<cfset ThisTag.config.EmailFields = StructNew()>
	<cfsavecontent variable="ThisTag.config.ErrorHeader"><div class="sebform-error"><b>We're Sorry. Some information is missing or incomplete:</b><br/><br/><ul>[Errors]</ul><br/>Please try again.</div></cfsavecontent>
	<cfsavecontent variable="ThisTag.config.ErrorItem"><li>[Error]</li></cfsavecontent>
	<cfsavecontent variable="ThisTag.config.ReqMark"><span class="sebReq">*</span></cfsavecontent>
	<cfsavecontent variable="ThisTag.config.Colon">:</cfsavecontent>
	<cfif attributes.Format eq "Table">
		<cfsavecontent variable="ThisTag.config.Layout"><cfoutput><div<cfif Len(Trim(attributes.skin))> class=" sebForm-skin-#LCase(attributes.skin)#"</cfif>><div id="sebForm" class="sebFormat-table">[ErrorHeader]<form><table border="0" cellspacing="0" cellpadding="3">[Fields]</table></form></div></div></cfoutput></cfsavecontent>
		<cfsavecontent variable="ThisTag.config.Fields.all"><tr id="row-[id]"><td valign="top" class="label">{[Label][ReqMark][Colon]}</td><td valign="top">[Input]<div class="sebHelp">[Help]</div></td></tr></cfsavecontent>
	<cfelse>
		<cfsavecontent variable="ThisTag.config.Layout"><cfoutput><div<cfif Len(Trim(attributes.skin))> class=" sebForm-skin-#LCase(attributes.skin)#"</cfif>><div id="sebForm" class="sebFormat-semantic">[ErrorHeader]<form>[Fields]</form></div></div></cfoutput></cfsavecontent>
		<cfsavecontent variable="ThisTag.config.Fields.all"><div id="div-[id]">{[Label][ReqMark][Colon]}[Input]<div class="sebHelp">[Help]</div></div></cfsavecontent>
	</cfif>
	
	<cfsavecontent variable="ThisTag.config.EmailLayout">[Fields]</cfsavecontent>
	<cfif attributes.emailtype eq "html">
		<cfsavecontent variable="ThisTag.config.EmailFields.all"><cfoutput>{[label][Colon] }[value]<br/>#cr#<br/>#cr#</cfoutput></cfsavecontent>
	<cfelse>
		<cfsavecontent variable="ThisTag.config.EmailFields.all"><cfoutput>{[label][Colon] }[value]#cr##cr#</cfoutput></cfsavecontent>
	</cfif>
	<cfsavecontent variable="ThisTag.config.EmailFields.buttons"></cfsavecontent>

	<cfloop collection="#ThisTag.config#" item="thisConfig">
		<cfif isStruct(ThisTag.config[thisConfig])>
			<cfif NOT StructKeyExists(attributes.config, thisConfig)><cfset attributes.config[thisConfig] = StructNew()></cfif>
			<cfloop collection="#ThisTag.config[thisConfig]#" item="thisSubConfig">
				<cfif
						isStruct(attributes.config[thisConfig])
					AND
						(
								NOT StructKeyExists(attributes.config[thisConfig], thisSubConfig)
							OR	NOT Len(attributes.config[thisConfig][thisSubConfig])
						)
				>
					<cfset attributes.config[thisConfig][thisSubConfig] = ThisTag.config[thisConfig][thisSubConfig]>
				</cfif>
			</cfloop>
		<cfelse>
			<cfif NOT StructKeyExists(attributes.config, thisConfig) OR NOT Len(attributes.config[thisConfig])>
				<cfset attributes.config[thisConfig] = ThisTag.config[thisConfig]>
			</cfif>
		</cfif>
	</cfloop>
	<!--- Email fields key must be a struct --->
	<cfif NOT isStruct(attributes.config["EmailFields"])>
		<cfset temp = attributes.config["EmailFields"]>
		<cfset attributes.config["EmailFields"] = StructNew()>
		<cfset attributes.config["EmailFields"]["all"] = temp>
	</cfif>

	<cftry>
		<cfif Len(attributes.query) AND isQuery(Caller[attributes.query])>
			<cfset attributes.qFormData = Caller[attributes.query]>
		<cfelseif isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_GetMethod") AND Len(Trim(attributes.CFC_GetMethod))>
			<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_GetMethod#" returnvariable="attributes.qFormData">
				<cfinvokeargument name="#attributes.pkfield#" value="#attributes.recordid#">
			</cfinvoke>
		<cfelseif Len(attributes.datasource) AND Len(attributes.dbtable) AND Len(attributes.pkfield)>
			<cfquery name="attributes.qFormData" datasource="#attributes.datasource#">SELECT * FROM #attributes.dbtable# WHERE #attributes.pkfield# = <cfqueryparam value="#attributes.recordid#" cfsqltype="#datatype#"></cfquery>
		<cfelse>
			<cfset attributes.qFormData = QueryNew('sebform_none')>
		</cfif>
		<cfcatch>
			<cfif isBoolean(attributes.debug) AND attributes.debug>
				<cfrethrow>
			<cfelse>
				<cfset attributes.qFormData = QueryNew('sebform_none')>
				<cfset Caller[attributes.returnvar]["GetError"] = CFCATCH>
			</cfif>
		</cfcatch>
	</cftry>
	
	<cfif attributes.qFormData.RecordCount AND ListFindNoCase(attributes.qFormData.ColumnList,attributes.pkfield)>
		<cfset attributes.recordid = attributes.qFormData[attributes.pkfield][1]>
	</cfif>

</cfif>


<cfscript>
if ( NOT StructKeyExists(request, "cftags") ) {
	request.cftags = StructNew();
}
if ( NOT StructKeyExists(request.cftags, TagName) ) {
	request.cftags[TagName] = StructNew();
}
if ( NOT StructKeyExists(request.cftags[TagName], "attributes") ) {
	request.cftags[TagName].attributes = StructNew();
}
request.cftags[TagName].attributes = attributes;
Caller[attributes.returnvar].attributes = attributes;
ThisTag.sForm = sForm;
</cfscript>

</cfsilent><!--- || CLOSING TAG || ---><cfif ThisTag.ExecutionMode eq "End">
<!--- Default Fields if possible and none provided --->
<cfif NOT ( isDefined("ThisTag.qfields") AND ArrayLen(ThisTag.qfields) )>
	<cfset ThisTag.qfields = ArrayNew(1)>
	<cfif isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_Component.getFieldsArray")>
		<cfset aDefFields = attributes.CFC_Component.getFieldsArray('sebField')>
		<cfloop index="ii" from="1" to="#ArrayLen(aDefFields)#" step="1">
			<cfif aDefFields[ii].type EQ "pkfield">
				<cfset attributes.pkfield = aDefFields[ii].name>
			<cfelse>
				<cfset aDefFields[ii].fieldname = aDefFields[ii].name>
				<cf_sebField attributeCollection="#aDefFields[ii]#">
			</cfif>
		</cfloop>
		<cf_sebField type="submit/cancel">
	</cfif>
</cfif><cfsilent><!--- || CHECK FOR DB TABLE ALTERATION || ---><cfscript>
arrFields = ArrayNew(1);
hasFileField = false;
hasDateField = false;
liRelateTableFields = "";
UniqueFields = "";
MainHasFileField = false;
focusField = "";
//Check for table alteration
for (thisField=1; thisField lte ArrayLen(ThisTag.qfields); thisField=thisField+1 ) {
	/* Add field value to structure returned to page */
	if ( Len(ThisTag.qfields[thisField].fieldname) ) {
		Caller[attributes.returnvar]["fields"][ThisTag.qfields[thisField].fieldname] = ThisTag.qfields[thisField].value;
	}
	/* Add all dbfield except those that are for a related table (used for many-many relations) */
	if ( Len(ThisTag.qfields[thisField].dbfield) AND NOT (StructKeyExists(ThisTag.qfields[thisField],"reltable") AND Len(ThisTag.qfields[thisField].reltable)) ) {
		ArrayAppend(arrFields, ThisTag.qfields[thisField]);
		
		//If this field is not in the database, mark that a SQL DDL statement is needed
		if ( NOT ListFindNoCase(attributes.qFormData.ColumnList, ThisTag.qfields[thisField].dbfield)  ) {
			doSQLDDL = true;
		}
		
		//Set enctype correctly for type=file
		if ( ThisTag.qfields[thisField].type eq "file" ) {
			attributes.enctype = "multipart/form-data";
			hasFileField = true;
			MainHasFileField = true;
		}
		if ( StructKeyExists(ThisTag.qfields[thisField],"isunique") AND isBoolean(ThisTag.qfields[thisField].isunique) AND ThisTag.qfields[thisField].isunique ) {
			UniqueFields = ListAppend(UniqueFields,thisField);
		}
	}
	//Check for relatetables
	if ( StructKeyExists(ThisTag.qfields[thisField],"reltable") AND Len(ThisTag.qfields[thisField].reltable) ) {
		liRelateTableFields = ListAppend(liRelateTableFields,thisField);
	}
	
	//check for xdate
	if ( ThisTag.qfields[thisField].type eq "xdate" ) {
		hasDateField = true;
	}
	if ( ThisTag.qfields[thisField].type neq "hidden" AND NOT Len(focusField) ) {
		focusField = ThisTag.qfields[thisField].fieldname;
	}
}
// ^^check for subform file fields
if ( isDefined("ThisTag.subforms") ) {
	//  Loop through subforms
	for ( i=1; i lte ArrayLen(ThisTag.subforms); i=i+1 ) {
		if ( ThisTag.subforms[i].hasFileField ) {
			attributes.enctype = "multipart/form-data";
			hasFileField = true;
		}
	}
	// /Loop through subforms
}
</cfscript>
<!--- || TABLE ALTERATION || --->
<cfif attributes.altertable and doSQLDDL>
	<cfscript>
	Tables = ArrayNew(1);
	ArrayAppend(Tables, StructNew());
	Tables[ArrayLen(Tables)].TableName = attributes.dbtable;
	Tables[ArrayLen(Tables)].Fields = ArrayNew(1);
	Tables[ArrayLen(Tables)].PrimaryKey = attributes.pkfield;
	Tables[ArrayLen(Tables)].Index = "";
		ArrayAppend(Tables[ArrayLen(Tables)].Fields, StructNew());
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].ColumnName = attributes.pkfield;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].DataType = "int";
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].AllowNulls = False;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].Length = 4;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].Increment = True;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].DefaultValue = "";
	for (thisField=1; thisField lte ArrayLen(arrFields); thisField=thisField+1 ) {
		ArrayAppend(Tables[ArrayLen(Tables)].Fields, StructNew());
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].ColumnName = arrFields[thisField].dbfield;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].DataType = arrFields[thisField].dbdatatype;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].AllowNulls = True;
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].Length = arrFields[thisField].length;
		if ( arrFields[thisField].dbfield eq attributes.pkfield ) {
			Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].Increment = True;
		} else {
			Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].Increment = False;
		}
		Tables[ArrayLen(Tables)].Fields[ArrayLen(Tables[ArrayLen(Tables)].Fields)].DefaultValue = "";
	}
	</cfscript>
	<cftry>
		<cf_dbchanges datasource="#attributes.datasource#" dbtype="#attributes.dbtype#" Tables="#Tables#">
		<cfcatch><cfthrow message="&lt;#TagName#&gt;: Error running &lt;cf_dbchanges&gt;. Make sure that the tag is installed in the same directory as &lt;#TagName#&gt;" type="cftag"></cfcatch>
	</cftry>
</cfif>
<cfset Caller[attributes.returnvar]["sebFields"] = ThisTag.qfields>

<!--- || HANDLE FORM SUBMISSION || --->
<cfif isDefined("sForm.sebformsubmit") AND sForm.sebformsubmit eq Hash(attributes.formname)>
	<!--- sebformsubmit only exists to determine form submission, so it is needed after this point --->
	<cfset StructDelete(sForm,"sebformsubmit")>
	<!--- Default pkfield value --->
	<cfif NOT StructKeyExists(sForm,"pkfield")>
		<cfset sForm.pkfield = "">
	</cfif>
	
	<cfif StructKeyExists(attributes,"filter")>
		<cfif NOT isArray(attributes.filter)>
			<cfset temp = attributes.filter>
			<cfset attributes.filter = ArrayNew(1)>
			<cfset attributes.filter[1] = temp>
		</cfif>
		<cfif isArray(attributes.filter) AND ArrayLen(attributes.filter)>
			<!--- temporarily remove pkfield from form struct --->
			<cfset pkval = sForm.pkfield>
			<!--- Process filter(s) --->
			<cfloop index="ii" from="1" to="#ArrayLen(attributes.filter)#" step="1">
				<cfif isObject(attributes.filter[ii]) AND StructKeyExists(attributes.filter[ii],"filter")>
					<cftry>
						<cfset sForm = attributes.filter[ii].filter(sForm)>
					<cfcatch>
						<cfset TagInfo.isValid = false>
						<cfset ArrayAppend(TagInfo.arrErrors, "#CFCATCH.Message#")>
						<cfif StructKeyExists(CFCATCH,"ExtendedInfo") AND Len(CFCATCH.ExtendedInfo)>
							<cfset TagInfo.liErrfields = ListAppend(TagInfo.liErrfields,CFCATCH.ExtendedInfo)>
						</cfif>
					</cfcatch>
					</cftry>
				</cfif>
			</cfloop>
			<!--- put pkfield back into form struct --->
			<cfset sForm.pkfield = pkval>
		</cfif>
	</cfif>
	
	<cfscript>
	//Check for delete command
	isDeletion = false;
	/* || CHECK FOR DELETION || */
	delFieldName = "sebformDelete";
	/* Following conditional is needed so that a manual delete button can be used. */
	if ( Len(delFieldName) AND StructKeyExists(sForm, delFieldName) AND isDefined("sForm.pkfield") AND Len(sForm.pkfield) ) {
		isDeletion = true;
	}
	for (thisField=1; thisField lte ArrayLen(ThisTag.qfields); thisField=thisField+1 ) {
		if ( Len(Trim(ThisTag.qfields[thisField].fieldname)) ) {
			//make sure form field exists (mostly for checkboxes and radio buton)
			if ( NOT StructKeyExists(sForm, ThisTag.qfields[thisField].fieldname) ) {
				sForm[ThisTag.qfields[thisField].fieldname] = "";
			}
			
			if ( isNumeric(ThisTag.qfields[thisField].length) AND ThisTag.qfields[thisField].length gt 0 ) {
				if ( Len(sForm[ThisTag.qfields[thisField].fieldname]) gt ThisTag.qfields[thisField].length ) {
					sForm[ThisTag.qfields[thisField].fieldname] = Left(sForm[ThisTag.qfields[thisField].fieldname],ThisTag.qfields[thisField].length);
				}
			}
			
			//Check for delete command
			if ( StructKeyExists(sForm, ThisTag.qfields[thisField].fieldname) AND isDefined("sForm.pkfield") AND Len(sForm.pkfield) ) {
				if ( ThisTag.qfields[thisField].type eq "delete" ) {
					isDeletion = true;
				}
				if ( (ThisTag.qfields[thisField].type eq "submit/cancel/delete") AND StructKeyExists(sForm,ThisTag.qfields[thisField].fieldname) AND (sForm[ThisTag.qfields[thisField].fieldname] eq "Delete") ) {
					isDeletion = true;
				}
			}
			//Set replyto value
			if ( attributes.replyto eq ThisTag.qfields[thisField].fieldname ) {
				attributes.replyto = sForm[ThisTag.qfields[thisField].fieldname];
			}
		}
	}
	//Make sure replyto is a valid email address
	if ( Len(attributes.replyto) AND NOT isEmail(attributes.replyto) ) {
		attributes.replyto = "";
	}
	</cfscript>
	
	
	<!--- || HANDLE DELETION || --->
	<!---  If main record is being deleted --->
	<cfif isDeletion>
		<cfif isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_DeleteMethod")>
			<cfset argCollection = StructCopy(sForm)>
			<cfif Len(Trim(attributes.pkfield))>
				<cfset argCollection[attributes.pkfield] = sForm.pkfield>
			</cfif>
			<cfset StructDelete(argCollection,"pkfield")>
			<cfif isDefined("attributes.CFC_MethodArgs") AND isStruct(attributes.CFC_MethodArgs)>
				<cfloop collection="#attributes.CFC_MethodArgs#" item="key"><cfif Len(Trim(key))>
					<cfset argCollection[key] = attributes.CFC_MethodArgs[key]>
				</cfif></cfloop>
			</cfif>
			<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_DeleteMethod#" argumentcollection="#argCollection#"></cfinvoke>
		<cfelseif Len(attributes.dbtable)>
			<!---  If main record has a file field --->
			<cfif MainHasFileField>
				<!--- Delete any files when deleting record (unless 'nameconflict' is overwrite - in which case check for any record using that file first) --->
				<!---  Loop through all fields in main table --->
				<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1">
					<!---  If this is a file field, delete the file (unless it is still in use) --->
					<cfif arrFields[thisField].type eq "file">
						<cfset thisFile = arrFields[thisField].destination & arrFields[thisField].value>
						<cfif arrFields[thisField].nameconflict eq "overwrite">
							<cfquery name="sebformGetDeleteFiles" datasource="#attributes.datasource#">
							SELECT	#arrFields[thisField].dbfield#
							FROM	#attributes.dbtable#
							WHERE	#attributes.pkfield# <> <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
								AND	#arrFields[thisField].dbfield# = '#arrFields[thisField].value#'
							</cfquery>
							<cfif sebformGetDeleteFiles.RecordCount eq 0 AND FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
						<cfelse>
							<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
						</cfif>
					</cfif>
					<!--- /If this is a file field, delete the file (unless it is still in use) --->
				</cfloop>
				<!--- /Loop through all fields in main table --->
			</cfif>
			<!--- /If main record has a file field --->
			<cfquery name="qformDelete" datasource="#attributes.datasource#">
			DELETE
			FROM	#attributes.dbtable#
			WHERE	#attributes.pkfield# = <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
			</cfquery>
		</cfif>
		
		<!--- Deletions for subforms: --->
		<!---  If this form has any subforms --->
		<cfif isDefined("ThisTag.subforms")>
			<!---  Loop over each sub form --->
			<cfloop index="i" from="1" to="#ArrayLen(ThisTag.subforms)#" step="1">
				<!---  If this subform has file fields --->
				<cfif ThisTag.subforms[i].HasFileField>
					<cfquery name="qsubformselectDeleted" datasource="#attributes.datasource#">
					SELECT	*
					FROM	#ThisTag.subforms[i].tablename#
					WHERE	#ThisTag.subforms[i].fkfield# = <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
					</cfquery>
					<!--- Delete any files that are orphaned by this deletion --->
					<cfoutput query="qsubformselectDeleted">
						<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
							<cfif Len(ThisTag.subforms[i].qfields[thisField].dbfield) AND (ThisTag.subforms[i].qfields[thisField].type eq "file")>
								<cfset thisFile = ThisTag.subforms[i].qfields[thisField].destination & ThisTag.subforms[i].qfields[thisField].value>
								<cfif ThisTag.subforms[i].qfields[thisField].nameconflict eq "overwrite">
									<!--- If nameconflict is overwrite, make sure no other record is using this file --->
									<cfquery name="qsubformdeletedfile" datasource="#attributes.datasource#">
									SELECT	#ThisTag.subforms[i].qfields[thisField].dbfield#
									FROM	#ThisTag.subforms[i].tablename#
									WHERE	#ThisTag.subforms[i].fkfield# <> <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
										AND	#ThisTag.subforms[i].qfields[thisField].dbfield# = '#ThisTag.subforms[i].qfields[thisField].value#'
									</cfquery>
									<cfif qsubformdeletedfile.RecordCount>
										<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
									</cfif>
								<cfelse>
									<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
								</cfif>
							</cfif>
						</cfloop>
					</cfoutput>
					<!--- /Delete any files that are orphaned by this deletion --->
				</cfif>
				<!--- /If this subform has file fields --->
				<cfquery name="qsebformsubDelete" datasource="#attributes.datasource#">
				DELETE
				FROM	#ThisTag.subforms[i].tablename#
				WHERE	#ThisTag.subforms[i].fkfield# = <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
				</cfquery>
			</cfloop>
			<!---  Loop over each sub form --->
		</cfif>
		<!--- /If this form has any subforms --->
		<cfif attributes.sendforward><cflocation url="#attributes.forward#" addtoken="no"></cfif>
	</cfif>
	<!--- /If main record is being deleted --->
	
	
	<!--- || SERVER-SIDE VALIDATION || --->
	<cfscript>
	if ( NOT StructKeyExists(TagInfo,"isValid") ) {
		TagInfo.isValid = true;
	}
	
	
	// %% Add server-side validation for subforms?
	for (thisField=1; thisField lte ArrayLen(arrFields); thisField=thisField+1 ) {
		thisName = arrFields[thisField].fieldname;
		if ( StructKeyExists(sForm, thisName) AND Len(sForm[thisName]) ) {
			if ( arrFields[thisField].type CONTAINS "date" ) {
				if ( isDate(sForm[thisName]) ) {
					sForm[thisName] = DateFormat(sForm[thisName],"mm/dd/yyyy");
				} else {
					TagInfo.isValid = false;
					TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, thisName);
					ArrayAppend(TagInfo.arrErrors, '"#arrFields[thisField].label#" must be a valid date.');
				}
			}
			if ( ListFindNoCase("wysiwyg,FCKeditor,HTMLArea",arrFields[thisField].type) ) {
				sForm[thisName] = fixAbsoluteLinks(sForm[thisName]);
			}
			if ( arrFields[thisField].type EQ "text" AND StructKeyExists(arrFields[thisField],"stripregex") AND Len(arrFields[thisField].stripregex) ) {
				sForm[thisname] = ReReplaceNoCase(sForm[thisname],arrFields[thisField].stripregex,"","ALL");
			}
			if ( arrFields[thisField].type EQ "text" AND StructKeyExists(arrFields[thisField],"regex") AND Len(arrFields[thisField].regex) ) {
				if ( NOT ReFindNoCase(arrFields[thisField].regex,sForm[thisname]) ) {
					TagInfo.isValid = false;
					TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, thisName);
					ArrayAppend(TagInfo.arrErrors, '"#arrFields[thisField].label#" is not valid.');				
				}
			}
		} else {
			if ( arrFields[thisField].required ) {
				if ( NOT ( arrFields[thisField].type eq "file" AND (arrFields[thisField].locked OR Len(arrFields[thisField].value)) ) ) {
					TagInfo.isValid = false;
					TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, thisName);
					ArrayAppend(TagInfo.arrErrors, '"#arrFields[thisField].label#" is required.');
				}
			}
		}
		//Make sure not to update a password field if is unchanged (based on Hash)
		/*
		if ( arrFields[thisField].type eq "password" ) {
			if ( Len(arrFields[thisField].dbvalue) AND StructKeyExists(sForm, thisName) AND Trim(sForm[thisName]) eq Left(Hash(arrFields[thisField].dbvalue), Len(arrFields[thisField].dbvalue)) ) {
				sForm[thisName] = arrFields[thisField].dbvalue;
			}
		}
		*/
		
		/* Run any qform validations */
		if ( Len(arrFields[thisField].qformmethods) ) {
			/* Email Validation */
			if ( ListFindNoCase(arrFields[thisField].qformmethods, "validateEmail()", ";") OR ListFindNoCase(arrFields[thisField].qformmethods, "isEmail()", ";") ) {
				if ( NOT IsEmail(sForm[thisName]) ) {
					TagInfo.isValid = false;
					TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, thisName);
					ArrayAppend(TagInfo.arrErrors, 'Invalid #arrFields[thisField].label# address. Valid addresses are in the format user@domain.com.');
				}
			}
			/* SSN Validation */
			if ( ListFindNoCase(arrFields[thisField].qformmethods, "validateSSN()", ";") OR ListFindNoCase(arrFields[thisField].qformmethods, "isSSN()", ";") ) {
				if ( NOT IsSSN(sForm[thisName]) ) {
					TagInfo.isValid = false;
					TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, thisName);
					ArrayAppend(TagInfo.arrErrors, 'The #arrFields[thisField].label# field must include 9 digits.');
				}
			}
		}
	}
	</cfscript>
	<!--- Check for unique fields --->
	<cfif ListLen(UniqueFields) AND Len(attributes.dbtable)>
		<cfloop index="thisField" list="#UniqueFields#">
			<cfquery name="qCheckUnique" datasource="#attributes.datasource#">
			SELECT	#arrFields[thisField].dbfield#
			FROM	#attributes.dbtable#
			WHERE	#arrFields[thisField].dbfield# = 
					<cfif StructKeyExists(sForm, arrFields[thisField].fieldname) AND Len(sForm[arrFields[thisField].fieldname])>
						<cfif Len(arrFields[thisField].datatype)>
							<cfqueryparam value="#sForm[arrFields[thisField].fieldname]#" cfsqltype="#arrFields[thisField].cfdatatype#">
						<cfelseif arrFields[thisField].dbdatatype CONTAINS "date" OR arrFields[thisField].type eq "xdate">
							<cfif attributes.dbtype eq "mys">'#DateFormat(sForm[arrFields[thisField].fieldname],"yyyy-mm-dd")#'<cfelse>#CreateODBCDate(sForm[arrFields[thisField].fieldname])#</cfif>
						<cfelse>
							<cfif isNumeric(sForm[arrFields[thisField].fieldname])>#sForm[arrFields[thisField].fieldname]#<cfelse>'#sForm[arrFields[thisField].fieldname]#'</cfif>
						</cfif>
					<cfelse>
						<cfif arrFields[thisField].isnullable>
							NULL
						<cfelse>
							''
						</cfif>
					</cfif>
			</cfquery>
			<cfscript>
			if ( qCheckUnique.RecordCount ) {
				TagInfo.isValid = false;
				TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, arrFields[thisField].fieldname);
				ArrayAppend(TagInfo.arrErrors, 'The value you entered for <strong>#arrFields[thisField].label#</strong> is already in use and must be unique.');
			}
			</cfscript>
		</cfloop>
	</cfif>
	<!--- /Check for unique fields --->	
	
	
	<!--- || UPLOADS || --->
	<!---  If any file fields exist in form --->
	<cfif hasFileField>
		<!---  If main table has any file fields --->
		<cfif MainHasFileField>
			<!---  main table uploads --->
			<!---  Loop through all field in maintable --->
			<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfset thisName = arrFields[thisField].fieldname>
				<!---  If this is a file field --->
				<cfif Len(thisName) AND arrFields[thisField].type eq "file">
					<cfset thisFile = arrFields[thisField].destination & arrFields[thisField].value>
					<!--- Attempt upload --->
					<!---  If form contains uploaded file or file is manually deleted --->
					<cfif Len(attributes.dbtable) AND (isDefined("sForm.#thisName#") AND Len(sForm[thisName]) AND sForm[thisName] neq "." AND FindNoCase(getTempDirectory(), sForm[thisName])) OR (isDefined("sForm.delete#thisName#") AND sForm["delete#thisName#"])>
						<!--- Delete old file before upload --->
						<cfif arrFields[thisField].nameconflict eq "overwrite" AND Len(attributes.datasource)>
							<cfquery name="qsebformGetDeleteFile" datasource="#attributes.datasource#">
							SELECT	#arrFields[thisField].dbfield#
							FROM	#attributes.dbtable#
							WHERE	#arrFields[thisField].dbfield# = '#arrFields[thisField].value#'
								AND	#attributes.pkfield# <> <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
							</cfquery>
							<cfif qsebformGetDeleteFile.RecordCount eq 0>
								<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
							</cfif>
						<cfelse>
							<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
						</cfif>
					</cfif>
					<!---  If form contains uploaded file --->
					<cfif isDefined("sForm.#thisName#") AND Len(sForm[thisName]) AND sForm[thisName] neq "."><!---  AND FindNoCase(getTempDirectory(), sForm[thisName]) --->
						<cftry>
							<!--- Correct accept for MS Word --->
							<cfif ListFindNoCase(arrFields[thisField].accept,"application/msword") AND NOT ListFindNoCase(arrFields[thisField].accept,"application/unknown")>
								<cfset arrFields[thisField].accept = ListAppend(arrFields[thisField].accept,"application/unknown")>
							</cfif>
							<cfif ListFindNoCase(arrFields[thisField].accept,"application/msword") AND NOT ListFindNoCase(arrFields[thisField].accept,"application/octet-stream")>
								<cfset arrFields[thisField].accept = ListAppend(arrFields[thisField].accept,"application/octet-stream")>
							</cfif>
							<!--- Correct accept for MS Excel --->
							<cfif ListFindNoCase(arrFields[thisField].accept,"application/vnd.ms-excel") AND NOT ListFindNoCase(arrFields[thisField].accept,"application/octet-stream")>
								<cfset arrFields[thisField].accept = ListAppend(arrFields[thisField].accept,"application/octet-stream")>
							</cfif>
							<cftry>
								<cfif Len(arrFields[thisField].accept)>
									<cffile action="UPLOAD" filefield="#thisName#" destination="#Trim(arrFields[thisField].destination)#" nameconflict="#arrFields[thisField].nameconflict#" accept="#arrFields[thisField].accept#" mode="#arrFields[thisField].mode#">
								<cfelse>
									<cffile action="UPLOAD" filefield="#thisName#" destination="#Trim(arrFields[thisField].destination)#" nameconflict="#arrFields[thisField].nameconflict#" mode="#arrFields[thisField].mode#">
								</cfif>
							<cfcatch>
								<!--- If failed file was rejected because it is same file as being used for this record, try again with overwrite --->
								<cfif
										isDefined("attributes.qFormData")
									AND	isQuery(attributes.qFormData)
									AND	ListFindNoCase(attributes.qFormData.ColumnList,arrFields[thisField].dbfield)
									AND	CFCATCH.Message CONTAINS "File overwriting is not permitted"
									AND	CFCATCH.Detail CONTAINS attributes.qFormData[arrFields[thisField].dbfield][1]
								>
									<cfif Len(arrFields[thisField].accept)>
										<cffile action="UPLOAD" filefield="#thisName#" destination="#Trim(arrFields[thisField].destination)#" nameconflict="overwrite" accept="#arrFields[thisField].accept#" mode="#arrFields[thisField].mode#">
									<cfelse>
										<cffile action="UPLOAD" filefield="#thisName#" destination="#Trim(arrFields[thisField].destination)#" nameconflict="overwrite" mode="#arrFields[thisField].mode#">
									</cfif>
								<cfelse>
									<cfrethrow>
								</cfif>
							</cfcatch>
							</cftry>
							<cfif Len(cffile.ServerFile)>
								<cfset sForm[thisName] = fixFileName(cffile.ServerFile,Trim(arrFields[thisField].destination))>
							<cfelse>
								<!--- <cfset sForm[thisName] = arrFields[thisField].value> --->
								<cfset StructDelete(sForm,thisName)>
							</cfif>
						<cfcatch>
							<cfscript>
							//sForm[thisName] = arrFields[thisField].value;
							StructDelete(sForm,thisName);
							TagInfo.isValid = false;
							TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, thisName);
							ArrayAppend(TagInfo.arrErrors, '#arrFields[thisField].label#: #CFCATCH.Message#: #CFCATCH.Detail#');
							</cfscript>
						</cfcatch>
						</cftry>
					<cfelse>
						<cfif isDefined("sForm.delete#thisName#") AND sForm["delete#thisName#"]>
							<cfset sForm[thisName] = "">
						<cfelse>
							<cfset sForm[thisName] = arrFields[thisField].value>
						</cfif>
					</cfif>
					<!--- /If form contains uploaded file --->
				</cfif>
				<!--- /If this is a file field --->
			</cfloop>
			<!--- /Loop through all field in maintable --->
			<!--- /main table uploads --->
		</cfif>
		<!--- /If main table has any file fields --->
		<!---  subform uploads  --->
		<cfif isDefined("ThisTag.subforms")>
			<!---  Loop through subforms --->
			<cfloop index="i" from="1" to="#ArrayLen(ThisTag.subforms)#" step="1">
				<!---  If this subform has any file fields --->
				<cfif ThisTag.subforms[i].HasFileField>
					<!---  If this record has existing entries for this subform --->
					<cfif ThisTag.subforms[i].qsubdata_RecordCount>
						<!---  Loop through all records in subform --->
						<cfloop index="j" from="1" to="#ThisTag.subforms[i].qsubdata_RecordCount#" step="1">
							<cfset RecordID = ThisTag.subforms[i].qsubdata[ThisTag.subforms[i].pkfield][j]>
							<cfset prefix = "#ThisTag.subforms[i].prefix#e#RecordID#_">
							<!---  Loop through fields --->
							<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
								<!---  Only handle file fields --->
								<cfif Len(ThisTag.subforms[i].qfields[thisField].fieldname) AND ThisTag.subforms[i].qfields[thisField].type eq "file">
									<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
									<!--- If file is uploaded for this field or file is manually delete --->
									<cfif ( Len(sForm[FormFieldName]) AND sForm[FormFieldName] neq "." AND FindNoCase(getTempDirectory(), sForm[FormFieldName]) ) OR (isDefined("sForm.delete#FormFieldName#") AND sForm["delete#FormFieldName#"])>
										<cfif Len(sForm[FormFieldName]) AND sForm[FormFieldName] neq "." AND FindNoCase(getTempDirectory(), sForm[FormFieldName])>
											<cfset thisFile = ThisTag.subforms[i].qfields[thisField].destination & sForm[FormFieldName]>
										<cfelse>
											<cfset thisFile = ThisTag.subforms[i].qfields[thisField].destination & ThisTag.subforms[i].qsubdata[ThisTag.subforms[i].qfields[thisField].dbfield][j]>
										</cfif>
										
										<!--- Delete unused file if it is being removed or updated --->
										<cfif ThisTag.subforms[i].qfields[thisField].nameconflict eq "overwrite">
											<cfquery name="qsebformGetDeleteFile" datasource="#attributes.datasource#">
											SELECT	#ThisTag.subforms[i].qfields[thisField].dbfield#
											FROM	#ThisTag.subforms[i].tablename#
											WHERE	#ThisTag.subforms[i].pkfield# <> <cfqueryparam value="#RecordID#" cfsqltype="#datatype#">
												AND	#ThisTag.subforms[i].qfields[thisField].dbfield# = '#ThisTag.subforms[i].qfields[thisField].value#'
											</cfquery>
											<cfif qsebformGetDeleteFile.RecordCount eq 0>
												<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
											</cfif>
										<cfelse>
											<cfif FileExists(thisFile)><cffile action="DELETE" file="#thisFile#"></cfif>
										</cfif>
									</cfif>
									<!--- If file is uploaded for this field --->
									<cfif Len(sForm[FormFieldName]) AND sForm[FormFieldName] neq "." AND FindNoCase(getTempDirectory(), sForm[FormFieldName])>
										<cftry>
											<cfif ListFindNoCase(ThisTag.subforms[i].qfields[thisField].accept,"application/msword") AND NOT ListFindNoCase(ThisTag.subforms[i].qfields[thisField].accept,"application/unknown")>
												<cfset arrFields[thisField].accept = ListAppend(arrFields[thisField].accept,"application/unknown")>
											</cfif>
											<cffile action="UPLOAD" filefield="#FormFieldName#" destination="#ThisTag.subforms[i].qfields[thisField].destination#" nameconflict="#ThisTag.subforms[i].qfields[thisField].nameconflict#" accept="#ThisTag.subforms[i].qfields[thisField].accept#" mode="#ThisTag.subforms[i].qfields[thisField].mode#">
											<cfset sForm[FormFieldName] = cffile.ServerFile>				
										<cfcatch>
											<cfscript>
											sForm[thisName] = "";
											TagInfo.isValid = false;
											TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, FormFieldName);
											ArrayAppend(TagInfo.arrErrors, '#ThisTag.subforms[i].qfields[thisField].label#: #CFCATCH.Message#: #CFCATCH.Detail#');
											</cfscript>
										</cfcatch>
										</cftry>
									<cfelse>
										<!--- If no form field is passed, set it to the value in the database (if one exists) --->
										<cfscript>
										if ( isDefined("sForm.delete#FormFieldName#") AND sForm["delete#FormFieldName#"] ) {
											sForm[FormFieldName] = "";
										} else {
											if ( Len(ThisTag.subforms[i].qfields[thisField].dbfield) AND ListFindNoCase(ThisTag.subforms[i].qsubdata_ColumnList, ThisTag.subforms[i].qfields[thisField].dbfield) ) {
												sForm[FormFieldName] = ThisTag.subforms[i].qsubdata[ThisTag.subforms[i].qfields[thisField].dbfield][j];
											}										
										}
										</cfscript>
									</cfif>
								</cfif>
								<!--- /Only handle file fields --->
							</cfloop>
							<!---  Loop through fields --->
						</cfloop>
						<!--- /Loop through all records in subform --->
					</cfif>
					<!--- /If this record has existing entries for this subform --->				
					<!---  If records can be added to this subform --->
					<cfif ThisTag.subforms[i].addrows gt 0>
						<!---  Loop through all potential new rows --->
						<cfloop index="j" from="1" to="#ThisTag.subforms[i].addrows#" step="1">
							<cfset prefix = "#ThisTag.subforms[i].prefix#a#j#_">
							<!---  Loop through fields --->
							<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
								<!---  Only handle file fields --->
								<cfif Len(ThisTag.subforms[i].qfields[thisField].fieldname) AND ThisTag.subforms[i].qfields[thisField].type eq "file">
									<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
									<!--- If file is uploaded for this field --->
									<cfif Len(sForm[FormFieldName]) AND sForm[FormFieldName] neq "." AND FindNoCase(getTempDirectory(), sForm[FormFieldName])>
										<cfset thisFile = ThisTag.subforms[i].qfields[thisField].destination & sForm[FormFieldName]>
										<cfif ListFindNoCase(ThisTag.subforms[i].qfields[thisField].accept,"application/msword") AND NOT ListFindNoCase(ThisTag.subforms[i].qfields[thisField].accept,"application/unknown")>
											<cfset arrFields[thisField].accept = ListAppend(arrFields[thisField].accept,"application/unknown")>
										</cfif>
										<cftry>
											<cffile action="UPLOAD" filefield="#FormFieldName#" destination="#ThisTag.subforms[i].qfields[thisField].destination#" nameconflict="#ThisTag.subforms[i].qfields[thisField].nameconflict#" accept="#ThisTag.subforms[i].qfields[thisField].accept#" mode="#ThisTag.subforms[i].qfields[thisField].mode#">
											<cfset sForm[FormFieldName] = cffile.ServerFile>				
										<cfcatch>
											<cfscript>
											sForm[thisName] = "";
											TagInfo.isValid = false;
											TagInfo.liErrFields = ListAppend(TagInfo.liErrFields, FormFieldName);
											ArrayAppend(TagInfo.arrErrors, '#ThisTag.subforms[i].qfields[thisField].label#: #CFCATCH.Message#: #CFCATCH.Detail#');
											</cfscript>
										</cfcatch>
										</cftry>
									<cfelse><!--- If no form field is being uploaded, set the value of the form to empty --->
										<cfset sForm[FormFieldName] = "">
									</cfif>
								</cfif>
								<!--- /Only handle file fields --->
							</cfloop>
							<!---  Loop through fields --->
						</cfloop>
						<!--- /Loop through all potential new rows --->
					</cfif>
					<!--- /If records can be added to this subform --->
				</cfif>
				<!--- /If this subform has any file fields --->
			</cfloop>
			<!--- /Loop through subforms --->
		</cfif>
		<!--- /subform uploads  --->
	</cfif>
	<!---  If any file fields exist in form --->
	
	
	
	<!--- || HANDLE INSERT/UPDATE || --->
	<cftry>
		<!---  If validation passes, add/edit data --->
		<cfif TagInfo.isValid>
			<cfif isDefined("attributes.CFC_Component") AND isDefined("attributes.CFC_Method")>
				<cfset argCollection = Duplicate(sForm)>
				<!--- Handle subforms --->
				<cfif isDefined("ThisTag.subforms")>
					<!---  Loop through all subforms --->
					<cfloop index="i" from="1" to="#ArrayLen(ThisTag.subforms)#" step="1">
						<cfset aSubFormData = ArrayNew(1)>
						<!---  If subform has records --->
						<cfif ThisTag.subforms[i].qsubdata_RecordCount>
							<!---  Loop through all existing records in subform --->
							<cfloop index="j" from="1" to="#ThisTag.subforms[i].qsubdata_RecordCount#" step="1">
								<cfset CurrRecordID = ThisTag.subforms[i].qsubdata[ThisTag.subforms[i].pkfield][j]>
								<cfset prefix = "#ThisTag.subforms[i].prefix#e#CurrRecordID#_">
								
								<cfset ArrayAppend(aSubFormData,StructNew())>
								
								<cfset isDeletion = true>
								
								<cfset aSubFormData[Arraylen(aSubFormData)][ThisTag.subforms[i].pkfield] = CurrRecordID>
								<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
									<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
									<cfset aSubFormData[Arraylen(aSubFormData)][ThisTag.subforms[i].qfields[thisField].dbfield] = sForm[FormFieldName]>
									<cfif Len(Trim(sForm[FormFieldName]))>
										<cfset isDeletion = false>
									</cfif>
									<cfset StructDelete(argCollection,FormFieldName)>
									<cfset StructDelete(argCollection,"#FormFieldName#_countdown")>
								</cfloop>
								<cfif isDeletion AND StructKeyExists(ThisTag.subforms[i],"CFC_DeleteMethod")>
									<!--- <cfdump var="#aSubFormData[Arraylen(aSubFormData)]#"><cfabort> --->
									<cfif StructKeyExists(ThisTag.subforms[i],"CFC_Component") AND isObject(ThisTag.subforms[i]["CFC_Component"])>
										<cfinvoke component="#ThisTag.subforms[i].CFC_Component#" method="#ThisTag.subforms[i].CFC_DeleteMethod#" argumentcollection="#aSubFormData[ArrayLen(aSubFormData)]#"></cfinvoke>
									<cfelse>
										<cfinvoke component="#attributes.CFC_Component#" method="#ThisTag.subforms[i].CFC_DeleteMethod#" argumentcollection="#aSubFormData[ArrayLen(aSubFormData)]#"></cfinvoke>
									</cfif>
									<cfset ArrayDeleteAt(aSubFormData,Arraylen(aSubFormData))>
								</cfif>
							</cfloop>
						</cfif>
						
						<!--- If subform can add records --->
						<cfif ThisTag.subforms[i].addrows>
							<!---  Loop over all possible new entries for subforms --->
							<cfloop index="j" from="1" to="#ThisTag.subforms[i].addrows#" step="1">
								<cfset prefix = "#ThisTag.subforms[i].prefix#a#j#_">
								<!--- /Check for populated fields (new record) --->
								<cfset isNewRecord = false>
								<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
									<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
									<cfif StructKeyExists(sForm,FormFieldName) AND Len(sForm[FormFieldName]) AND (sForm[FormFieldName] neq ThisTag.subforms[i].qfields[thisField].defaultvalue)>
										<cfset isNewRecord = true>
									</cfif>
								</cfloop>
								<!--- /Check for populated fields (new record) --->
								<!---  If this is a new record --->
								<cfif isNewRecord>
									<cfset ArrayAppend(aSubFormData,StructNew())>
									<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
										<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
										<cfset aSubFormData[Arraylen(aSubFormData)][ThisTag.subforms[i].qfields[thisField].dbfield] = sForm[FormFieldName]>
										<cfset StructDelete(argCollection,FormFieldName)>
										<cfset StructDelete(argCollection,"#FormFieldName#_countdown")>
									</cfloop>
								<cfelse>
									<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
										<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
										<cfset StructDelete(argCollection,FormFieldName)>
										<cfset StructDelete(argCollection,"#FormFieldName#_countdown")>
									</cfloop>
								</cfif>
								<!--- /If this is a new record --->
							</cfloop>
							<!--- /Loop over all possible new entries for subform --->
						</cfif>
						<!--- /Insert new records into subform --->
						<cfif StructKeyExists(ThisTag.subforms[i],"fieldname")>
							<cfset argCollection[ThisTag.subforms[i].fieldname] = Duplicate(aSubFormData)>
						<cfelse>
							<cfset ThisTag.subforms[i].aSubFormData = Duplicate(aSubFormData)>
						</cfif>
					</cfloop>
				</cfif>
				<!--- <cfloop collection="#sForm#" item="field">
					<cfif Len(Trim(sForm[field]))>
						<cfset argCollection[field] = sForm[field]>
					</cfif>
				</cfloop> --->
				<cfif isDefined("attributes.CFC_MethodArgs") AND isStruct(attributes.CFC_MethodArgs)>
					<cfloop collection="#attributes.CFC_MethodArgs#" item="key"><cfif Len(Trim(key))>
						<cfset argCollection[key] = attributes.CFC_MethodArgs[key]>
					</cfif></cfloop>
				</cfif>
				<cfif StructKeyExists(sForm,"pkfield") AND Len(Trim(sForm.pkfield))>
					<cfset argCollection[attributes.pkfield] = sForm.pkfield>
				</cfif>
				<cfset StructDelete(argCollection,"pkfield")>
				<!--- Perform CFC Method --->
				<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_Method#" argumentcollection="#argCollection#" returnvariable="CFC_Result"></cfinvoke>
				<!--- Perform CFC Methods for sub forms --->
				<cfif isDefined("ThisTag.subforms")>
					<cfloop index="i" from="1" to="#ArrayLen(ThisTag.subforms)#" step="1">
						<cfif StructKeyExists(ThisTag.subforms[i],"CFC_Method") AND StructKeyExists(ThisTag.subforms[i],"aSubFormData") AND ArrayLen(ThisTag.subforms[i].aSubFormData)>
							<cfloop index="j" from="1" to="#ArrayLen(ThisTag.subforms[i].aSubFormData)#" step="1">
								<cfset argCollection = Duplicate(ThisTag.subforms[i].aSubFormData[j])>
								<cfif StructKeyExists(ThisTag.subforms[i],"fkfield")>
									<cfif isDefined("CFC_Result")>
										<cfset argCollection[ThisTag.subforms[i].fkfield] = CFC_Result>	
									<cfelseif StructKeyExists(sForm,"pkfield") AND Len(sForm.pkfield)>
										<cfset argCollection[ThisTag.subforms[i].fkfield] = sForm.pkfield>
									</cfif>
								</cfif>
								<cfif StructKeyExists(ThisTag.subforms[i],"CFC_Component") AND isObject(ThisTag.subforms[i]["CFC_Component"])>
									<cfinvoke component="#ThisTag.subforms[i].CFC_Component#" method="#ThisTag.subforms[i].CFC_Method#" argumentcollection="#argCollection#"></cfinvoke>
								<cfelse>
									<cfinvoke component="#attributes.CFC_Component#" method="#ThisTag.subforms[i].CFC_Method#" argumentcollection="#argCollection#"></cfinvoke>
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
				</cfif>
				<!--- So that result from CFC can be passed to next page. %%Need to add to docs --->
				<cfif isDefined("CFC_Result") AND Len(CFC_Result) AND attributes.forward CONTAINS "{result}">
					<cfset attributes.forward = ReplaceNoCase(attributes.forward, "{result}", CFC_Result, "ALL")>
				</cfif>
				<cfif attributes.sendforward><cflocation url="#attributes.forward#" addtoken="no"></cfif>
			<cfelse>
				<!--- If datasource has a value, then update the database --->
				<cfif Len(attributes.datasource) AND Len(attributes.dbtable)>
					<!---  Main table updates/inserts --->
					<cfif Len(sForm.pkfield)>
						<!--- Edit data --->
						<cfquery name="qsebformUpdate" datasource="#attributes.datasource#">
						UPDATE	#attributes.dbtable#
						SET		<cfset fieldcount = 0>
						<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfif NOT Len(arrFields[thisField].reltable)>
							<cfif NOT arrFields[thisField].locked>
								<cfset fieldcount = fieldcount + 1>
								<cfif fieldcount gt 1>,</cfif>
								<cfset thisName = arrFields[thisField].fieldname>
								#arrFields[thisField].dbfield# =
								<cfif StructKeyExists(sForm, arrFields[thisField].fieldname) AND Len(sForm[arrFields[thisField].fieldname])>
									<cfif Len(arrFields[thisField].cfdatatype)>
										<cfqueryparam value="#sForm[arrFields[thisField].fieldname]#" cfsqltype="#arrFields[thisField].cfdatatype#">
									<cfelseif arrFields[thisField].dbdatatype CONTAINS "date" OR arrFields[thisField].type eq "xdate">
										<cfif attributes.dbtype eq "mys">'#DateFormat(sForm[arrFields[thisField].fieldname],"yyyy-mm-dd")#'<cfelse>#CreateODBCDate(sForm[arrFields[thisField].fieldname])#</cfif>
									<cfelse>
										<cfif isNumeric(sForm[arrFields[thisField].fieldname])>#sForm[arrFields[thisField].fieldname]#<cfelse>'#sForm[arrFields[thisField].fieldname]#'</cfif>
									</cfif>
								<cfelse>
									<cfif arrFields[thisField].isnullable>
										NULL
									<cfelse>
										''
									</cfif>
								</cfif>
								<!--- <cfif thisField lt ArrayLen(arrFields)>,</cfif> --->
							</cfif>
						</cfif></cfloop>
						WHERE	#attributes.pkfield# = <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
						</cfquery>
					<cfelse>
						<!--- Add data --->
						<!--- Use identity/autonumber or generate next key --->
						<cfquery name="qsebformInsert" datasource="#attributes.datasource#">
						INSERT INTO #attributes.dbtable#(
						<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfset thisName = arrFields[thisField].fieldname>
							#arrFields[thisField].dbfield#<cfif thisField lt ArrayLen(arrFields)>,</cfif>
						</cfloop>
						)
						VALUES(
						<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfset thisName = arrFields[thisField].fieldname><cfparam name="sForm.#thisName#" default="">
							<cfif Len(sForm[arrFields[thisField].fieldname])>
								<cfif Len(arrFields[thisField].cfdatatype)>
									<cfqueryparam value="#sForm[arrFields[thisField].fieldname]#" cfsqltype="#arrFields[thisField].cfdatatype#">
								<cfelseif arrFields[thisField].dbdatatype CONTAINS "date" OR arrFields[thisField].type eq "xdate">
									<cfif attributes.dbtype eq "mys">'#DateFormat(sForm[arrFields[thisField].fieldname],"yyyy-mm-dd")#'<cfelse>#CreateODBCDate(sForm[arrFields[thisField].fieldname])#</cfif>
								<cfelse>
									<cfif isNumeric(sForm[arrFields[thisField].fieldname])>#sForm[arrFields[thisField].fieldname]#<cfelse>'#sForm[arrFields[thisField].fieldname]#'</cfif>
								</cfif>					
							<cfelse>
								<cfif arrFields[thisField].isnullable>
									NULL
								<cfelse>
									''
								</cfif>
							</cfif>
							<cfif thisField lt ArrayLen(arrFields)>,</cfif>
						</cfloop>
						)
						</cfquery>
						<cfquery name="qGetPKfield" datasource="#attributes.datasource#" maxrows="1">
						SELECT		#attributes.pkfield#
						FROM		#attributes.dbtable#
						ORDER BY	#attributes.pkfield# DESC
						</cfquery>
						<cfset sForm.pkfield = qGetPKfield[attributes.pkfield][1]>
					</cfif>
					<!--- /Main table updates/inserts --->
					<!--- Relate table inserts/updates --->
					<!--- <cfoutput>|#liRelateTableFields#|</cfoutput><cfabort> --->
					<cfif Len(liRelateTableFields)>
						<cfloop index="thisField" list="#liRelateTableFields#">
							<cfif StructKeyExists(ThisTag.qfields[thisField],"reltable") AND Len(ThisTag.qfields[thisField].reltable)>
								<cfquery name="qRelateData" datasource="#attributes.datasource#">
								SELECT	#attributes.pkfield# AS pkfield, #ThisTag.qfields[thisField].subvalues# AS fkfield
								FROM	#ThisTag.qfields[thisField].reltable#
								WHERE	#attributes.pkfield# = <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
								</cfquery>
								<cfset liCurrValues = ValueList(qRelateData.fkfield)>
								<!--- Run Deletes --->
								<cfparam name="sForm.#ThisTag.qfields[thisField].fieldname#" default="">
								<cfloop index="thisFkVal" list="#liCurrValues#">
									<cfif NOT ListFindNoCase(sForm[ThisTag.qfields[thisField].fieldname], thisFkVal)>
										<cfquery name="qDeleteRelate" datasource="#attributes.datasource#">
										DELETE
										FROM	#ThisTag.qfields[thisField].reltable#
										WHERE	#attributes.pkfield# = <cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
											AND	#ThisTag.qfields[thisField].subvalues# = <cfqueryparam value="#thisFkVal#" cfsqltype="#ThisTag.qfields[thisField].fkdatatype#">
										</cfquery>
									</cfif>
								</cfloop>
								<!--- /Run Deletes --->
								<!--- Run Inserts --->
								<cfloop index="formFkVal" list="#sForm[ThisTag.qfields[thisField].fieldname]#">
									<cfif Len(formFkVal) AND NOT ListFindNoCase(liCurrValues, formFkVal)>
										<cfquery name="qAddRelate" datasource="#attributes.datasource#">
										INSERT INTO	#ThisTag.qfields[thisField].reltable# (
											#attributes.pkfield#,
											#ThisTag.qfields[thisField].subvalues#
										)
										VALUES (
											<cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">,
											<cfqueryparam value="#formFkVal#" cfsqltype="#ThisTag.qfields[thisField].fkdatatype#">
										)
										</cfquery>
									</cfif>
								</cfloop>
								<!--- /Run Inserts --->
							</cfif>
						</cfloop>
					</cfif>
					<!--- /Relate table inserts/updates --->
					<!---  sub table inserts/updates --->
					<cfif isDefined("ThisTag.subforms")>
						<!---  Loop through all subforms --->
						<cfloop index="i" from="1" to="#ArrayLen(ThisTag.subforms)#" step="1">
							<!---  If subform has records --->
							<cfif ThisTag.subforms[i].qsubdata_RecordCount>
								<!---  Loop through all existing records in subform --->
								<cfloop index="j" from="1" to="#ThisTag.subforms[i].qsubdata_RecordCount#" step="1">
									<cfset CurrRecordID = ThisTag.subforms[i].qsubdata[ThisTag.subforms[i].pkfield][j]>
									<cfset prefix = "#ThisTag.subforms[i].prefix#e#CurrRecordID#_">
									<!---  Edit subform --->
									<cfquery name="qsebformUpdate" datasource="#attributes.datasource#">
									UPDATE	#ThisTag.subforms[i].tablename#
									SET
									<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
										<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
										<cfif Len(ThisTag.subforms[i].qfields[thisField].dbfield) AND isDefined("sForm.#FormFieldName#") AND NOT ThisTag.subforms[i].qfields[thisField].locked>
											#ThisTag.subforms[i].qfields[thisField].dbfield# =
											<cfif Len(sForm[FormFieldName])>
												<cfif Len(ThisTag.subforms[i].qfields[thisField].cfdatatype)>
													<cfqueryparam value="#sForm[FormFieldName]#" cfsqltype="#ThisTag.subforms[i].qfields[thisField].cfdatatype#">
												<cfelseif ThisTag.subforms[i].qfields[thisField].dbdatatype CONTAINS "date" OR ThisTag.subforms[i].qfields[thisField].type eq "xdate">
													<cfif attributes.dbtype eq "mys">'#DateFormat(sForm[FormFieldName],"yyyy-mm-dd")#'<cfelse>#CreateODBCDate(sForm[FormFieldName])#</cfif>
												<cfelse>
													<cfif isNumeric(sForm[FormFieldName])>#sForm[FormFieldName]#<cfelse>'#sForm[FormFieldName]#'</cfif>
												</cfif>
											<cfelse>
												<cfif ThisTag.subforms[i].qfields[thisField].isnullable>
													NULL
												<cfelse>
													''
												</cfif>
											</cfif>
											,
										</cfif>
									</cfloop><!--- Need to be able to handle any data type for pkfield --->
									#ThisTag.subforms[i].fkfield# = #sForm.pkfield#
									WHERE	#ThisTag.subforms[i].pkfield# = <cfqueryparam value="#CurrRecordID#" cfsqltype="#ThisTag.subforms[i].datatype#">
									</cfquery>
									<!--- /Edit subform --->
								</cfloop>
								<!--- /Loop through all existing records in subform --->
							</cfif>
							<!--- /If subform has records --->
							<!---  Insert new records into subform --->
							<cfif ThisTag.subforms[i].addrows>
								<!---  Loop over all possible new entries for subforms --->
								<cfloop index="j" from="1" to="#ThisTag.subforms[i].addrows#" step="1">
									<cfset prefix = "#ThisTag.subforms[i].prefix#a#j#_">
									<!--- /Check for populated fields (new record) --->
									<cfset isNewRecord = false>
									<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
										<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
										<cfif isDefined("sForm.#FormFieldName#") AND Len(sForm[FormFieldName]) AND (sForm[FormFieldName] neq ThisTag.subforms[i].qfields[thisField].defaultvalue)>
											<cfset isNewRecord = true>
										</cfif>
									</cfloop>
									<!--- /Check for populated fields (new record) --->
									<!---  If this is a new record --->
									<cfif isNewRecord>
										<cfquery name="qsebformInsert" datasource="#attributes.datasource#">
										INSERT INTO #ThisTag.subforms[i].tablename#(
										<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
										<cfif Len(ThisTag.subforms[i].qfields[thisField].dbfield)>
											<cfset thisName = ThisTag.subforms[i].qfields[thisField].fieldname>
											#ThisTag.subforms[i].qfields[thisField].dbfield#,
										</cfif>
										</cfloop>
											#ThisTag.subforms[i].fkfield#
										)
										VALUES(
										<cfloop index="thisField" from="1" to="#ArrayLen(ThisTag.subforms[i].qfields)#" step="1">
										<cfif Len(ThisTag.subforms[i].qfields[thisField].dbfield)>
											<cfset FormFieldName = "#prefix##ThisTag.subforms[i].qfields[thisField].fieldname#">
											<cfif Len(sForm[FormFieldName])>
												<cfif Len(ThisTag.subforms[i].qfields[thisField].cfdatatype)>
													<cfqueryparam value="#sForm[FormFieldName]#" cfsqltype="#ThisTag.subforms[i].qfields[thisField].cfdatatype#">
												<cfelseif ThisTag.subforms[i].qfields[thisField].dbdatatype CONTAINS "date" OR ThisTag.subforms[i].qfields[thisField].type eq "xdate">
													<cfif attributes.dbtype eq "mys">#DateFormat(sForm[FormFieldName],"yyyy-mm-dd")#<cfelse>#CreateODBCDate(sForm[FormFieldName])#</cfif>
												<cfelse>
													<cfif isNumeric(sForm[FormFieldName])>#sForm[FormFieldName]#<cfelse>'#sForm[FormFieldName]#'</cfif>
												</cfif>					
											<cfelse>
												<cfif ThisTag.subforms[i].qfields[thisField].isnullable>
													NULL
												<cfelse>
													''
												</cfif>
											</cfif>
											,
										</cfif>
										</cfloop>
											<cfqueryparam value="#sForm.pkfield#" cfsqltype="#datatype#">
										)
										</cfquery>
									</cfif>
									<!--- /If this is a new record --->
								</cfloop>
								<!--- /Loop over all possible new entries for subform --->
							</cfif>
							<!--- /Insert new records into subform --->
						</cfloop>
						<!--- /Loop through all subforms --->
					</cfif>
					<!--- /sub table inserts/updates --->
				</cfif>
				<!--- || SEND EMAIL || --->
				<cfif Len(attributes.email)><!--- %%Email needs to include subform stuff as well --->
					<!--- If attributes.email has value, send an email --->
					<cfset Attachments = "">
					<cfset EmailFieldsOutput = "">
					<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfset thisName = arrFields[thisField].fieldname>
						<cfscript>
						if ( arrFields[thisField].type eq "file" AND Len(sForm[thisName]) ) {
							Attachments = ListAppend(Attachments, "#arrFields[thisField].destination##sForm[thisName]#");
						} else {
							if ( StructKeyExists(attributes.config["EmailFields"], arrFields[thisField].type) ) {
								ThisFieldOutput = attributes.config["EmailFields"][arrFields[thisField].type];
							} else if ( ListFindNoCase(request.liButtonTypes, arrFields[thisField].type) AND StructKeyExists(attributes.config["EmailFields"], "buttons") ) {
								ThisFieldOutput = attributes.config["EmailFields"]["buttons"];
							} else {
								ThisFieldOutput = attributes.config["EmailFields"].all;
							}
							if ( Len(Trim(arrFields[thisField].label)) ) {
								ThisFieldOutput = ReplaceNoCase(ThisFieldOutput,  "{", "", "ALL");
								ThisFieldOutput = ReplaceNoCase(ThisFieldOutput,  "}", "", "ALL");
							} else {
								ThisFieldOutput = REReplaceNoCase(ThisFieldOutput,"{[^}]*}","","ALL");
							}
							ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[id]", arrFields[thisField].id);
							ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[Label]", arrFields[thisField].label);
							ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[value]", arrFields[thisField].display);
							ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[Input]", "");
							ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[ReqMark]", "");
							if ( Len(Trim(arrFields[thisField].label)) ) {
								ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[Colon]", ":");
							} else {
								ThisFieldOutput = ReplaceNoCase(ThisFieldOutput, "[Colon]", "");
							}
							EmailFieldsOutput = EmailFieldsOutput & ThisFieldOutput;
						}
						</cfscript>
					</cfloop>
					<cfscript>
					ThisTag.output.EmailLayout = ReplaceNoCase(attributes.config.EmailLayout,  "[Fields]", EmailFieldsOutput);
					ThisTag.GeneratedContent = "";
					</cfscript>
					<cfif isDefined("attributes.Mailer") AND isObject(attributes.Mailer) AND StructKeyExists(attributes.Mailer,"send")>
						<cfinvoke
							component="#attributes.Mailer#"
							method="send"
						>
							<cfinvokeargument name="To" value="#attributes.email#">
							<cfinvokeargument name="CC" value="#attributes.emailCC#">
							<cfinvokeargument name="BCC" value="#attributes.emailBCC#">
							<cfinvokeargument name="ReplyTo" value="#attributes.replyto#">
							<cfinvokeargument name="From" value="#attributes.emailfrom#">
							<cfinvokeargument name="Subject" value="#attributes.subject#">
							<cfinvokeargument name="type" value="#attributes.emailtype#">
							<cfinvokeargument name="Contents" value="#ThisTag.output.EmailLayout#">
							<cfif Len(Attachments)>
								<cfinvokeargument name="Attachments" value="#Attachments#">
							</cfif>
						</cfinvoke>
					<cfelseif Len(attributes.mailserver)>
						<cfmail to="#attributes.email#" cc="#attributes.emailCC#" bcc="#attributes.emailBCC#" replyto="#attributes.replyto#" from="#attributes.emailfrom#" subject="#attributes.subject#" server="#attributes.mailserver#" type="#attributes.emailtype#">#ThisTag.output.EmailLayout#<cfloop index="thisAttach" list="#Attachments#"><cfmailparam file="#thisAttach#"></cfloop></cfmail>
					</cfif>
				</cfif>
				<!--- <cfset ThisTag.GeneratedContent = ""> --->
				<cfif attributes.sendforward><cflocation url="#attributes.forward#" addtoken="no"></cfif>
			</cfif>
		</cfif>
		<!--- /If validation passes, add/edit data --->
		<cfcatch type="Any">
			<cfif Len(attributes.CatchErrTypes) AND ListFindNoCase(attributes.CatchErrTypes,cfcatch.type)>
				<cfset Caller[attributes.returnvar].CaughtError = CFCATCH>
				<cfif StructKeyExists(CFCATCH,"Detail") AND Len(Trim(CFCATCH.Detail))>
					<cfset ArrayAppend(TagInfo.arrErrors, "#CFCATCH.Message#: #CFCATCH.Detail#")>
				<cfelse>
					<cfset ArrayAppend(TagInfo.arrErrors, "#CFCATCH.Message#")>
				</cfif>
				<cfif StructKeyExists(CFCATCH,"ExtendedInfo") AND Len(Trim(CFCATCH.ExtendedInfo))>
					<cfset TagInfo.liErrfields = ListAppend(TagInfo.liErrfields,CFCATCH.ExtendedInfo)>
				</cfif>
			<cfelse>
				<cfrethrow>
			</cfif>
		</cfcatch>
	</cftry>
</cfif>

<!--- || GENERATE OUTPUT || --->
<cfif Len(TagInfo.liErrFields) OR ArrayLen(TagInfo.arrErrors)>
	<cfsavecontent variable="cfgErrorItems"><cfoutput><cfloop index="thisErr" from="1" to="#ArrayLen(TagInfo.arrErrors)#" step="1">#ReplaceNoCase(attributes.config.ErrorItem, "[Error]", TagInfo.arrErrors[thisErr])#</cfloop></cfoutput></cfsavecontent>
	<cfset ThisTag.output.ErrorHeader = ReplaceNoCase(attributes.config.ErrorHeader, "[Errors]", cfgErrorItems)>
<cfelse>
	<cfset ThisTag.output.ErrorHeader = "">
</cfif>
<cfoutput><cfsavecontent variable="MyHead">
<cfif NOT request.isQformLoaded><script src="#attributes.librarypath#qforms.js" type="text/javascript"></script>
<style type="text/css"><cfif Len(attributes.skin)>@import url(#attributes.skinpath##attributes.skin#.css);<cfelse>@import url(#attributes.librarypath#calendar/calendar-win2k-1.css);</cfif><!--- <cfloop list="#TagInfo.liErrFields#" index="tfn">input###tfn# {background-color:red;}input###tfn#:focus {background-color:white;}</cfloop> ---></style><cfif hasDateField>
<script type="text/javascript" src="#attributes.librarypath#calendar/calendar.js"></script>
<script type="text/javascript" src="#attributes.librarypath#calendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="#attributes.librarypath#calendar/calendar-setup.js"></script></cfif>
<script language="JavaScript" type="text/javascript">
qFormAPI.setLibraryPath("#attributes.librarypath#");
qFormAPI.include("*");
<cfloop index="thisAPIvar" list="#TagInfo.liQFormAPI#"><cfif StructKeyExists(attributes, thisAPIvar)>qFormAPI.#thisAPIvar# = <cfif isBoolean(attributes[thisAPIvar]) or isNumeric(attributes[thisAPIvar])>#attributes[thisAPIvar]#<cfelse>'#attributes[thisAPIvar]#'</cfif>;
</cfif></cfloop></script><!--- Generate any qform API property ---><cfset request.isQformLoaded = true></cfif>
</cfsavecontent><cfhtmlhead text="#MyHead#"><cfsavecontent variable="ThisTag.output.form"><form name="#attributes.formname#"<cfloop index="thisHtmlAtt" list="#TagInfo.liHtmlAtts#"><cfif Len(attributes[thisHtmlAtt])> #thisHtmlAtt#="#attributes[thisHtmlAtt]#"</cfif></cfloop><cfif Len(attributes.action)> action="#xmlFormat(attributes.action)#"</cfif><cfif Len(attributes.method)> method="#attributes.method#"</cfif><cfif Len(attributes.enctype)> enctype="#attributes.enctype#"</cfif><cfif Len(attributes.target)> target="#attributes.target#"</cfif>><cfif attributes.sendback AND attributes.sendforward>
<input type="hidden" name="sebForm_forward" value="#CGI.HTTP_REFERER#"/>
</cfif><input type="hidden" name="sebformsubmit" value="#Hash(attributes.formname)#"/><cfif attributes.method EQ "get"><cfloop list="#CGI.QUERY_STRING#" delimiters="&" index="urlvalpair"><cfif ListLen(urlvalpair,"=") EQ 2 AND NOT ListFindNoCase(fieldlist,ListFirst(urlvalpair,"="))>
<input type="hidden" name="#ListFirst(urlvalpair,"=")#" value="#ListLast(urlvalpair,"=")#"/></cfif></cfloop></cfif>
<cfif ListFindNoCase(attributes.qFormData.ColumnList, attributes.pkfield)><input type="hidden" name="pkfield" value="#attributes.qFormData[attributes.pkfield][1]#"/><cfelse><input type="hidden" name="pkfield" value=""/></cfif><cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfif arrFields[thisField].type eq "hidden">
<input type="hidden" name="#arrFields[thisField].fieldname#"<cfif Len(arrFields[thisField].id)> id="#arrFields[thisField].id#"</cfif> value="#arrFields[thisField].value#"/></cfif></cfloop>
</cfsavecontent></cfoutput>
<cfscript>
ThisTag.output.Layout = ReplaceNoCase(attributes.config.Layout,  "<form>", ThisTag.output.form);
ThisTag.output.Layout = ReplaceNoCase(ThisTag.output.Layout,  "[ErrorHeader]", ThisTag.output.ErrorHeader);
ThisTag.output.Layout = ReplaceNoCase(ThisTag.output.Layout,  "[Fields]", ThisTag.GeneratedContent);
ThisTag.GeneratedContent = "";
wysifields = "";
</cfscript>
</cfsilent><cfoutput><!--- || DISPLAY OUTPUT || --->#Trim(ThisTag.output.Layout)#<cfif attributes.showReqMarkHint>
	<div>#attributes.config.ReqMark# = required</div>
</cfif>
<script language="JavaScript" type="text/javascript">
function seb_addEvent(obj, evType, fn) {if (obj.addEventListener) {obj.addEventListener(evType, fn, true);return true;} else if (obj.attachEvent){var r = obj.attachEvent("on"+evType, fn);return r;} else {return false;}}<cfif hasFileField>
/* check extensions function */
function checkExts(field,extensions) {var fieldValue = field.value;var arrExtensions = extensions.toLowerCase().split(",");var i = 0;var arrFieldValue = fieldValue.toLowerCase().split(".");var thisExt = arrFieldValue[arrFieldValue.length-1];var missingExt = true;fieldValue = fieldValue.toLowerCase();if (fieldValue.length == 0) {missingExt = false;} else {for (i=0; i < arrExtensions.length; i++) {if ( arrExtensions[i].charAt(0) == "." ) {arrExtensions[i] = arrExtensions[i].substring(1, arrExtensions[i].length);}if ( thisExt == arrExtensions[i] ) {missingExt = false;}}}return missingExt;}</cfif>
/* initialize the qForm object */
#attributes.objname# = new qForm("#attributes.formname#");<cfloop index="thisField" from="1" to="#ArrayLen(arrFields)#" step="1"><cfset thisName = arrFields[thisField].fieldname><cfif arrFields[thisField].type neq "plaintext">
if ( #attributes.objname#.#thisName# ) {#attributes.objname#.#thisName#.description = '#JSStringFormat(arrFields[thisField].label)#'};<cfif ListFindNoCase(wysytypes,arrFields[thisField].type)><cfset wysifields = ListAppend(wysifields, thisField)></cfif><cfif arrFields[thisField].required AND NOT ( arrFields[thisField].locked AND arrFields[thisField].type eq "file" ) AND NOT ( arrFields[thisField].type eq "file" AND Len(arrFields[thisField].value) )>
#attributes.objname#.#thisName#.required = true;</cfif><cfif arrFields[thisField].locked>
#attributes.objname#.#thisName#.locked = true;</cfif><cfif arrFields[thisField].type EQ "text" AND StructKeyExists(arrFields[thisField],"regex") AND Len(arrFields[thisField].regex)>
reFilter = new RegExp("#arrFields[thisField].regex#");
#attributes.objname#.#thisName#.validateExp("!reFilter.test(document.getElementById('#arrFields[thisField].id#').value)",'#arrFields[thisField].label# must be formatted correctly');</cfif><cfif Len(arrFields[thisField].qformmethods)><cfloop index="thisqFormMethod" list="#arrFields[thisField].qformmethods#" delimiters=";"><cfif Len(thisqFormMethod)>
#attributes.objname#.#thisName#.#thisqFormMethod#;</cfif></cfloop></cfif><cfif arrFields[thisField].type eq "file" AND Len(arrFields[thisField].extensions)>
#attributes.objname#.#thisName#.validateExp("checkExts(document.#attributes.formname#.#thisName#,'#arrFields[thisField].extensions#')", '#arrFields[thisField].label# must have one of the following extensions: #arrFields[thisField].extensions#');<cfelseif arrFields[thisField].type eq "xdate">
#attributes.objname#.#thisName#.locked = true;<cfelseif arrFields[thisField].type eq "textarea" AND isNumeric(arrFields[thisField].length) AND arrFields[thisField].length gt 0>
function sebTextareaLength_#arrFields[thisField].id#() {var limitField = document.getElementById('#arrFields[thisField].id#');var limitNum = #arrFields[thisField].length#;if (limitField.value.length > limitNum) {limitField.value = limitField.value.substring(0, limitNum);} else {document.getElementById('#arrFields[thisField].id#-countdown').value = #arrFields[thisField].length# - limitField.value.length;}}
seb_addEvent(document.getElementById('#arrFields[thisField].id#'), 'keydown', sebTextareaLength_#arrFields[thisField].id#);
seb_addEvent(document.getElementById('#arrFields[thisField].id#'), 'keyup', sebTextareaLength_#arrFields[thisField].id#);
document.getElementById('#arrFields[thisField].id#-countdiv').style.display = 'block';</cfif></cfif></cfloop><cfif Len(wysifields)>
function updateWysis() {<cfloop index="thisField" list="#wysifields#"><cfif arrFields[thisField].type eq "xstandard">document.getElementById('#arrFields[thisField].id#-edit').EscapeUnicode = true;document.getElementById('#arrFields[thisField].id#').value = document.getElementById('#arrFields[thisField].id#-edit').value;<cfelse>document.getElementById('#arrFields[thisField].id#').value = ha#arrFields[thisField].id#.getHTML();#attributes.objname#.#arrFields[thisField].fieldname#.setValue(ha#arrFields[thisField].id#.getHTML());</cfif></cfloop>}
seb_addEvent(#attributes.objname#,'submit',updateWysis);
//#attributes.objname#.onSubmit = updateWysis;
</cfif>
</script><cfif Len(focusField)></cfif><!--- %%Generate any qform field property ---><!--- <cfif arrFields[thisField].validate>#attributes.objname#.#thisName#.validate = true;</cfif> --->
</cfoutput>
</cfif><!--- %%Server-side checks for locked,email,phone,zip,ssn ---><!--- %%If email only, then files can accumulate in the destination folder --->
