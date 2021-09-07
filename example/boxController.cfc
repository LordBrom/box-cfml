component  {

	/**
	 *
	 */
	remote void function getFolderContents(string folderID) output=false {

		try {
			local.folderData = application.boxService.getFolderInfo( folderID = arguments.folderID );
			local.return = structNew();
			local.return.folderID = arguments.folderID;
			local.return.childArray = arrayNew(1);
			for ( local.folder in local.folderData.item_collection.entries ) {
				local.newFolder = structNew();
				local.newFolder.ID   = local.folder.ID;
				local.newFolder.name = local.folder.name;
				local.newFolder.type = local.folder.type;
				local.return.childarray.append(duplicate(local.newFolder));
			}
			wsSendMessage({type: 'setFolders', msg: '#serializeJSON(local.return)#'});
		} catch (any cfcatch) {
			wsSendMessage({type: 'error', msg: '#cfcatch#'});
		}
	}

}
