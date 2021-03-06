function Disable-Inheritance {

    <#
    .SYNOPSIS
    Removes permissions inheritance from a directory.
    .EXAMPLE
    Disable-Inheritance -Path C:\Files\
    .PARAMETER Path
    Location of the directory from which to remove inheritance.
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Path
    )

    $acl = (Get-Item $path).getAccessControl("Access")
    
    if ($acl.AreAccessRulesProtected -eq $false) {

        Write-Output "$path is inheriting permissions - removing inheritance"
        
        $acl.SetAccessRuleProtection($True,$True)
        Set-ACL -Path $path -AclObject $acl
    
    }
    else {
    
        Write-Output "$path is not inheriting permissions"
    
    }

}

function Revoke-Permissions {

    <#
    .SYNOPSIS
    Removes the permissions of a given security principal or user account from a directory.
    .EXAMPLE
    Revoke-Permissions -SecurityPrincipal MARS\SuperUser -Path C:\Files\
    .PARAMETER SecurityPrincipal
    Security principal or account from which to remove permissions. Should be in the format DOMAIN\User.
    .PARAMETER Path
    Location of the directory from which to remove permissions.
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$SecurityPrincipal,

        [parameter(Mandatory=$true)]
        [string]$Path
    )

    $pathRights = [System.Security.AccessControl.FileSystemRights]"Read"

    $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $propagationFlag = [System.Security.AccessControl.PropagationFlags]"None"
    
    $objType = [System.Security.AccessControl.AccessControlType]::Allow
    
    $objUser = New-Object System.Security.Principal.NTAccount($SecurityPrincipal)

    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $pathRights, $inheritanceFlag, $propagationFlag, $objType)

    $objACL = (Get-Item $path).getAccessControl("Access")
    
    $objACL.RemoveAccessRuleAll($objACE)

    Set-ACL -Path $path -AclObject $objACL

}

function Grant-Permissions {

    <#
    .SYNOPSIS
    Grants permissions to a given security principal or user account to a directory.
    .EXAMPLE
    Grant-Permissions -SecurityPrincipal MARS\SuperUser -Path C:\Files\ -Permissions "Read,ReadAndExecute,Write"
    .PARAMETER SecurityPrincipal
    Security principal or account for which to grant permissions. Should be in the format DOMAIN\User.
    .PARAMETER Path
    Location of the directory from which to grant permissions.
    .PARAMETER Permissions
    Permissions to grant in comma delimited format.
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$SecurityPrincipal,

        [parameter(Mandatory=$true)]
        [string]$Path,

        [parameter(Mandatory=$true)]
        [string]$Permissions
    )

    $pathRights = [System.Security.AccessControl.FileSystemRights]$permissions

    $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $propagationFlag = [System.Security.AccessControl.PropagationFlags]"None"
    
    $objType = [System.Security.AccessControl.AccessControlType]::Allow
    
    $objUser = New-Object System.Security.Principal.NTAccount($SecurityPrincipal)

    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $pathRights, $inheritanceFlag, $propagationFlag, $objType)

    $objACL = (Get-Item $path).getAccessControl("Access")

    $objACL.AddAccessRule($objACE)

    Set-ACL $path -AclObject $objACL

}