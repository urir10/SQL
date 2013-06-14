USE [TDIWEB]
GO

/****** Object:  StoredProcedure [dbo].[proc_UpdateSiteMapItem]    Script Date: 06/14/2013 11:14:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_UpdateSiteMapItem]
    @ID  as int,
    @Title as VARCHAR(50),
    @Description  as  VARCHAR(512),
    @Url as VARCHAR(512),
    @Roles as VARCHAR(512),
    @Parent as int
    
AS
BEGIN

 DECLARE @NewID  int
 DELETE FROM web_MenuRoles Where MenuID = @ID
 
 
 SET @NewID = (SELECT TOP 1 ID FROM (
				SELECT t1.Id+1 AS Id
				FROM [dbo].[SiteMap] t1
				WHERE NOT EXISTS(SELECT * FROM  [dbo].[SiteMap] t2 WHERE t2.Id = t1.Id + 1 )
				UNION 
				SELECT 1 AS Id
				WHERE NOT EXISTS (SELECT * FROM  [dbo].[SiteMap] t3 WHERE t3.Id = 1)) ot
				WHERE ID > @Parent
				ORDER BY 1)
				
UPDATE   [dbo].[SiteMap] 
SET ID=@NewID ,Title=@Title, Description=@Description,Url=@Url,Roles=@Roles ,Parent=@Parent
WHERE ID=@ID

UPDATE  [dbo].[SiteMap] 
SET Parent = @NewID 
WHERE Parent = @ID
 --Update all child nodes where ID is smaller than parent id
DECLARE @ItemId  int
DECLARE @ParentId  int
Declare c Cursor For Select Distinct ID,Parent From SiteMap
Open c
Fetch next From c into @ItemId,@ParentId
While @@Fetch_Status=0 Begin 
 UPDATE  [dbo].[SiteMap] 
SET ID = ( SELECT TOP 1 ID FROM (
				SELECT t1.Id+1 AS Id
				FROM [dbo].[SiteMap] t1
				WHERE NOT EXISTS(SELECT * FROM  [dbo].[SiteMap] t2 WHERE t2.Id = t1.Id + 1 )
				UNION 
				SELECT 1 AS Id
				WHERE NOT EXISTS (SELECT * FROM  [dbo].[SiteMap] t3 WHERE t3.Id = 1)) ot
				WHERE ID > @NewID
				ORDER BY 1)
 
		WHERE ID=@ItemId AND @ItemId<@ParentId AND @ParentId = @NewID 		
   Fetch next From c into @ItemId,@ParentId
End


Close c
Deallocate c 
 
 
 
 
 
SELECT @NewID 
END

GO


