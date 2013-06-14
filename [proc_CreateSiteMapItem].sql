USE [TDIWEB]
GO

/****** Object:  StoredProcedure [dbo].[proc_CreateSiteMapItem]    Script Date: 06/14/2013 11:12:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* SP Creates a new item in the site map. It will use the first available SiteMap ID as long as it is > than the selected parent*/
CREATE PROCEDURE [dbo].[proc_CreateSiteMapItem]
   
    @Title as VARCHAR(50),
    @Description  as  VARCHAR(512),
    @Url as VARCHAR(512),
    @Roles as VARCHAR(512),
    @Parent as int,
    @Report as char(10)
    
AS
BEGIN

 DECLARE @NewID  int
 
 SET @NewID = (SELECT TOP 1 ID FROM (
				SELECT t1.Id+1 AS Id
				FROM [dbo].[SiteMap] t1
				WHERE NOT EXISTS(SELECT * FROM  [dbo].[SiteMap] t2 WHERE t2.Id = t1.Id + 1 )
				UNION 
				SELECT 1 AS Id
				WHERE NOT EXISTS (SELECT * FROM  [dbo].[SiteMap] t3 WHERE t3.Id = 1)) ot
				WHERE ID > @Parent
				ORDER BY 1)
				
INSERT INTO [dbo].[SiteMap] 
(ID,Title,Description,Url,Roles,Parent,Report)
VALUES (@NewID,@Title,@Description,@URL,@Roles,@parent,@Report)

SELECT @NewID 
END


GO


