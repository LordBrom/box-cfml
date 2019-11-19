<cfcomponent name="boxFile" output="false" accessors="true" hint="Box file object">

	<cfproperty name="type"                type="string"  hint="[file]" />
	<cfproperty name="ID"                  type="string"  hint="The ID of the file object" />
	<cfproperty name="fileVersion"         type="object"  hint="The version information of the file" />
	<cfproperty name="sequenceID"          type="string"  hint="A unique ID for use with the [/events] endpoint" />
	<cfproperty name="etag"                type="string"  hint="The entity tag of this file object.  Used with [If-Match] <headers>." />
	<cfproperty name="sha1"                type="string"  hint="The <SHA-1> hash of this file" />
	<cfproperty name="name"                type="string"  hint="The name of this file" />
	<cfproperty name="description"         type="string"  hint="The description of this file" />
	<cfproperty name="size"                type="numeric" hint="Size of this file in bytes" />
	<cfproperty name="pathCollection"      type="object"  hint="The path of folders to this item, starting at the root" />
	<cfproperty name="createdAt"           type="date"    hint="When this file was created on Box's servers" />
	<cfproperty name="modifiedAt"          type="date"    hint="When this file was last updated on the Box servers. This is a read-only field." />
	<cfproperty name="trashedAt"           type="date"    hint="When this file was last moved to the trash" />
	<cfproperty name="purgedAt"            type="date"    hint="When this file will be permanently deleted" />
	<cfproperty name="contentCreatedAt"    type="date"    hint="When the content of this file was created (<more info>)" />
	<cfproperty name="contentModifiedAt"   type="date"    hint="When the content of this file was last modified (<more info>). This is a read-only field." />
	<cfproperty name="expiresAt"           type="date"    hint="When the file will automatically be deleted, i.e. expired. This attribute cannot be set." />
	<cfproperty name="createdBy"           type="struct"  hint="The user who first created this file" />
	<cfproperty name="modifiedBy"          type="struct"  hint="The user who last updated this file" />
	<cfproperty name="ownedBy"             type="struct"  hint="The user who owns this file" />
	<cfproperty name="sharedLink"          type="object"  hint="The <shared link object> for this file.  Will be [null] if no shared link has been created." />
	<cfproperty name="parent"              type="struct"  hint="The folder containing this file" />
	<cfproperty name="itemStatus"          type="string"  hint="Whether this item is deleted or not. Values include [active], [trashed] if the file has been moved to the trash, and [deleted] if the file has been permanently deleted" />
	<cfproperty name="versionNumber"       type="string"  hint="The version number of this file" />
	<cfproperty name="commentCount"        type="numeric" hint="The number of comments on this file" />
	<cfproperty name="permissions"         type="object"  hint="An object containing the permissions that the current user has on this file. The keys are [can_download], [can_preview], [can_upload], [can_comment], [can_annotate], [can_rename],  [can_invite_collaborator],[can_delete], [can_share], and [can_set_share_access]. Each key has a boolean value." />
	<cfproperty name="tags"                type="array"   hint="All tags applied to this file" />
	<cfproperty name="lock"                type="object"  hint="The lock held on this file. If there is no lock, this can either be [null] or have a timestamp in the past." />
	<cfproperty name="extension"           type="string"  hint="Indicates the suffix, when available, on the file. By default, set to an empty string. The suffix usually indicates the encoding (file format) of the file contents or usage." />
	<cfproperty name="isPackage"           type="boolean" hint="Whether the file is a package. Used for Mac Packages used by iWorks." />
	<cfproperty name="expiringEmbedLink"   type="string"  hint="An expiring URL for an embedded preview session in an iframe. This URL will expire after 60 seconds and the session will expire after 60 minutes." />
	<cfproperty name="watermarkInfo"       type="object"  hint="Information about the watermark status of this file. See <Watermarking> for additional endpoints." />
	<cfproperty name="allowedInviteeRoles" type="array"   hint="File <collaboration> roles allowed by the enterprise administrator." />
	<cfproperty name="isExternallyOwned"   type="boolean" hint="Whether this file is owned by a user outside of the enterprise." />
	<cfproperty name="hasCollaborations"   type="boolean" hint="Whether this file has any collaborators." />
	<cfproperty name="metadata"            type="object"  hint="Specific metadata on the file, identified by [scope] and [templateKey]. The limit of metadata instances to be requested this way is 3." />

	<cffunction name="init" returntype="boxFile" access="public" output="false" hint="Constructor">
		<cfargument name="apiBoxFileResponseData" type="struct" required="true" hint="The object returned from the boxAPIHandler.makeRequest() function." />

		<cfif structKeyExists(arguments.apiBoxFileResponseData, "type")>
			<cfset setType(arguments.apiBoxFileResponseData.type) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "id")>
			<cfset setID(arguments.apiBoxFileResponseData.id) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "file_version")>
			<cfset setFileVersion(arguments.apiBoxFileResponseData.file_version) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "sequence_id")>
			<cfset setSequenceID(arguments.apiBoxFileResponseData.sequence_id) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "etag")>
			<cfset setEtag(arguments.apiBoxFileResponseData.etag) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "sha1")>
			<cfset setSha1(arguments.apiBoxFileResponseData.sha1) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "name")>
			<cfset setName(arguments.apiBoxFileResponseData.name) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "description")>
			<cfset setDescription(arguments.apiBoxFileResponseData.description) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "size")>
			<cfset setSize(arguments.apiBoxFileResponseData.size) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "path_collection")>
			<cfset setPathCollection(arguments.apiBoxFileResponseData.path_collection) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "created_at")>
			<cfset setCreatedAt(arguments.apiBoxFileResponseData.created_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "modified_at")>
			<cfset setModifiedAt(arguments.apiBoxFileResponseData.modified_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "trashed_at")>
			<cfset setTrashedAt(arguments.apiBoxFileResponseData.trashed_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "purged_at")>
			<cfset setPurgedAt(arguments.apiBoxFileResponseData.purged_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "content_created_at")>
			<cfset setContentCreatedAt(arguments.apiBoxFileResponseData.content_created_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "content_modified_at")>
			<cfset setContentModifiedAt(arguments.apiBoxFileResponseData.content_modified_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "expires_at")>
			<cfset setExpiresAt(arguments.apiBoxFileResponseData.expires_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "created_by")>
			<cfset setCreatedBy(arguments.apiBoxFileResponseData.created_by) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "modified_by")>
			<cfset setModifiedBy(arguments.apiBoxFileResponseData.modified_by) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "owned_by")>
			<cfset setOwnedBy(arguments.apiBoxFileResponseData.owned_by) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "shared_link")>
			<cfset setSharedLink(arguments.apiBoxFileResponseData.shared_link) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "parent")>
			<cfset setParent(arguments.apiBoxFileResponseData.parent) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "item_status")>
			<cfset setItemStatus(arguments.apiBoxFileResponseData.item_status) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "version_number")>
			<cfset setVersionNumber(arguments.apiBoxFileResponseData.version_number) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "comment_count")>
			<cfset setCommentCount(arguments.apiBoxFileResponseData.comment_count) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "permissions")>
			<cfset setPermissions(arguments.apiBoxFileResponseData.permissions) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "tags")>
			<cfset setTags(arguments.apiBoxFileResponseData.tags) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "lock")>
			<cfset setLock(arguments.apiBoxFileResponseData.lock) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "extension")>
			<cfset setExtension(arguments.apiBoxFileResponseData.extension) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "is_package")>
			<cfset setIsPackage(arguments.apiBoxFileResponseData.is_package) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "expiring_embed_link")>
			<cfset setExpiringEmbedLink(arguments.apiBoxFileResponseData.expiring_embed_link) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "watermark_info")>
			<cfset setWatermarkInfo(arguments.apiBoxFileResponseData.watermark_info) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "allowed_invitee_roles")>
			<cfset setAllowedInviteeRoles(arguments.apiBoxFileResponseData.allowed_invitee_roles) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "is_externally_owned")>
			<cfset setIsExternallyOwned(arguments.apiBoxFileResponseData.is_externally_owned) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "has_collaborations")>
			<cfset setHasCollaborations(arguments.apiBoxFileResponseData.has_collaborations) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFileResponseData, "metadata")>
			<cfset setMetadata(arguments.apiBoxFileResponseData.metadata) />
		</cfif>

		<cfreturn this />
	</cffunction>

</cfcomponent>