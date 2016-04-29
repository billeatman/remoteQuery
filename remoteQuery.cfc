<cfcomponent displayName="remoteQuery">

  <cffunction name="init" access="public" output="false" returntype="remoteQuery" hint="constructor">
    <cfset this.sqlArray = "">
      <cfreturn this />
   </cffunction>


	<!--- Rules for different field names --->
    <cffunction name="getFieldName" access="public" returntype="boolean" output="no">
        <cfargument name="FltObj" type="struct">
        <cfswitch expression="#trim(ucase(FltObj.fieldId))#">
            <cfcase value="ASSIGNEDNAME">
                <cfif isNumeric("#FltObj.values[1].value#")>
                    <cfset ArrayAppend(this.sqlArray, 'assignedID')>
                <cfelse>
                    <cfset ArrayAppend(this.sqlArray, 'assignedName')>
                </cfif>
            </cfcase>
            <cfcase value="COMPLETE">
                <cfset ArrayAppend(this.sqlArray, 'completed')>
                <cfif FltObj.values[1].value eq -1>
                    <cfset FltObj.values[1].value = 0>
                </cfif>
            </cfcase>
            <cfcase value="COST,REQUESTOR,TASKID,LASTUPDATED,TASKBRIEF,PROJECTID,REQUESTORTYPE,ROOM,LOCATION,HOURS,TASKTYPE,PRIORITY,CREATEDBY">
                <cfset ArrayAppend(this.sqlArray, FltObj.fieldId)>
            </cfcase>
			<cfcase value="DUEDATE,COMPLETEDDATE,REQUESTDATE,MODIFIEDDATE">
			</cfcase>
            <cfdefaultcase>
                 NO FIELD MAPPING - #trim(ucase(FltObj.fieldId))#
                 <cfreturn false>
            </cfdefaultcase>
        </cfswitch>
        <cfreturn true>
    </cffunction>

	<!--- builds the value structure for the cfqueryparam --->
    <cffunction access="public" name="buildValue" returntype="struct" output="no">
        <cfargument name="bvalue">
        <cfargument name="bsqltype">
        <cfset var valueStruct = structnew()>
        <cfset valueStruct.value = bvalue>
        <cfset valueStruct.sqltype = bsqltype>
        <cfreturn valueStruct>
    </cffunction>

	<!--- build by operator id --->
    <cffunction name="buildSQL" access="public" returntype="boolean" output="no">
      <cfargument name="FltObj" type="struct">
          <cfif getFieldName(FltObj) eq false>
              <cfreturn false>
          </cfif>	
          <cfswitch expression="#trim(ucase(FltObj.operatorId))#">
            <cfcase value="STRING_EQUAL">
            <cfif #trim(FltObj.values[1].value)# eq "">
              <cfset ArrayAppend(this.sqlArray, 'is null')>
              <cfelse>
              <cfset ArrayAppend(this.sqlArray, '=')>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_varchar"))>
            </cfif>
            </cfcase>
            <cfcase value="STRING_DIFFERENT">
            <cfset ArrayAppend(this.sqlArray, '<>')>
            <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_varchar"))>
            </cfcase>
            <cfcase value="STRING_CONTAINS">
            <cfset ArrayAppend(this.sqlArray, 'like')>
            <cfset ArrayAppend(this.sqlArray, buildValue('%#FltObj.values[1].value#%', "cf_sql_varchar"))>
            </cfcase>
            <cfcase value="STRING_DOESNT_CONTAIN">
            <cfset ArrayAppend(this.sqlArray, 'not like')>
            <cfset ArrayAppend(this.sqlArray, buildValue('%#FltObj.values[1].value#%', "cf_sql_varchar"))>
            </cfcase>
            <cfcase value="STRING_STARTS_WITH">
            <cfset ArrayAppend(this.sqlArray, 'like')>
            <cfset ArrayAppend(this.sqlArray, buildValue('#FltObj.values[1].value#%', "cf_sql_varchar"))>
            </cfcase>
            <cfcase value="STRING_ENDS_WITH">
            <cfset ArrayAppend(this.sqlArray, 'like')>
            <cfset ArrayAppend(this.sqlArray, buildValue('%#FltObj.values[1].value#', "cf_sql_varchar"))>
            </cfcase>      
            <cfcase value="STRING_LIST">
            <cfset ArrayAppend(this.sqlArray, 'in (-1')>
            <CFLOOP index="i" array="#FltObj.values#">
              <cfset ArrayAppend(this.sqlArray, ',')>
              <cfset ArrayAppend(this.sqlArray, buildValue(i.value, "cf_sql_integer"))>
            </CFLOOP>
            <cfset ArrayAppend(this.sqlArray, ')')>
            </cfcase>
			<cfcase value="NUMBER_EQUAL">
            <cfset ArrayAppend(this.sqlArray, '=')>
            <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_integer"))>
            </cfcase>
			<cfcase value="NUMBER_NOT_EQUAL">
            <cfset ArrayAppend(this.sqlArray, '<>')>
            <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_integer"))>
            </cfcase>
            <cfcase value="NUMBER_GREATER">
            <cfset ArrayAppend(this.sqlArray, '>')>
            <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_integer"))>
            </cfcase>
		    <cfcase value="NUMBER_GREATER_OR_EQUAL">
		      <cfset ArrayAppend(this.sqlArray, '>=')>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_integer"))>
		    </cfcase>
		    <cfcase value="NUMBER_LESS">
		       <cfset ArrayAppend(this.sqlArray, '<')>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_integer"))>
		    </cfcase>
		    <cfcase value="NUMBER_LESS_OR_EQUAL">
		        <cfset ArrayAppend(this.sqlArray, '<=')>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_integer"))>
		    </cfcase>
		    <cfcase value="NUMBER_RANGE">
			    <!---and taskBrief between--->
		    </cfcase>
		    <cfcase value="DATE_EQUAL">
			  <cfset ArrayAppend("dateDiff(day," + #FltObj.fieldId# +", ")>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_date"))>
		      <cfset ArrayAppend(") = 0")>
		    </cfcase>
		    <cfcase value="DATE_GREATER">
			  <cfset ArrayAppend("dateDiff(day," + #FltObj.fieldId# +", ")>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_date"))>
		      <cfset ArrayAppend(") < 0")>
		    </cfcase>
		    <cfcase value="DATE_GREATER_OR_EQUAL">
			  <cfset ArrayAppend("dateDiff(day," + #FltObj.fieldId# +", ")>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_date"))>
		      <cfset ArrayAppend(") <= 0")>
		    </cfcase>
		    <cfcase value="DATE_LESS">
			  <cfset ArrayAppend("dateDiff(day," + #FltObj.fieldId# +", ")>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_date"))>
		      <cfset ArrayAppend(") > 0")>
		    </cfcase>
		    <cfcase value="DATE_LESS_OR_EQUAL">
			  <cfset ArrayAppend("dateDiff(day," + #FltObj.fieldId# +", ")>
              <cfset ArrayAppend(this.sqlArray, buildValue(FltObj.values[1].value, "cf_sql_date"))>
		      <cfset ArrayAppend(") >= 0")>
		    </cfcase>
		    <cfcase value="DATE_RANGE">
		    	<!---and dueDate between <cfqueryparam cfsqltype="cf_sql_varchar" value="#filterDUEDATE#"> and <cfqueryparam cfsqltype="cf_sql_varchar" value="#filterDUEDATE2#">--->
		    </cfcase>
		    <cfcase value="DATE_PERIOD">
				<cfswitch expression="#filterDUEDATE#">
					<cfcase value="LAST_QUARTER">

					</cfcase>
					<cfcase value="LAST_HOUR">
						<cfset ArrayAppend("dateDiff(hour," + #FltObj.fieldId# +", ")>
			            <cfset ArrayAppend(this.sqlArray, buildValue(#now()#, "cf_sql_date"))>
					    <cfset ArrayAppend(") = 1")>
					</cfcase>
					<cfcase value="LAST_DAY">
						<cfset ArrayAppend("dateDiff(day," + #FltObj.fieldId# +", ")>
			            <cfset ArrayAppend(this.sqlArray, buildValue(#now()#, "cf_sql_date"))>
					    <cfset ArrayAppend(") = 1")>
					</cfcase>
					<cfcase value="LAST_WEEK">
						<cfset ArrayAppend("dateDiff(week," + #FltObj.fieldId# +", ")>
			            <cfset ArrayAppend(this.sqlArray, buildValue(#now()#, "cf_sql_date"))>
					    <cfset ArrayAppend(") = 1")>
					</cfcase>
					<cfcase value="LAST_MONTH">
						<cfset ArrayAppend("dateDiff(month," + #FltObj.fieldId# +", ")>
			            <cfset ArrayAppend(this.sqlArray, buildValue(#now()#, "cf_sql_date"))>
					    <cfset ArrayAppend(") = 1")>
					</cfcase>
					<cfcase value="LAST_YEAR">
						<cfset ArrayAppend("dateDiff(year," + #FltObj.fieldId# +", ")>
			            <cfset ArrayAppend(this.sqlArray, buildValue(#now()#, "cf_sql_date"))>
					    <cfset ArrayAppend(") = 1")>
					</cfcase>
				</cfswitch>
		    </cfcase>
            <cfdefaultcase>
                OPERATOR NOT FOUND
                <cfreturn false>
            </cfdefaultcase>
          </cfswitch>
          <cfreturn true>
    </cffunction>

	<!--- Recusively walk /parse the filterObject --->
    <cffunction name="walkFilterObject" access="public" returntype="boolean" output="no">
      <cfargument name="FltObj" type="struct">
      <cfif isDefined("FltObj.left")>
        <cfset ArrayAppend(this.sqlArray, '(')>
        <cfif walkFilterObject(FltObj.left) eq false>
            <cfreturn false>
        </cfif>
            <cfswitch expression="#trim(ucase(FltObj.logicalOperator))#">
                <cfcase value="OR">
                    <cfset ArrayAppend(this.sqlArray, 'OR')>
                </cfcase>
                <cfdefaultcase>
                    <cfset ArrayAppend(this.sqlArray, 'AND')>
                </cfdefaultcase>            
            </cfswitch>
        <cfif walkFilterObject(FltObj.right) eq false>
            <cfreturn false>
        </cfif>
        <cfset ArrayAppend(this.sqlArray, ')')>
        <cfelse>
        <cfset buildSQL(FltObj)>    
      </cfif>
      <cfreturn true>
    </cffunction>
	
 	<cffunction name="GETALL" access="public" output="true"> 
        <cfargument name="FILTEROBJECT" type="string" required="yes">
        <cfargument name="START" type="numeric" required="yes" default="0">
        <cfargument name="LIMIT" type="numeric" required="yes" default="25">     	

        <cftry>
			<cfset this.sqlArray = ArrayNew(1)>
    		<cfset myFltObj = DeserializeJSON(filterObject)>
    
    		<cfif walkFilterObject(myFltObj) eq true>
            <cfelse>
                *** FAILURE PARSING FILTER OBJECT ***
            </cfif>

    		<cfquery dataSource="#application.DataSource#" name='ticketQuery'>
                set QUOTED_IDENTIFIER ON
                select * from (select assignedName,taskID,requestor, requestDate,dueDate,taskBrief,
                <cfif isDefined('sort')>
                    ROW_NUMBER() OVER(ORDER BY #sort# #dir#) AS 'RowNumber'
                <cfelse>
                    ROW_NUMBER() OVER(ORDER BY taskID desc) AS 'RowNumber'
                </cfif>
                from vwtask where
                <!--- build the sql from the generated array --->
                <CFLOOP index="i" array="#this.sqlArray#">
                <cfif isStruct(i) eq true>
                    <cfqueryparam cfsqltype="#i.sqltype#" value="#i.value#">
                <cfelse>
                    <cfoutput>#i#</cfoutput>
                </cfif>
                </CFLOOP>
                ) as t where RowNumber between #start + 1# and #start + limit#
                        	<cfif isDefined('sort')>
                                order by #sort# #dir#
                                <cfelse>
                                order by taskid desc
                        	</cfif>
            </cfquery>
                
            <cfquery dataSource="#application.DataSource#" name='totalRows'>
                select count(*) as totalRows
                from vwtask where
                <CFLOOP index="i" array="#this.sqlArray#">
                <cfif isStruct(i) eq true>
                    <cfqueryparam cfsqltype="#i.sqltype#" value="#i.value#">
                <cfelse>
                    <cfoutput>#i#</cfoutput>
                </cfif>
                </CFLOOP>
            </cfquery>
            
            
            <cfset result = application.JSON.encode(data = "#ticketQuery#", totalCount ="#totalRows.totalRows#", queryFormat="array")>
            <cfoutput>
            #result#
            </cfoutput>
            <cfabort>

			<cfcatch>
    	       <cfabort>
            </cfcatch>
        </cftry>
  	</cffunction>

</cfcomponent>