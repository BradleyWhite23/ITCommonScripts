Import-Module ActiveDirectory

$OuDn = "OU=Year1,OU=Students,DC=your,DC=domain,DC=local"  # change this
$NewDescription = "Y1" #change this
$Users = Get-ADUser -SearchBase $OuDn -Filter * -Properties Description

foreach ($u in $Users) {
    try {
        Set-ADUser -Identity $u.DistinguishedName -Description $NewDescription -ErrorAction Stop
        Write-Host "Updated $($u.SamAccountName) -> '$NewDescription'" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed $($u.SamAccountName): $($_.Exception.Message)" -ForegroundColor Red
    }
}
