USE [TDIWEB]
GO

/****** Object:  StoredProcedure [dbo].[aspnet_UsersInRoles_IsUserInRole]    Script Date: 06/14/2013 11:02:41 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



/* This StoredProcedure is a modified asp membership SP. It has been modified to support a herachy of Roles, 
	meaning that a Role can inherit access from other Roles in the table 
	This SP check if  the user is in a given Role or if he is in a role that inherits access from another role
	*/
	
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_IsUserInRole]
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(2)
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    DECLARE @RoleId uniqueidentifier
    SELECT  @RoleId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.aspnet_Users
    WHERE   LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

    IF (@UserId IS NULL)
        RETURN(2)

    SELECT  @RoleId = RoleId
    FROM    dbo.aspnet_Roles
    WHERE   LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId

    IF (@RoleId IS NULL)
        RETURN(3)

	-----------------------------------------------------------------------------------------------
	DECLARE @HierachyExists bit; --Variable is 1 if the node is a nested node
	SET @HierachyExists = 0;
	with Hierachy( RoleID,NestedRole) --build hierachy based on child role @RoleName
	as
	(
	select  RoleID,NestedRole
		from  [dbo].web_NestedRoles N
		where N.NestedRole = @RoleId -- insert parameter here
		union all
		select  N.RoleID,N.NestedRole
		from  [dbo].web_NestedRoles N
		inner join Hierachy ch 
		on ch.RoleID = N.NestedRole
	    

	)
	select  TOP 1 @HierachyExists = 1 --If user is assigned to any parent node set to TRUE
	from Hierachy H 
	WHERE H.RoleID IN  (SELECT aspnet_Roles.RoleId FROM aspnet_Roles INNER JOIN aspnet_UsersInRoles ON aspnet_Roles.RoleID = aspnet_UsersInRoles.RoleID AND aspnet_UsersInRoles.UserId=@UserId)
	-----------------------------------------------------------------------------------------------
	
    IF (EXISTS( SELECT * FROM dbo.aspnet_UsersInRoles WHERE  UserId = @UserId AND RoleId = @RoleId))
        RETURN(1) -- If role assigned directly to user
    ELSE IF(@HierachyExists=1)
		RETURN(1) --if role is a nested role of the assigned user role
    ELSE
        RETURN(0)
END

GO


