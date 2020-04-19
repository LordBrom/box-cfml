<cfsilent>
	<cfparam name="url.folderID" default="0" />

</cfsilent>
<!DOCTYPE html>
<html>
<head>
	<title>Box Drive API Example</title>

	<!--- <link rel="stylesheet" type="text/css" href="bootstrap.min.css"> --->
	<link rel="stylesheet" type="text/css" href="style.css">

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
	<script src="script.js"></script>

</head>
<body>
	<cfoutput>
		<div id="container" class="folder_#url.folderID#">
			<ul class="childContainer childContainer_#url.folderID#"></ul>
		</div>



	</cfoutput>
	<cfwebsocket name="ws"
				 onmessage="parseMessage"
				 subscribeto="box" />
</body>
</html>


