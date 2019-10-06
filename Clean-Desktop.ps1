
<#
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

#>