/**
 * Box service layer.
 */
component output="false" accessors="true" hint="Box service layer." {
	property name="fileService"          type="file";
	property name="folderService"        type="folder";
	property name="userService"          type="user";
	property name="searchService"        type="search";
	property name="collaborationService" type="collaboration";
	property name="uploadSessionService" type="uploadSession";

	public box function init() output=false {
		local.boxAPIHandler = createObject("component", "boxAPIHandler").init();
		setFileService(          createObject("component", "services.file"         ).init( local.boxAPIHandler ) );
		setFolderService(        createObject("component", "services.folder"       ).init( local.boxAPIHandler ) );
		setUserService(          createObject("component", "services.user"         ).init( local.boxAPIHandler ) );
		setSearchService(        createObject("component", "services.search"       ).init( local.boxAPIHandler ) );
		setCollaborationService( createObject("component", "services.collaboration").init( local.boxAPIHandler ) );
		setUploadSessionService( createObject("component", "services.uploadSession").init( local.boxAPIHandler ) );
		return this;
	}
	/* -------------------------------------------------------------------
	  --------------------------------SEARCH--------------------------------
	  -------------------------------------------------------------------*/

	public any function searchForContent(
		required string query,
		required string file_extensions="",
		required string type="",
		required numeric limit="",
		required string asUserID=""
	) output=false {
		local.return = getSearchService().searchForContent( argumentCollection = arguments );
		return local.return;
	}
	/* ------------------------------------------------------------------
	  --------------------------------FILES--------------------------------
	  ------------------------------------------------------------------*/

	public any function uploadFile(
		required string fileName,
		required string filePath,
		required string ParentID="0",
		required string fileID="",
		required boolean preflight="0",
		required string asUserID="",
		required boolean returnIDOnly="1"
	) output=false {
		local.return = getFileService().upload( argumentCollection = arguments );
		if ( arguments.Preflight ) {
			local.firstPos = find("=", local.return.upload_url) + 1;
			local.lastPos = find("&", local.return.upload_url);
			local.uploadSessionID = mid(local.return.upload_url, local.firstPos, local.lastPos - local.firstPos);
			writeDump( var=getUploadSession(uploadSessionID = local.uploadSessionID), abort=1);
			local.return = getFileService().commitUpload(
				uploadSessionID = local.uploadSessionID,
				asUserID        = arguments.asUserID
		 	);
			writeDump( var=local.return, abort=1 );
		}
		if ( arguments.returnIDOnly && structKeyExists(local.return, "success") && local.return.success ) {
			return local.return.entries[1].id;
		}
		return local.return;
	}

	public any function downloadFile(
		required string fileID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().download( argumentCollection = arguments );
		return local.return;
	}

	public any function getFileInfo(
		required string fileID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().getInfo( argumentCollection = arguments );
		return local.return;
	}

	public any function renameFile(
		required string fileName,
		required string asUserID=""
	) output=false {
		local.return = updateFile( argumentCollection = arguments );
		return local.return;
	}

	public any function moveFile(
		required string fileID,
		required string parentID="0",
		required string asUserID=""
	) output=false {
		local.return = updateFile( argumentCollection = arguments );
		return local.return;
	}

	public any function setFileTags(
		required string fileID,
		required array tags,
		required string asUserID=""
	) output=false {
		local.return = updateFile( argumentCollection = arguments );
		return local.return;
	}

	public any function updateFile(
		required string fileID, string fileName, string parentID, array tags,
		required string asUserID=""
	) output=false {
		local.return = getFileService().update( argumentCollection = arguments );
		return local.return;
	}

	public any function deleteFile(
		required string fileID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().delete( argumentCollection = arguments );
		return local.return;
	}

	public any function copyFile(
		required string fileName,
		required string ParentID="0",
		required string SourceID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().copy( argumentCollection = arguments );
		return local.return;
	}

	public any function getFileCollaborations(
		required string fileID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().getCollaborations( argumentCollection = arguments );
		return local.return;
	}

	public any function createFileUploadSession(
		required string fileID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().createUploadSession( argumentCollection = arguments );
		return local.return;
	}

	public any function listFileVersions(
		required string fileID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().ListVersions( argumentCollection = arguments );
		return local.return;
	}

	public any function getFileVersion(
		required string fileID,
		required string versionID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().getVersion( argumentCollection = arguments );
		return local.return;
	}

	public any function revertFileVersion(
		required string fileID,
		required string versionID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().revertVersion( argumentCollection = arguments );
		return local.return;
	}

	public any function deleteFileVersion(
		required string fileID,
		required string versionID,
		required string asUserID=""
	) output=false {
		local.return = getFileService().deleteVersion( argumentCollection = arguments );
		return local.return;
	}
	/* ------------------------------------------------------------------
	  -------------------------------FOLDERS-------------------------------
	  ------------------------------------------------------------------*/

	public any function createFolder(
		required string folderName,
		required string ParentID="0",
		required string asUserID="",
		required boolean returnID="1"
	) output=false {
		local.return = getFolderService().create( argumentCollection = arguments );
		if ( arguments.returnID && local.return?.success ?: false ) {
			return local.return.id;
		}
		return local.return;
	}

	public any function copyFolder(
		required string folderName,
		required string ParentID="0",
		required string SourceID,
		required string asUserID="",
		required boolean returnID="1"
	) output=false {
		local.return = getFolderService().copy( argumentCollection = arguments );
		if ( arguments.returnID && local.return?.success ?: false ) {
			return local.return.id;
		}
		return local.return;
	}

	public any function getFolderContents(
		required string folderID="0",
		required string asUserID=""
	) output=false {
		local.return = getFolderService().getContents( argumentCollection = arguments );
		return local.return;
	}

	public any function getFolderInfo(
		required string folderID="0",
		required string asUserID=""
	) output=false {
		local.return = getFolderService().getInfo( argumentCollection = arguments );
		return local.return;
	}

	public any function renameFolder(
		required string folderID, string folderName,
		required string asUserID=""
	) output=false {
		local.return = updateFolder( argumentCollection = arguments );
		return local.return;
	}

	public any function moveFolder(
		required string folderID, string parentID="0",
		required string asUserID=""
	) output=false {
		local.return = updateFolder( argumentCollection = arguments );
		return local.return;
	}

	public any function setFolderTags(
		required string folderID, array tags,
		required string asUserID=""
	) output=false {
		local.return = updateFolder( argumentCollection = arguments );
		return local.return;
	}

	public any function updateFolder(
		required string folderID, string folderName, string parentID, array tags,
		required string asUserID=""
	) output=false {
		local.return = getFolderService().update( argumentCollection = arguments );
		return local.return;
	}

	public any function deleteFolder(
		required string folderID="0",
		required string asUserID=""
	) output=false {
		local.return = getFolderService().delete( argumentCollection = arguments );
		return local.return;
	}

	public any function getFolderCollaborations(
		required string folderID="0",
		required string asUserID=""
	) output=false {
		local.return = getFolderService().getCollaborations( argumentCollection = arguments );
		return local.return;
	}
	/* ------------------------------------------------------------------
	  --------------------------------USERS--------------------------------
	  ------------------------------------------------------------------*/

	public any function getUserInfo(
		required string userID,
		required string asUserID=""
	) output=false {
		local.return = getUserService().getInfo( argumentCollection = arguments );
		return local.return;
	}

	public any function getCurrentUserInfo(
		required string asUserID=""
	) output=false {
		local.return = getUserService().getCurrentUserInfo( argumentCollection = arguments );
		return local.return;
	}

	public any function createAppUser(
		required string userName,
		required string asUserID=""
	) output=false {
		local.return = getUserService().createAppUser( argumentCollection = arguments );
		return local.return;
	}
	/* -------------------------------------------------------------------
	  ----------------------------COLLABORATIONS----------------------------
	  -------------------------------------------------------------------*/

	public any function createCollaboration(
		required string itemBoxID,
		required string accessibleByBoxID,
		required string accessibleType="user",
		required string role="editor",
		required string asUserID=""
	) output=false {
		if ( !listFindNoCase("editor,viewer,previewer,uploader,previewer uploader,viewer uploader,co-owner", arguments.role) ) {
			throw( message="Arugment ""role"" was passed with an invalid value" );
		}
		if ( !listFindNoCase("user,group", arguments.accessibleType) ) {
			throw( message="Arugment ""accessibleType"" was passed with an invalid value" );
		}
		local.return = getCollaborationService().create( argumentCollection = arguments );
		return local.return;
	}
	/* -------------------------------------------------------------------
	  ----------------------------UPLOAD SESSION----------------------------
	  -------------------------------------------------------------------*/

	public any function getUploadSession(
		required string uploadSessionID,
		required string asUserID=""
	) output=false {
		local.return = getUploadSessionService().get( argumentCollection = arguments );
		return local.return;
	}

	public any function createUploadSession(
		required string fileName,
		required string filePath,
		required string ParentID="0",
		required string asUserID=""
	) output=false {
		local.fileInfo = getFileInfo(arguments.filePath);
		arguments.fileSize = local.fileInfo.size;
		local.return = getUploadSessionService().create( argumentCollection = arguments );
		return local.return;
	}

}
