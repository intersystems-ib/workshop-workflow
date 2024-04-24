Class Workflow.Utils.Functions
{

/// Description
ClassMethod UserExists(username As %String, role As %String) As %Status
{
        new $NAMESPACE
        set $NAMESPACE = "%SYS"
        set userExists = ##class(Security.Users).Exists(username)
        if ('userExists) {
            set props("Enabled")=1
            set props("Name")=username
            set props("FullName")=""
            set props("SuperUser")=0
            set props("NameSpace")="WORKFLOW"
            set props("Roles")="%DB_WORKFLOW,%HS_DB_WORKFLOW"
            set props("Password")="SYS"
            set props("PasswordNeverExpires")=0
            set props("ChangePassword")=0
            set props("Routine")=""
            set props("ExpirationDate")=""
            set props("Flags")=1
            set props("EmailAddress")=""
            set status=##class(Security.Users).Create(username, .props)
            if $$$ISERR(status) {
                Return $$$ERROR(status)
            }
        }
        set sc = ..UserInRole(username,role) 
        if ($$$ISERR(sc)){
            Return $$$ERROR(sc)
        }
        Return $$$OK
}

ClassMethod UserInRole(username As %String, role As %String) As %Status
{
    set $NAMESPACE = "WORKFLOW"
    &sql(SELECT COUNT(*) INTO :userInRole FROM EnsLib_Workflow.UserDefinition WHERE ID = :username )

    if (SQLCODE<0) {
        Return $$$ERROR(%msg)
    }
    elseif (userInRole = 0)
    {
        set sc = ##class(EnsLib.Workflow.UserDefinition).CreateUser(username)
        if $$$ISERR(sc) {
            Return $$$ERROR(sc)
        }
    }
    
    set sc = ##class(EnsLib.Workflow.RoleDefinition).AddUserToRole(role, username)
    if $$$ISERR(sc) {
        Return $$$ERROR(sc)
    }

    &sql(SELECT COUNT(*) INTO :userInRole FROM EnsLib_Workflow.RoleMembership WHERE RoleName = :role AND UserName = :username )
    if (SQLCODE<0) {
        Return $$$ERROR(%msg)
    }
    elseif (userInRole = 0)
    {
        set sc = ##class(EnsLib.Workflow.RoleDefinition).AddUserToRole(role, username)
        if $$$ISERR(sc) {
            Return $$$ERROR(sc)
        }
    }
    Return $$$OK
}

ClassMethod CheckTask(username As %String, role As %String, Output task) As %Status
{
    set $NAMESPACE = "WORKFLOW"
    &sql(SELECT ID INTO :taskId FROM EnsLib_Workflow.TaskResponse WHERE TaskStatus_AssignedTo = :username AND TaskStatus_IsComplete = 0 AND %RoleName = :role)

    if (SQLCODE<0) {
        Return $$$ERROR(%msg)
    }
    elseif (SQLCODE = 100)
    {
        Return $$$ERROR("No pending tasks")
    }
    else {
        set task = ##class(EnsLib.Workflow.TaskResponse).%OpenId(taskId)
    }
        
    Return $$$OK
}

}
