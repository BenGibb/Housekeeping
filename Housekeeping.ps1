function Get-ItemsGrouped {
    [CmdletBinding()]
    param (
        # Source Path
        [Parameter(ParameterSetName = 'Created', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Accessed', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Updated', Mandatory = $true)]
        [string]
        $Path,
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
        $DateFormat = 'yyyyMMdd'
    )
    
    begin {
        [string]$GroupBy = $($PsCmdlet.ParameterSetName)

        [array]$FileProperties = @(
            'FullName'
            'length'
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
    }
    
    process {
        $Groups = get-childitem -Path $Path |
            Select-Object -Property $FileProperties |
            group-object -property $GroupBy
        foreach ($Group in $Groups) {
            $Group | Add-Member -name "Size" -MemberType NoteProperty -Value $($Group.Group.length | Measure-Object -Sum).Sum
        }
    }
    
    end {
        $Groups | Select-Object *
    }
}

<# 
$Files = Get-ChildItem -Path $SourcePath -Recurse


$groups = get-childitem -Path $SourcePath |
    Select-Object -Property FullName, length, @{Name = "Updated"; Expression = { $_.lastwritetime.ToString('yyyyMM') } } |
    group-object -property Updated;
foreach ($g in $groups) {
    $groupsize = 0;
    foreach ($item in $g.group) {
        $groupsize += Get-item $item.FullName | Select-Object -ExpandProperty length;
    }
    $g | Add-Member -name "Size" -MemberType NoteProperty -Value $groupsize;
}
$groups | select @{Name = "Date"; Expression = { $_.Name } }, @{Name = "Number of Files"; Expression = { $_.Count } }, Size | sort-object -property "Date" | Format-Table -AutoSize;


$Files | ForEach-Object {
    $File = $_
    if(-not (Test-Path $DestFolder)){
        New-Item -Path $DestFolder -ItemType Directory
    }
    $Dest = "$($DestFolder)$($File.CreationTime.ToString($DateFormat))$($File.BaseName)$($File.CreationTime.ToString($DateFormat))$($File.Extension)"
    #Move-Item -Path $File -Destination $Dest
}
 #>
