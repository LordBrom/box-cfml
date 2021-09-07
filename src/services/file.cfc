/**
 * Box service layer for file objects.
 */
component output="false" hint="Box service layer for file objects." {
	this.objectName = "files";

	public file function init(boxAPIHandler boxAPIHandler) output=false {
		variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  );
		return this;
	}

	public struct function upload(required string fileName, required string filePath, required string ParentID, required string fileID, required boolean preflight, required string asUserID) output=false {
		local.boxID = "";
		local.jsonBody = structNew();
		local.jsonBody['name']   = arguments.fileName;
		local.jsonBody['parent'] = structNew();
		local.jsonBody['parent']['id'] = arguments.ParentID;
		local.httpMethod = (arguments.preflight) ? "OPTIONS" : "POST";
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "content",
			jsonBody   = local.jsonBody,
			httpMethod = local.httpMethod,
			userID     = arguments.asUserID,
			filePath   = arguments.filePath
		);
		return local.apiResponse;
	}

	public struct function download(required string fileID, required string asUserID) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "content",
			httpMethod = "GET",
			userID     = arguments.asUserID,
			getasbinary = "YES"
		);
		return local.apiResponse;
	}

	public struct function getInfo(required string fileID, required string asUserID) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function update(required string fileID, string fileName, string parentID, array tags, required string asUserID) output=false {
		local.return = structNew();
		local.jsonBody = structNew();
		if ( structKeyExists(arguments, "fileName") && len(arguments.fileName) ) {
			local.jsonBody['name']   = arguments.fileName;
		}
		if ( structKeyExists(arguments, "parentID") && len(arguments.parentID) ) {
			local.jsonBody['parent'] = structNew();
			local.jsonBody['parent']['id'] = arguments.ParentID;
		}
		if ( structKeyExists(arguments, "tags") && arrayLen(arguments.tags) ) {
			local.jsonBody['tags'] = arguments.tags;
		}
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			httpMethod = "PUT",
			jsonBody   = local.jsonBody,
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function delete(required string fileID, required string asUserID) output=false {
		local.return = structNew();
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			httpMethod = "DELETE",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function copy(required string fileName, required string ParentID, required string SourceID, required string asUserID) output=false {
		local.boxID = "";
		local.jsonBody = structNew();
		local.jsonBody['name']   = arguments.fileName;
		local.jsonBody['parent'] = structNew();
		local.jsonBody['parent']['id'] = arguments.ParentID;
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "copy",
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function getCollaborations(required string fileID, required string asUserID) output=false {
		local.return = structNew();
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "collaborations",
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function createUploadSession(required string fileID, required string asUserID) output=false {
		local.return = structNew();
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "upload_sessions",
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}
	/* ------------------------------------------------------------------
	  --------------------------VERSION FUNCTIONS--------------------------
	  ------------------------------------------------------------------*/

	public struct function ListVersions(required string fileID, required string asUserID) output=false {
		local.return = structNew();
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions",
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function getVersion(required string fileID, required string versionID, required string asUserID) output=false {
		local.return = structNew();
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions/#arguments.versionID#",
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function revertVersion(required string fileID, required string versionID, required string asUserID) output=false {
		local.return = structNew();
		local.jsonBody = structNew();
		local.jsonBody['type'] = "file_version";
		local.jsonBody['id'] = arguments.versionID;
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions/current",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function deleteVersion(required string fileID, required string versionID, required string asUserID) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.fileID,
			method     = "versions/#arguments.versionID#",
			httpMethod = "DELETE",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

}
