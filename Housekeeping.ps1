function Get-FilesGrouped {
    [CmdletBinding()]
    param (
        # Source Path
        [Parameter(ParameterSetName = 'Created', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Accessed', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Updated', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Extension', Mandatory = $true)]
        [string]
        $Path,
        #region Date Grouping
        # Group by CreationTime
        [Parameter(ParameterSetName = 'Created', Mandatory = $true)]
        [switch]
        $ByCreated,
        # Group by LastAccessTime
        [Parameter(ParameterSetName = 'Accessed', Mandatory = $true)]
        [switch]
        $ByAccessed,
        # Group by LastWriteTime
        [Parameter(ParameterSetName = 'Updated', Mandatory = $true)]
        [switch]
        $ByUpdated,

        [Parameter(ParameterSetName = 'Created', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Accessed', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Updated', Mandatory = $false)]
        [string]
        $DateFormat = 'yyyyMMdd',
        #endregion Date Grouping

        #region Type Grouping
        [Parameter(ParameterSetName = 'Extension', Mandatory = $true)]
        [Alias('ByExt')]
        [switch]
        $ByExtension
        #endregion Type Grouping

    )
    
    begin {
        [string]$GroupBy = $($PsCmdlet.ParameterSetName)

        [array]$FileProperties = @(
            'FullName'
            'Length'
            'Extension'
            @{
                Name       = 'Created'
                Expression = { $_.CreationTime.ToString($DateFormat) }
            }
            @{
                Name       = 'Accessed'
                Expression = { $_.LastAccessTime.ToString($DateFormat) }
            }
            @{
                Name       = 'Updated'
                Expression = { $_.LastWriteTime.ToString($DateFormat) }
            }
            @{
                Name       = 'IsFile'
                Expression = { $_.GetType().Name -eq 'FileInfo' }
            }
            @{
                Name       = 'IsDir'
                Expression = { $_.GetType().Name -eq 'DirectoryInfo' }
            }
        )
            $GroupMeasure = @{
                Sum = $true
                Average = $true
                Maximum = $true
                Minimum = $true
            }
    }
    
    process {
        $Groups = get-childitem -Path $Path |
            Select-Object -Property $FileProperties |
            group-object -property $GroupBy
            foreach ($Group in $Groups) {
            $GroupSize = $($Group.Group.length | Measure-Object @GroupMeasure)
            foreach ($Measurement in $GroupMeasure.Keys) {
                $Group | Add-Member -name $Measurement -MemberType NoteProperty -Value $GroupSize.$Measurement
            }
        }
    }
    
    end {
        $Groups | Select-Object *
    }
}

#Get-FilesGrouped -Path 'c:\windows' -ByCreated
function Move-FileGroups {
    #Todo: Groups(source), Destination, Exclusions(bygroup?|filter?), Deletions(bygroup?|filter?), Copyonly?(Switch)
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}



<#region code bits
$groups | select @{Name = "Date"; Expression = { $_.Name } }, @{Name = "Number of Files"; Expression = { $_.Count } }, Size | sort-object -property "Date" | Format-Table -AutoSize;


$Files | ForEach-Object {
    $File = $_
    if(-not (Test-Path $DestFolder)){
        New-Item -Path $DestFolder -ItemType Directory
    }
    $Dest = "$($DestFolder)$($File.CreationTime.ToString($DateFormat))$($File.BaseName)$($File.CreationTime.ToString($DateFormat))$($File.Extension)"
    #Move-Item -Path $File -Destination $Dest
}

$DateFormat = "yyyy-MM-dd"
#$DateFormat = "MM-dd-yyyy"
$Path = ".\SourceFolder\"
$DestFolder = ".\DestFolder\"
$Files = Get-ChildItem -Path $Path
$Files | ForEach-Object {
    $File = $_
    if(-not (Test-Path $DestFolder)){
        New-Item -Path $DestFolder -ItemType Directory
    }
    $Dest = "$($DestFolder)$($File.CreationTime.ToString($DateFormat))$($File.BaseName)$($File.CreationTime.ToString($DateFormat))$($File.Extension)"
    Move-Item -Path $File -Destination $Dest
}


$docspath = [environment]::getfolderpath("mydocuments") + "\Desktop Items"
$desktop = [environment]::getfolderpath("desktop")
$exclusions = @("*.iso", "*.lnk", "*.mp*", "*.exe", "*.msu", "*.url", "*.wav")
$mediafiles = @("*.iso", "*.mp*", "*.exe", "*.msu", "*.wav")
 
if (!(Test-Path $docspath)) {
    new-item -Path $docspath -ItemType Directory
}
 
# List items to be copied / deleted
$filedirlist = Get-ChildItem -Path $desktop -Recurse -Exclude $exclusions | where FullName -NotLike *Personal* | where FullName -NotLike *Misc*
 
# Copy files and folders
$filedirlist |
    Move-Item -Destination {
        if ($_.PSIsContainer) {
            Join-Path $docspath $_.Parent.FullName.Substring($desktop.length)
        }
        else {
            Join-Path $docspath $_.FullName.Substring($desktop.length)
        }
    } -Force -Exclude $exclusions
 
# Set Miscellaneous folder location
$miscdocspath = [environment]::getfolderpath("desktop") + "\Misc"
 
# Collect list of legacy files to be moved
$legacyfilelist = Get-ChildItem -Path $desktop -Recurse -Include $mediafiles | where FullName -NotLike *Personal* | where FullName -NotLike *.lnk | where FullName -NotLike *Misc*
 
# Conditional statement to create a "Miscellaneous" directory for left over legacy files if they exist
if ($legacyfileslist -eq $null) {
    if (!(Test-Path $miscdocspath)) {
        new-item -Path $miscdocspath -ItemType Directory
    }
}
 
$legacyfilelist |
    Copy-Item -Destination {
        if ($_.PSIsContainer) {
            Join-Path $miscdocspath $_.Parent.FullName.Substring($desktop.length)
        }
        else {
            Join-Path $miscdocspath $_.FullName.Substring($desktop.length)
        }
    } -Force -ErrorAction SilentlyContinue


#endregion code bits#>

