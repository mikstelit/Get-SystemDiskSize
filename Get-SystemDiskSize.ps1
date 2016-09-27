<#
.Synopsis
   Gets the size and free space of a drive from the list of computers. 
.DESCRIPTION
   The script takes either one or more computer names and outputs the 
   computer's name, disk size, and free space.  Only one disk is investigated 
   and by default that is the C drive, but this can be changed by specifying 
   the Drive parameter in the format of D:.
.EXAMPLE
   Get-SystemDiskSize $ComputerNames
.EXAMPLE
   $ComputerNames | Get-SystemDiskSize
#>
function Get-SystemDiskSize
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$True,
                   Position=0)]
        [string[]]$ComputerNames,

        [string]$Drive = "C:"
    )

    Process
    {
        Foreach ($ComputerName in $ComputerNames)
        {
            Try
            {
                $Disk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName | Where-Object { $_.DeviceID -eq $Drive } -ErrorAction Stop
                [psobject]$System = @{
                    'Name' = $ComputerName;
                    'DiskSize' = $Disk.Size / 1GB;
                    'FreeSpace' = $Disk.FreeSpace / 1GB;
                }
            }
            Catch
            {
                [psobject]$System = @{
                    'Name' = $ComputerName;
                    'DiskSize' = $Error[0].Exception.Message;
                    'FreeSpace' = '';
                }
            }

            $System
        }
    }
}