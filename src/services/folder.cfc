/**
 * Box service layer for folder objects.
 */
component output="false" hint="Box service layer for folder objects." {
	this.objectName = "folders";

	public folder function init(
		boxAPIHandler boxAPIHandler
	) output=false {
		variables.boxAPIHandler = arguments?.boxAPIHandler ?: createObject("component", "boxAPI.src.boxAPIHandler").init(  );
		return this;
	}

	public any function create(
		required string folderName,
		required string ParentID,
		required string asUserID
	) output=false {
		local.jsonBody = structNew();
		local.jsonBody['name']   = arguments.folderName;
		local.jsonBody['parent'] = structNew();
		local.jsonBody['parent']['id'] = arguments.ParentID;
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public struct function copy(
		required string folderName,
		required string ParentID,
		required string SourceID,
		required string asUserID
	) output=false {
		local.jsonBody = structNew();
		local.jsonBody['name']   = arguments.folderName;
		local.jsonBody['parent'] = structNew();
		local.jsonBody['parent']['id'] = arguments.ParentID;
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = SourceID,
			method     = "copy",
			jsonBody   = local.jsonBody,
			httpMethod = "POST",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public any function getContents(
		required string folderID,
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			method     = "items",
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public any function getInfo(
		required string folderID,
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		//  <cfset local.boxFolder = createObject("component", "objects.boxFolder").init(local.apiResponse) />
		return local.apiResponse;
	}

	public any function update(
		required string folderID,
		string folderName,
		string parentID,
		array tags,
		required string asUserID
	) output=false {
		local.jsonBody = structNew();
		if ( structKeyExists(arguments, "folderName") && len(arguments.folderName) ) {
			local.jsonBody['name']   = arguments.folderName;
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
			objectID   = arguments.folderID,
			httpMethod = "PUT",
			jsonBody   = local.jsonBody,
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

	public any function delete(
		required string folderID,
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object      = this.objectName,
			objectID    = arguments.folderID,
			queryParams = "recursive=true",
			httpMethod  = "DELETE",
			userID      = arguments.asUserID
		);
		return local.apiResponse;
	}

	public any function getCollaborations(
		required string folderID,
		required string asUserID
	) output=false {
		local.apiResponse = variables.boxAPIHandler.makeRequest(
			object     = this.objectName,
			objectID   = arguments.folderID,
			method     = "collaborations",
			httpMethod = "GET",
			userID     = arguments.asUserID
		);
		return local.apiResponse;
	}

}
