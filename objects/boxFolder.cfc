<cfcomponent name="boxFolder" output="false" accessors="true" hint="Box folder object">

	<cfproperty name="type"                                  type="string"  hint="[folder]"                                                                                                                                                                                                                                               />
	<cfproperty name="ID"                                    type="string"  hint="The ID of the folder object."                                                                                                                                                                                                                           />
	<cfproperty name="sequenceID"                            type="string"  hint="A unique ID for use with the [/events] endpoint.<br> May be [null] for some folders, such as root or trash."                                                                                                                                            />
	<cfproperty name="etag"                                  type="string"  hint="The entity tag of this folder object. Used with If-Match <headers>.  May be [null] for some folders such as root or trash."                                                                                                                             />
	<cfproperty name="name"                                  type="string"  hint="The name of the folder."                                                                                                                                                                                                                                />
	<cfproperty name="createdAt"                             type="date"    hint="The time the folder was created.  May be [null] for some folders such as root or trash."                                                                                                                                                                />
	<cfproperty name="modifiedAt"                            type="date"    hint="When this folder was last updated on the Box servers. This is a read-only field."                                                                                                                                                                       />
	<cfproperty name="description"                           type="string"  hint="The description of the folder. The limit is 256 characters."                                                                                                                                                                                            />
	<cfproperty name="size"                                  type="numeric" hint="The folder size in bytes. Be careful parsing this integer, it can easily go into EE notation: see <IEEE754 format>."                                                                                                                                    />
	<cfproperty name="pathCollection"                        type="struct"  hint="The path of folders to this folder, starting at the root."                                                                                                                                                                                              />
	<cfproperty name="createdBy"                             type="struct"  hint="The user who created this folder."                                                                                                                                                                                                                      />
	<cfproperty name="modifiedBy"                            type="struct"  hint="The user who last modified this folder."                                                                                                                                                                                                                />
	<cfproperty name="trashedAt"                             type="date"    hint="The time the folder or its contents were put in the trash.  May be [null] for some folders such as root or trash."                                                                                                                                      />
	<cfproperty name="purgedAt"                              type="date"    hint="The time the folder or its contents will be purged from the trash.  May be [null] for some folders such as root or trash."                                                                                                                              />
	<cfproperty name="contentCreatedAt"                      type="date"    hint="The time the folder or its contents were originally created (according to the uploader).  May be [null] for some folders such as root or trash."                                                                                                        />
	<cfproperty name="contentModifiedAt"                     type="date"    hint="The time the folder or its contents were last modified (according to the uploader).  May be [null] for some folders such as root or trash."                                                                                                             />
	<cfproperty name="expiresAt"                             type="date"    hint="When the folder will automatically be deleted, i.e. expired. This attribute cannot be set."                                                                                                                                                             />
	<cfproperty name="ownedBy"                               type="struct"  hint="The user who owns this folder."                                                                                                                                                                                                                         />
	<cfproperty name="sharedLink"                            type="object"  hint="The <shared link object> for this file.  Will be [null] if no shared link has been created."                                                                                                                                                            />
	<cfproperty name="folderUploadEmail"                     type="object"  hint="The upload email address for this folder. [null] if not set."                                                                                                                                                                                           />
	<cfproperty name="parent"                                type="struct"  hint="The folder that contains this folder.<br> May be [null] for folders such as root, trash and child folders whose parent is inaccessible."                                                                                                                />
	<cfproperty name="itemStatus"                            type="string"  hint="Whether this item is deleted or not. Values include [active], [trashed] if the item has been moved to the trash, and [deleted] if the item has been permanently deleted."                                                                               />
	<cfproperty name="itemCollection"                        type="struct"  hint="A collection of mini file and folder objects contained in this folder."                                                                                                                                                                                 />
	<cfproperty name="syncState"                             type="string"  hint="Whether this folder will be synced by the Box sync clients or not. Can be [synced], [not_synced], or [partially_synced]."                                                                                                                               />
	<cfproperty name="hasCollaborations"                     type="boolean" hint="Whether this folder has any collaborators."                                                                                                                                                                                                             />
	<cfproperty name="permissions"                           type="object"  hint="An object containing the permissions that the current user has on this folder. The keys are [can_download], [can_upload], [can_rename], [can_delete], [can_share], [can_invite_collaborator], and [can_set_share_access]. Each key has a boolean value."/>
	<cfproperty name="tags"                                  type="array"   hint="All tags applied to this folder."                                                                                                                                                                                                                       />
	<cfproperty name="canNonOwnersInvite"                    type="boolean" hint="Whether non-owners can invite collaborators to this folder."                                                                                                                                                                                            />
	<cfproperty name="isExternallyOwned"                     type="boolean" hint="Whether this folder is owned by a user outside of the enterprise."                                                                                                                                                                                      />
	<cfproperty name="isCollaborationRestrictedToEnterprise" type="boolean" hint="Whether future collaborations should be restricted to within the enterprise only."                                                                                                                                                                      />
	<cfproperty name="allowedSharedLinkAccessLevels"         type="array"   hint="Access level settings for shared links set by administrator. Can include [open], [company], or [collaborators]."                                                                                                                                        />
	<cfproperty name="allowedInviteeRoles"                   type="array"   hint="Folder <collaboration> roles allowed by the enterprise administrator."                                                                                                                                                                                  />
	<cfproperty name="watermarkInfo"                         type="object"  hint="Information about the watermark status of this folder. See <Watermarking> for additional endpoints.</p><p>Fields:<br>[is_watermarked] (boolean): Whether the folder is watermarked or not."                                                             />
	<cfproperty name="metadata"                              type="object"  hint="Specific metadata on the folder, identified by [scope] and [templateKey]. The limit of metadata instances to be requested this way is 3.</p></div></div></div>"                                                                                         />

	<cffunction name="init" returntype="boxFolder" access="public" output="false" hint="Constructor">
		<cfargument name="apiBoxFolderResponseData" type="struct" required="true" hint="The object returned from the boxAPIHandler.makeRequest() function." />

		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "type") >
			<cfset setType(arguments.apiBoxFolderResponseData.type) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "id") >
			<cfset setID(arguments.apiBoxFolderResponseData.id) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "sequence_id") >
			<cfset setSequenceID(arguments.apiBoxFolderResponseData.sequence_id) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "etag") >
			<cfset setEtag(arguments.apiBoxFolderResponseData.etag) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "name") >
			<cfset setName(arguments.apiBoxFolderResponseData.name) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "created_at") >
			<cfset setCreatedAt(arguments.apiBoxFolderResponseData.created_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "modified_at") >
			<cfset setModifiedAt(arguments.apiBoxFolderResponseData.modified_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "description") >
			<cfset setDescription(arguments.apiBoxFolderResponseData.description) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "size") >
			<cfset setSize(arguments.apiBoxFolderResponseData.size) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "path_collection") >
			<cfset setPathCollection(arguments.apiBoxFolderResponseData.path_collection) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "created_by") >
			<cfset setCreatedBy(arguments.apiBoxFolderResponseData.created_by) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "modified_by") >
			<cfset setModifiedBy(arguments.apiBoxFolderResponseData.modified_by) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "trashed_at") >
			<cfset setTrashedAt(arguments.apiBoxFolderResponseData.trashed_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "purged_at") >
			<cfset setPurgedAt(arguments.apiBoxFolderResponseData.purged_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "content_created_at") >
			<cfset setContentCreatedAt(arguments.apiBoxFolderResponseData.content_created_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "content_modified_at") >
			<cfset setContentModifiedAt(arguments.apiBoxFolderResponseData.content_modified_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "expires_at") >
			<cfset setExpiresAt(arguments.apiBoxFolderResponseData.expires_at) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "owned_by") >
			<cfset setOwnedBy(arguments.apiBoxFolderResponseData.owned_by) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "shared_link") >
			<cfset setSharedLink(arguments.apiBoxFolderResponseData.shared_link) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "folder_upload_email") >
			<cfset setFolderUploadEmail(arguments.apiBoxFolderResponseData.folder_upload_email) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "parent") >
			<cfset setParent(arguments.apiBoxFolderResponseData.parent) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "item_status") >
			<cfset setItemStatus(arguments.apiBoxFolderResponseData.item_status) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "item_collection") >
			<cfset setItemCollection(arguments.apiBoxFolderResponseData.item_collection) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "sync_state") >
			<cfset setSyncState(arguments.apiBoxFolderResponseData.sync_state) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "has_collaborations") >
			<cfset setHasCollaborations(arguments.apiBoxFolderResponseData.has_collaborations) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "permissions") >
			<cfset setPermissions(arguments.apiBoxFolderResponseData.permissions) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "tags") >
			<cfset setTags(arguments.apiBoxFolderResponseData.tags) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "can_non_owners_invite") >
			<cfset setCanNonOwnersInvite(arguments.apiBoxFolderResponseData.can_non_owners_invite) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "is_externally_owned") >
			<cfset setIsExternallyOwned(arguments.apiBoxFolderResponseData.is_externally_owned) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "is_collaboration_restricted_to_enterprise") >
			<cfset setIsCollaborationRestrictedToEnterprise(arguments.apiBoxFolderResponseData.is_collaboration_restricted_to_enterprise) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "allowed_shared_link_access_levels") >
			<cfset setAllowedSharedLinkAccessLevels(arguments.apiBoxFolderResponseData.allowed_shared_link_access_levels) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "allowed_invitee_roles") >
			<cfset setAllowedInviteeRoles(arguments.apiBoxFolderResponseData.allowed_invitee_roles) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "watermark_info") >
			<cfset setWatermarkInfo(arguments.apiBoxFolderResponseData.watermark_info) />
		</cfif>
		<cfif structKeyExists(arguments.apiBoxFolderResponseData, "metadata") >
			<cfset setMetadata(arguments.apiBoxFolderResponseData.metadata) />
		</cfif>

		<cfreturn this />
	</cffunction>

</cfcomponent>