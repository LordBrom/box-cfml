<cfcomponent name="boxObjectIDService" output="false" hint="Box object ID service">

	<cffunction name="getBoxFolderID" access="public" returntype="string" output="false" hint="Returns a Box Folder ID">
		<cfargument name="rootFolderName" type="string" required="true" hint="bid|lead|job|media" />
		<cfswitch expression="#lCase(arguments.rootFolderName)#">
			<cfcase value="bid">
				<cfreturn getBoxBidFolderID() />
			</cfcase>
			<cfcase value="asapbid">
				<cfreturn getBoxASAPBidFolderID() />
			</cfcase>
			<cfcase value="asapbidtemplate">
				<cfreturn getBoxASAPBidTemplateFolderID() />
			</cfcase>
			<cfcase value="lead">
				<cfreturn getBoxLeadFolderID() />
			</cfcase>
			<cfcase value="job">
				<cfreturn getBoxJobFolderID() />
			</cfcase>
			<cfcase value="media">
				<cfreturn getBoxMediaFolderID() />
			</cfcase>
			<cfdefaultcase ><cfthrow message="Box folder with name '#lCase(arguments.rootFolderName)#' not found" /></cfdefaultcase>
		</cfswitch>
	</cffunction>

	<cffunction name="getBoxBidFolderID" access="private" returntype="string" output="false" hint="Returns the Box root Shumate Bid Folder ID">
		<cfswitch expression="#request.environment#">
			<cfcase value="production" ><cfreturn "68489297379" /></cfcase>
			<cfcase value="staging"    ><cfreturn "54120452204" /></cfcase>
			<cfcase value="development"><cfreturn "54120452204" /></cfcase>
			<cfdefaultcase             ><cfreturn "54120452204" /></cfdefaultcase> <!--- same as beta --->
		</cfswitch>
	</cffunction>

	<cffunction name="getBoxASAPBidFolderID" access="private" returntype="string" output="false" hint="Returns the Box root ASAP Bid Folder ID">
		<cfswitch expression="#request.environment#">
			<cfcase value="production" ><cfreturn "83295117388" /></cfcase>
			<cfcase value="staging"    ><cfreturn "83295117388" /></cfcase>
			<cfcase value="development"><cfreturn "82644739773" /></cfcase>
			<cfdefaultcase             ><cfreturn "82644739773" /></cfdefaultcase> <!--- same as beta --->
		</cfswitch>
	</cffunction>

	<cffunction name="getBoxASAPBidTemplateFolderID" access="private" returntype="string" output="false" hint="Returns the Box root ASAP Bid Folder ID">
		<cfswitch expression="#request.environment#">
			<cfcase value="production" ><cfreturn "83564583521" /></cfcase>
			<cfcase value="staging"    ><cfreturn "83564583521" /></cfcase>
			<cfcase value="development"><cfreturn "83565699196" /></cfcase>
			<cfdefaultcase             ><cfreturn "83565699196" /></cfdefaultcase> <!--- same as beta --->
		</cfswitch>
	</cffunction>

	<cffunction name="getBoxLeadFolderID" access="private" returntype="string" output="false" hint="Returns the Box root Shumate Lead Folder ID">
		<cfswitch expression="#request.environment#">
			<cfcase value="production" ><cfreturn "68488930027" /></cfcase>
			<cfcase value="staging"    ><cfreturn "54119686335" /></cfcase>
			<cfcase value="development"><cfreturn "54119686335" /></cfcase>
			<cfdefaultcase             ><cfreturn "54119686335" /></cfdefaultcase> <!--- same as beta --->
		</cfswitch>
	</cffunction>

	<cffunction name="getBoxJobFolderID" access="private" returntype="string" output="false" hint="Returns the Box root Shumate Job(/WO) Folder ID">
		<cfswitch expression="#request.environment#">
			<cfcase value="production" ><cfreturn "68486633425" /></cfcase>
			<cfcase value="staging"    ><cfreturn "54120861924" /></cfcase>
			<cfcase value="development"><cfreturn "54120861924" /></cfcase>
			<cfdefaultcase             ><cfreturn "54120861924" /></cfdefaultcase> <!--- same as beta --->
		</cfswitch>
	</cffunction>

	<cffunction name="getBoxMediaFolderID" access="private" returntype="string" output="false" hint="Returns the Box root Media Folder ID">
		<cfswitch expression="#request.environment#">
			<cfcase value="production" ><cfreturn "68489209919" /></cfcase>
			<cfcase value="staging"    ><cfreturn "57598902161" /></cfcase>
			<cfcase value="development"><cfreturn "57598902161" /></cfcase>
			<cfdefaultcase             ><cfreturn "57598902161" /></cfdefaultcase> <!--- same as beta --->
		</cfswitch>
	</cffunction>

	<cffunction name="getUserID" access="public" returntype="string" output="false" hint="Returns a users Box account ID">
		<!--- <cfargument name="name" type="type" required="type" hint="" /> --->
		<cfif request.isDevevelopment>
			<cfset local.return = "3832020592" />
		<cfelse>
			<cfset local.return = "9507304114" />
		</cfif>

		<cfreturn local.return />
	</cffunction>

</cfcomponent>