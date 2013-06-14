USE [TDIWEB]
GO

/****** Object:  StoredProcedure [dbo].[proc_GetSiteMap]    Script Date: 06/14/2013 11:14:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_GetSiteMap] AS
   /*ORIGINAL CODE */
   /* SELECT [ID], [Title], [Description], [Url], [Roles], [Parent]
    FROM [SiteMap] ORDER BY [ID]*/



SELECT [ID], [Title], [Description], [Url],web_MenuRoles.[Roles], [Parent]
    FROM [dbo].[SiteMap] 
    LEFT JOIN (Select distinct M2.MenuID, 
               substring((Select ','+A.RoleName  AS [text()]
                From dbo.web_MenuRoles M1 INNER JOIN [dbo].aspnet_Roles A on A.RoleID = M1.RoleId
                Where M1.MenuID = M2.MenuID
                ORDER BY M1.MenuID
                For XML PATH ('')),2, 1000) Roles
                From dbo.web_MenuRoles M2)  web_MenuRoles
         ON web_MenuRoles.MenuId = dbo.SiteMap.ID 
    
    
     ORDER BY [ID] 
GO


