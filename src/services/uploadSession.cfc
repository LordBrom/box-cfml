/**
 * Box service layer for upload session objects.
 */
component output="false" hint="Box service layer for upload session objects." {
	this.objectName = "files/upload_sessions";

	public uploadSession function init(
		boxAPIHandler boxAPIHandler
	) output=false {
		variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  );
		return this;
	}

	public struct function get(
		required string uploadSessionID,
		required string asUserID
	) output=false {
		local.httpMethod = "GET";
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.uploadSessionID,
			httpMethod = local.httpMethod,
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function listParts(
		required string uploadSessionID,
		required string asUserID
	) output=false {
		local.httpMethod = "GET";
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.uploadSessionID,
			method     = "list",
			httpMethod = local.httpMethod,
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function create(
		required string fileName,
		required numeric fileSize,
		required string filePath,
		required string ParentID,
		required string asUserID
	) output=false {
		local.jsonBody = structNew();
		local.jsonBody['file_name'] = arguments.fileName;
		local.jsonBody['file_size'] = arguments.fileSize;
		local.jsonBody['folder_id'] = arguments.ParentID;
		local.httpMethod = "POST";
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			httpMethod = local.httpMethod,
			jsonBody   = local.jsonBody,
			filePath   = arguments.filePath,
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

}
