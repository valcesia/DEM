 # Create Dynamic Environment Manager Folder Structure

## Define your variables
## 

# Get Servername
$DEMServer = "$env:computername.$env:userdnsdomain"

# Get Domain Name
$Domain = Get-ADDomain -Current LocalComputer
$Domain.Name

# DEM Folder Names
$DEMShare = "DEMShare"
$DEMProfile = "DEMProfile"

# Define DEM Share and DEM Profile Path

$PathDEMShare = "c:\$DEMShare"
$PathDEMProfile = "c:\$DEMProfile"

## 
## Run the PowerShell Script to create it automatically

# Create DEM Share Folder
New-Item -ItemType directory -Path $PathDEMShare

# Create DEM Profiles Folder
New-Item -ItemType directory -Path $PathDEMProfile

# Create SMB Share DEM Share Folder
New-SmbShare -Name $DEMShare `
             -Path $PathDEMShare `
             -FullAccess Administrators `
             -ChangeAccess 'Everyone' `
             -ReadAccess Users 

# Create SMB Share DEM Profiles Folder
New-SmbShare -Name $DEMProfile `
             -Path $PathDEMProfile `
             -FullAccess Administrators `
             -ChangeAccess 'Everyone' `
             -ReadAccess Users 

# Set DEM Share permissions properly
$path = "\\$DEMServer\$DEMShare"
$rights = @('ADM', 'USERS', 'LADM')

foreach($right in $rights){
	$acl = Get-Acl $path
	$permission = switch ($right){
		ADM {'VIRTUAL\Domain Admins','FullControl','ContainerInherit,ObjectInherit','None','Allow'}
        LADM {'Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow'}
		USERS {'VIRTUAL\Domain Users','ReadAndExecute','ContainerInherit,ObjectInherit','None','Allow'}		
	}
	if($permission){
		$ace = New-Object System.Security.AccessControl.FileSystemAccessRule($permission)
		$acl.SetAccessRule($ace)
		$acl | Set-Acl $path
    }else{
		Write-host 'variabele not valid'
    }
}

# Set DEM Profiles permissions properly
$path = "\\$DEMServer\$DEMProfile"
$rights = @('ADM','LADM','USERS','CO','DC')

foreach($right in $rights){
	$acl = Get-Acl $path
	$permission = switch ($right){
		ADM {'VIRTUAL\Domain Admins','FullControl','ContainerInherit,ObjectInherit','None','Allow'}
        LADM {'Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow'}
		USERS {'VIRTUAL\Domain Users','AppendData','ObjectInherit','None','Allow'}
        CO {'CREATOR OWNER','AppendData','ContainerInherit,ObjectInherit','None','Allow'}
        DC {'DOMAIN COMPUTERS','AppendData','ObjectInherit','None','Allow'}			
	}
	if($permission){
		$ace = New-Object System.Security.AccessControl.FileSystemAccessRule($permission)
		$acl.SetAccessRule($ace)
		$acl | Set-Acl $path
    }else{
		Write-host 'variabele not valid'
    }
}

# Check ACL from DEM Share
Get-Acl -Path C:\$DEMShare | Format-Table -Wrap

# Check ACL from DEM Profiles
Get-Acl -Path C:\$DEMProfile | Format-Table -Wrap
