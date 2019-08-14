<#
.Synopsis
   Find ScopeID by IPv4-address
.DESCRIPTION
   Find the ScopeID Which contains a specific ipv4 address.
.EXAMPLE
   Find-DhcpServerv4ScopeID -IPaddress <IP address>
   Returns only the ScopeID.
.EXAMPLE
   Find-DhcpServerv4ScopeID -IPaddress <IP address> -Details
   Returns more information about the Scope.
.NOTES
  Author: Flemming Sørvollen Skaret
#>


function Find-DhcpServerv4ScopeID # ($IPaddress)
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        $IPaddress,
        [switch]
        $Details

    )

    try
    {
        Import-Module -Name DhcpServer

        $all_scopes = Get-DhcpServerv4Scope
        $number_of_scopes = $all_scopes.Count

        Do
        {
            $counter = $counter+1                                 

            If (([version]($all_scopes[$counter]).StartRange.IPAddressToString) -le ([version]$IPaddress) -and ([version]$IPaddress) -le ([version]($all_scopes[$counter]).EndRange.IPAddressToString))
            {
                $hit_in_scope = ($all_scopes[$counter]).ScopeID
            }

        } until ($counter -eq $number_of_scopes -or $hit_in_scope -ne $null)
    


        $ScopeID = ($all_scopes[$counter]).ScopeID.IPAddressToString

        if ($Details)
        {
            $DhcpServerv4Scope_Objects = Get-DhcpServerv4Scope -ScopeId $ScopeID | Select-Object *
            $DhcpServerv4ScopeStatistics_Objects = Get-DhcpServerv4ScopeStatistics -ScopeId $ScopeID | Select-Object *


            Write-Host "Scope Info/Status:" -NoNewline
            $DhcpServerv4Scope_Objects | Select-Object Name,Description,State,ActivatePolicies,LeaseDuration,Type,MaxBootpClients,Delay | Format-list
            Write-Host "Scope Addresses": -NoNewline
            $DhcpServerv4Scope_Objects | Select-Object ScopeID,SubnetMask,StartRange,EndRange | Format-list
            Write-Host "Scope Statitstics:" -NoNewline
            $DhcpServerv4ScopeStatistics_Objects | Select-Object Free,InUse,Reserved,Pending,AddressesFree,AddressesFreeOnPartnerServer,AddressesFreeOnThisServer,AddressesInUse,AddressesInUseOnPartnerServer,AddressesInUseOnThisServer,PendingOffers,PercentageInUse,ReservedAddress | Format-list


        }

        else
        {
            $ScopeID
        }




    }

    catch
    {
        Write-Host ERROR: Something went wrong -ForegroundColor Red
    }

    finally
    {
        $counter = 0
        $hit_in_scope = $null
    }

}
