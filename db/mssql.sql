CREATE TABLE [dbo].[boxApiLog]
(
	[boxApiLogID] [int] IDENTITY(1,1) NOT NULL,
	[url] [varchar](max) NOT NULL,
	[method] [varchar](max) NOT NULL,
	[getasbinary] [bit] NOT NULL,
	[httpParams] [varchar](max) NULL,
	[datetimeSent] [datetime] NOT NULL,
	[response] [text] NULL,
	[responseCode] [varchar](50) NULL,
	[datetimeReceived] [datetime] NULL
)
