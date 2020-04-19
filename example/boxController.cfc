<cfcomponent >

	<cffunction name="getFolderContents" access="remote" returntype="void" output="false" hint="">
		<cfargument name="folderID" type="string" required="false" hint="" />

		<cftry>
			<cfset local.folderData = application.boxService.getFolderInfo( folderID = arguments.folderID ) />

			<cfset local.return = structNew() />
			<cfset local.return.folderID = arguments.folderID  />
			<cfset local.return.childArray = arrayNew(1)  />

			<cfloop array="#local.folderData.item_collection.entries#" index="local.folder">
				<cfset local.newFolder = structNew() />
				<cfset local.newFolder.ID   = local.folder.ID />
				<cfset local.newFolder.name = local.folder.name />
				<cfset local.newFolder.type = local.folder.type />

				<cfset local.return.childarray.append(duplicate(local.newFolder)) />
			</cfloop>

			<cfset wsSendMessage({type: 'setFolders', msg: '#serializeJSON(local.return)#'}) />

			<cfcatch>
				<cfset wsSendMessage({type: 'error', msg: '#cfcatch.message#'}) />
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>
