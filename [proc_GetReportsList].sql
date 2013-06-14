USE [TDIWEB]
GO

/****** Object:  StoredProcedure [dbo].[proc_GetReportsList]    Script Date: 06/14/2013 11:14:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_GetReportsList]
	 @Type as CHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Get all roles for each menu and build a Hierachy of inherited roles
	
;with Hierachy( RoleID,NestedRole,MenuID) 
	as
	(
		select  M.RoleID,NestedRole,M.MenuID
		from  [dbo].web_NestedRoles N RIGHT JOIN web_MenuRoles M ON M.RoleId=N.NestedRole
		union all
		select  N.RoleID,N.NestedRole,ch.MenuID
		from  [dbo].web_NestedRoles N
		inner join Hierachy ch 
		on ch.RoleID = N.NestedRole 
		
		)
		
		SELECT 
		--S1.[ID] as menuid, S1.[Title] as menutitle, S1.[Description] as menudesc,
		S1.[ID] as menuid, REVERSE(SUBSTRING(REVERSE(S1.URL),0,charindex('=',REVERSE(S1.URL)))) as menutitle, S1.[Description] as menudesc,
		CASE WHEN web_MenuRoles.[Roles] IS NULL THEN '*' ELSE  web_MenuRoles.[Roles] END as Roles, 
		CASE WHEN S1.URL IS NULL THEN 'Parent' ELSE 'Child' END AS NodeType ,
		S1.Parent as ParentID, S2.Title as groupname
		FROM SiteMap S1
		LEFT JOIN (
                Select distinct H2.MenuID,substring((Select ', '+A.RoleName  AS [text()]
				from Hierachy H1 INNER JOIN aspnet_Roles A on A.RoleID = H1.RoleId
				Where H1.MenuID = H2.MenuID
				ORDER BY H1.MenuID
				For XML PATH ('')),2, 1000) Roles
				From Hierachy H2
                )  web_MenuRoles
         ON web_MenuRoles.MenuId = S1.ID   LEFT JOIN SiteMap S2 ON  S2.ID=S1.Parent
         WHERE S1.ID <> 1 and S1.Report = @Type
		 ORDER BY s1.[Description],REVERSE(SUBSTRING(REVERSE(S1.URL),0,charindex('=',REVERSE(S1.URL))))   
            
END


GO


