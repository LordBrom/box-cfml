<cfcomponent name="boxService" output="false" accessors="true" hint="Box service layer.">

	<cfproperty name="defaultUserID"        type="string"        />

	<cfproperty name="fileService"          type="file"          />
	<cfproperty name="folderService"        type="folder"        />
	<cfproperty name="userService"          type="user"          />
	<cfproperty name="searchService"        type="search"        />
	<cfproperty name="collaborationService" type="collaboration" />
	<cfproperty name="uploadSessionService" type="uploadSession" />

	<cffunction name="init" returntype="boxService" access="public" output="false" hint="Constructor">
		<cfargument name="defaultUserID" type="string" required="true" default="#getUserID()#" hint="The user to be used if no user is passed in." />

		<cfset setDefaultUserID( arguments.defaultUserID ) />

		<cfset variables.boxAPIHandler = createObject("component", "boxAPIHandler").init() />

		<cfset setFileService(          createObject("component", "services.file"         ).init( variables.boxAPIHandler ) ) />
		<cfset setFolderService(        createObject("component", "services.folder"       ).init( variables.boxAPIHandler ) ) />
		<cfset setUserService(          createObject("component", "services.user"         ).init( variables.boxAPIHandler ) ) />
		<cfset setSearchService(        createObject("component", "services.search"       ).init( variables.boxAPIHandler ) ) />
		<cfset setCollaborationService( createObject("component", "services.collaboration").init( variables.boxAPIHandler ) ) />
		<cfset setUploadSessionService( createObject("component", "services.uploadSession").init( variables.boxAPIHandler ) ) />

		<cfreturn this />
	</cffunction>

	<!----------------------------------------------------------------------
	  --------------------------------SEARCH--------------------------------
	  ---------------------------------------------------------------------->

	<cffunction name="searchForContent" access="public" returntype="any" output="false" hint="">
		<cfargument name="query"           type="string"  required="true"                                hint="The string to search for. Box matches the search string against object names, descriptions, text contents of files, and other data." />
		<cfargument name="file_extensions" type="string"  required="true" default=""                     hint="Limit searches to specific file extensions like [pdf], [png], or [doc]. The value can be a single file extension or a comma-delimited list of extensions. For example: [png,md,pdf]" />
		<cfargument name="type"            type="string"  required="true" default=""                     hint="The type of objects you want to include in the search results. The type can be [file], [folder], or [web_link]." />
		<cfargument name="limit"           type="numeric" required="true" default=""                     hint="The maximum number of items to return. The default is 30 and the maximum is 200." />

		<cfargument name="asUserID"        type="string"  required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getSearchService().searchForContent( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>


	<!---------------------------------------------------------------------
	  --------------------------------FILES--------------------------------
	  --------------------------------------------------------------------->

	<cffunction name="uploadFile"            access="public" returntype="any" output="false" hint="">
		<cfargument name="fileName"  type="string"  required="true"                                hint="Name of uploaded file." />
		<cfargument name="filePath"  type="string"  required="true"                                hint="Path to file to be uploaded." />
		<cfargument name="ParentID"  type="string"  required="true" default="0"                    hint="BoxID of folder to upload file to." />
		<cfargument name="fileID"    type="string"  required="true" default=""                     hint="BoxID of file to update the version of." />
		<cfargument name="preflight" type="boolean" required="true" default="0"                    hint="Performs a Preflight check, to see if uploading the file would be successful." />
		<cfargument name="asUserID"  type="string"  required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfargument name="returnIDOnly"  type="boolean"  required="true" default="1" hint="If true, only the BoxID of the file is returned. if false, the whole api response is returned" />

		<cfset local.result = getFileService().upload( argumentCollection = arguments ) />

		<cfif arguments.Preflight>
			<cfset local.firstPos = find("=", local.result.upload_url) + 1 />
			<cfset local.lastPos = find("&", local.result.upload_url) />
			<cfset local.uploadSessionID = mid(local.result.upload_url, local.firstPos, local.lastPos - local.firstPos) />
			<cfdump var="#getUploadSession(uploadSessionID = local.uploadSessionID)#" /><cfabort />
			<cfset local.result = getFileService().commitUpload(
				uploadSessionID = local.uploadSessionID,
				asUserID        = arguments.asUserID
		 	) />
		 	<cfdump var="#local.result#" /><cfabort />
		</cfif>

		<cfif arguments.returnIDOnly AND structKeyExists(local.result, "success") and local.result.success>
			<cfreturn local.result.entries[1].id />
		</cfif>

		<cfreturn local.result />
	</cffunction>

	<cffunction name="getFileInfo"             access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to get info of." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().getInfo( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="renameFile"              access="public" returntype="any" output="false" hint="">
		<cfargument name="fileName" type="string" required="true"                                hint="Name to change the file to." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = updateFile( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="moveFile"                access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to update." />
		<cfargument name="parentID" type="string" required="true" default="0"                    hint="BoxID of folder to move the file to." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = updateFile( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="setFileTags"             access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to update." />
		<cfargument name="tags"     type="array"  required="true"                                hint="Array of strings. These tags will by applied to the file." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = updateFile( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="updateFile"              access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                 hint="BoxID of file to update." />
		<cfargument name="fileName" type="string" required="false"                                hint="Name to change the file to." />
		<cfargument name="parentID" type="string" required="false"                                hint="BoxID of folder to move the file to." />
		<cfargument name="tags"     type="array"  required="false"                                hint="Array of strings. These tags will by applied to the file." />
		<cfargument name="asUserID" type="string" required="true"  default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().update( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="deleteFile"              access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().delete( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="copyFile"                access="public" returntype="any" output="false" hint="">
		<cfargument name="fileName" type="string" required="true"                                hint="Name of the newly created file." />
		<cfargument name="ParentID" type="string" required="true" default="0"                    hint="BoxID of folder new file will be created in." />
		<cfargument name="SourceID" type="string" required="true"                                hint="BoxID of folder to be copied." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().copy( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getFileCollaborations"   access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().getCollaborations( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="createFileUploadSession" access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().createUploadSession( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="listFileVersions"        access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"   type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().ListVersions( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getFileVersion"          access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"    type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="versionID" type="string" required="true"                                hint="Version number to retrieve." />
		<cfargument name="asUserID"  type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().getVersion( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="revertFileVersion"       access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"    type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="versionID" type="string" required="true"                                hint="Version number to revert to." />
		<cfargument name="asUserID"  type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().revertVersion( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="deleteFileVersion"       access="public" returntype="any" output="false" hint="">
		<cfargument name="fileID"    type="string" required="true"                                hint="BoxID of file to delete." />
		<cfargument name="versionID" type="string" required="true"                                hint="Version number to delete." />
		<cfargument name="asUserID"  type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFileService().deleteVersion( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>


	<!---------------------------------------------------------------------
	  -------------------------------FOLDERS-------------------------------
	  --------------------------------------------------------------------->

	<cffunction name="createFolder"            access="public" returntype="any" output="false" hint="">
		<cfargument name="folderName" type="string" required="true"                                hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true" default="0"                    hint="BoxID of folder new folder will be created in." />
		<cfargument name="asUserID"   type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfargument name="returnID"  type="boolean"  required="true" default="1" hint="If true, only the BoxID of the folder is returned. if false, the whole api response is returned" />

		<cfset local.result = getFolderService().create( argumentCollection = arguments ) />

		<cfif arguments.returnID AND local.result?.success ?: false>
			<cfreturn local.result.id />
		</cfif>

		<cfreturn local.result />
	</cffunction>

	<cffunction name="copyFolder"              access="public" returntype="any" output="false" hint="">
		<cfargument name="folderName" type="string" required="true"                                hint="Name of the newly created folder." />
		<cfargument name="ParentID"   type="string" required="true" default="0"                    hint="BoxID of folder new folder will be created in." />
		<cfargument name="SourceID"   type="string" required="true"                                hint="BoxID of folder to be copied." />
		<cfargument name="asUserID"   type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfargument name="returnID"  type="boolean"  required="true" default="1" hint="If true, only the BoxID of the folder is returned. if false, the whole api response is returned" />

		<cfset local.result = getFolderService().copy( argumentCollection = arguments ) />

		<cfif arguments.returnID AND local.result?.success ?: false>
			<cfreturn local.result.id />
		</cfif>

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getFolderContents"       access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0"                    hint="BoxID of folder to get contents of." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFolderService().getContents( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getFolderInfo"           access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0"                    hint="BoxID of folder to get info of." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFolderService().getInfo( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="renameFolder"            access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID"   type="string" required="true"                                hint="BoxID of folder to update." />
		<cfargument name="folderName" type="string" required="false"                               hint="Name to change the folder to." />
		<cfargument name="asUserID"   type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = updateFolder( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="moveFolder"              access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true"                                 hint="BoxID of folder to update." />
		<cfargument name="parentID" type="string" required="false" default="0"                    hint="BoxID of folder to move the folder to." />
		<cfargument name="asUserID" type="string" required="true"  default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = updateFolder( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="setFolderTags"           access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true"                                hint="BoxID of folder to update." />
		<cfargument name="tags"     type="array"  required="false"                               hint="Array of strings. These tags will by applied to the folder." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = updateFolder( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="updateFolder"            access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID"   type="string" required="true"                                hint="BoxID of folder to update." />
		<cfargument name="folderName" type="string" required="false"                               hint="Name to change the folder to." />
		<cfargument name="parentID"   type="string" required="false"                               hint="BoxID of folder to move the folder to." />
		<cfargument name="tags"       type="array"  required="false"                               hint="Array of strings. These tags will by applied to the folder." />
		<cfargument name="asUserID"   type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFolderService().update( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="deleteFolder"            access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0"                    hint="BoxID of folder to delete." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFolderService().delete( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getFolderCollaborations" access="public" returntype="any" output="false" hint="">
		<cfargument name="folderID" type="string" required="true" default="0"                     hint="BoxID of folder to delete." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getFolderService().getCollaborations( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>


	<!---------------------------------------------------------------------
	  --------------------------------USERS--------------------------------
	  --------------------------------------------------------------------->

	<cffunction name="getUserInfo"        access="public" returntype="any" output="false" hint="">
		<cfargument name="userID"   type="string" required="true"                                hint="BoxID of user to get info of." />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getUserService().getInfo( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="getCurrentUserInfo" access="public" returntype="any" output="false" hint="">
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getUserService().getCurrentUserInfo( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="createAppUser"      access="public" returntype="any" output="false" hint="">
		<cfargument name="userName" type="string" required="true"                                hint="Name of user to create" />
		<cfargument name="asUserID" type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getUserService().createAppUser( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>


	<!----------------------------------------------------------------------
	  ----------------------------COLLABORATIONS----------------------------
	  ---------------------------------------------------------------------->

	<cffunction name="createCollaboration" access="public" returntype="any" output="false" hint="">
		<cfargument name="itemBoxID"         type="string" required="true"                                hint="The ID of the file or folder that access is granted to" />
		<cfargument name="accessibleByBoxID" type="string" required="true"                                hint="The ID of the user or group that is granted access" />
		<cfargument name="accessibleType"    type="string" required="true" default="user"                 hint="[user] or [group]" />
		<cfargument name="role"              type="string" required="true" default="editor"               hint="The level of access granted. Can be [editor], [viewer], [previewer], [uploader], [previewer uploader], [viewer uploader], or [co-owner]." />
		<cfargument name="asUserID"          type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfif NOT listFindNoCase("editor,viewer,previewer,uploader,previewer uploader,viewer uploader,co-owner", arguments.role) >
			<cfthrow message="Arugment ""role"" was passed with an invalid value" />
		</cfif>
		<cfif NOT listFindNoCase("user,group", arguments.accessibleType) >
			<cfthrow message="Arugment ""accessibleType"" was passed with an invalid value" />
		</cfif>

		<cfset local.return = getCollaborationService().create( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>


	<!----------------------------------------------------------------------
	  ----------------------------UPLOAD SESSION----------------------------
	  ---------------------------------------------------------------------->

	<cffunction name="getUploadSession"    access="public" returntype="any" output="false" hint="">
		<cfargument name="uploadSessionID" type="string" required="true" hint="" />
		<cfargument name="asUserID"        type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.return = getUploadSessionService().get( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

	<cffunction name="createUploadSession" access="public" returntype="any" output="false" hint="">
		<cfargument name="fileName"  type="string"  required="true"                                hint="Name of uploaded file." />
		<cfargument name="filePath"  type="string"  required="true"                                hint="Path to file to be uploaded." />
		<cfargument name="ParentID"  type="string"  required="true" default="0"                    hint="BoxID of folder to upload file to." />
		<cfargument name="asUserID"  type="string" required="true" default="#getDefaultUserID()#" hint="BoxID of user to perform action oh behalf of." />

		<cfset local.fileInfo = getFileInfo(arguments.filePath) />
		<cfset arguments.fileSize = local.fileInfo.size />

		<cfset local.return = getUploadSessionService().create( argumentCollection = arguments ) />

		<cfreturn local.return />
	</cffunction>

</cfcomponent>
