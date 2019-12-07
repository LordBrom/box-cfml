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
		<cfargument name="fileData" type="struct" required="true" default="#structNew()#" hint="The object returned from the boxAPIHandler.makeRequest() function." />

		<cfset setType(               arguments.fileData?.type                 ) />
		<cfset setID(                 arguments.fileData?.id                   ) />
		<cfset setFileVersion(        arguments.fileData?.file_version         ) />
		<cfset setSequenceID(         arguments.fileData?.sequence_id          ) />
		<cfset setEtag(               arguments.fileData?.etag                 ) />
		<cfset setSha1(               arguments.fileData?.sha1                 ) />
		<cfset setName(               arguments.fileData?.name                 ) />
		<cfset setDescription(        arguments.fileData?.description          ) />
		<cfset setSize(               arguments.fileData?.size                 ) />
		<cfset setPathCollection(     arguments.fileData?.path_collection      ) />
		<cfset setCreatedAt(          arguments.fileData?.created_at           ) />
		<cfset setModifiedAt(         arguments.fileData?.modified_at          ) />
		<cfset setTrashedAt(          arguments.fileData?.trashed_at           ) />
		<cfset setPurgedAt(           arguments.fileData?.purged_at            ) />
		<cfset setContentCreatedAt(   arguments.fileData?.content_created_at   ) />
		<cfset setContentModifiedAt(  arguments.fileData?.content_modified_at  ) />
		<cfset setExpiresAt(          arguments.fileData?.expires_at           ) />
		<cfset setCreatedBy(          arguments.fileData?.created_by           ) />
		<cfset setModifiedBy(         arguments.fileData?.modified_by          ) />
		<cfset setOwnedBy(            arguments.fileData?.owned_by             ) />
		<cfset setSharedLink(         arguments.fileData?.shared_link          ) />
		<cfset setParent(             arguments.fileData?.parent               ) />
		<cfset setItemStatus(         arguments.fileData?.item_status          ) />
		<cfset setVersionNumber(      arguments.fileData?.version_number       ) />
		<cfset setCommentCount(       arguments.fileData?.comment_count        ) />
		<cfset setPermissions(        arguments.fileData?.permissions          ) />
		<cfset setTags(               arguments.fileData?.tags                 ) />
		<cfset setLock(               arguments.fileData?.lock                 ) />
		<cfset setExtension(          arguments.fileData?.extension            ) />
		<cfset setIsPackage(          arguments.fileData?.is_package           ) />
		<cfset setExpiringEmbedLink(  arguments.fileData?.expiring_embed_link  ) />
		<cfset setWatermarkInfo(      arguments.fileData?.watermark_info       ) />
		<cfset setAllowedInviteeRoles(arguments.fileData?.allowed_invitee_roles) />
		<cfset setIsExternallyOwned(  arguments.fileData?.is_externally_owned  ) />
		<cfset setHasCollaborations(  arguments.fileData?.has_collaborations   ) />
		<cfset setMetadata(           arguments.fileData?.metadata             ) />

		<cfreturn this />
	</cffunction>

</cfcomponent>