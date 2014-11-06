<?xml version="1.0" encoding="utf-8"?>
<site><!-- Make sure all comments are the two-dash (not three-dash) variety -->
	<arguments>
		<argument name="datasource" type="string" />
		<argument name="UploadPath" type="string" />
	</arguments>
	<components>
		<component name="DataMgr" path="com.sebtools.DataMgr_MSSQL">
			<argument name="datasource" arg="datasource"/>
		</component>
		<component name="FileMgr" path="com.sebtools.FileMgr">
			<argument name="UploadPath" arg="UploadPath"/>
		</component>
		<component name="CodeCop" path="sys.CodeCop">
			<argument name="DataMgr" component="DataMgr"/>
		</component>
	</components>
</site>