CREATE TABLE boxApiLog (
	boxApiLogID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	url TEXT NOT NULL,
	method TEXT NOT NULL,
	getasbinary BIT NOT NULL,
	httpParams TEXT NULL,
	datetimeSent DATETIME NOT NULL,
	response TEXT NULL,
	responseCode TEXT NULL,
	datetimeReceived DATETIME NULL
);
