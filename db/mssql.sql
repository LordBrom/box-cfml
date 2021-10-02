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
	[datetimeReceived] [datetime] NULL,
	CONSTRAINT [PK_boxApiLog] PRIMARY KEY CLUSTERED
					(
						[boxApiLogID] ASC
					)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
