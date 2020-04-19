var $container = $("#container");

var parseMessage = function(wsPackage) {
	var data = wsPackage.data;
	switch (data?.TYPE) {
		case "error":
			console.error(data.MSG);
			break;
		case "log":
			console.log(data.MSG);
			break;


		case "setFolders":
			var folderData = JSON.parse(data.MSG);
			setFolders(folderData.FOLDERID, folderData.CHILDARRAY);
			break;

		default:
			break;
	}
}

var getFolderContents = function(folderID) {
	ws.invoke("boxController", "getFolderContents", [folderID]);
}


var setFolders = function(folderID, childArray) {
	var $folderRow = $(`.folder_${folderID}`);
	var $childRow = $(`.childContainer_${folderID}`);

	if (childArray.length == 0) {
		$childRow.append($(`<li>No Items</li>`));
	}

	for (var i = 0; i < childArray.length; i++) {
		var child = childArray[i];
		if (child.TYPE == 'folder') {
			$childRow.append($(`<li class="folder folder_${child.ID}" onclick="showChildren(${child.ID})">${child.NAME}</li>`));
			$childRow.append($(`<ul class="childContainer childContainer_${child.ID}"></ul>`));
		} else {
			$childRow.append($(`<li class="file">${child.NAME}</li>`));
		}
	}

	$folderRow.addClass('loaded');
	$folderRow.addClass('open');
	$childRow.addClass('open');
}


var showChildren = function(folderID) {

	var $folderRow = $(`.folder_${folderID}`);
	var $childRow = $(`.childContainer_${folderID}`);

	if ($folderRow.hasClass('open')) {
		$folderRow.removeClass('open');
		$childRow.removeClass('open');
		return;
	}


	if (!$folderRow.hasClass('loaded')) {
		getFolderContents(folderID);
	} else {
		$folderRow.addClass('open');
		$childRow.addClass('open');
	}
}
