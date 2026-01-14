

Import-Module ActiveDirectory

# === CONFIGURE THESE VALUES ===
$OuDn = "OU=Year1,OU=Students,DC=your,DC=domain,DC=local"  # change this if needed - Will change NESTED OUs too
$NewDescription = "Year 1 "                                                             # change this if needed
$DisplayNameSuffix = " (School_Name)"                                                   # suffix to append
$OfficeName = "School_Name"                                                             # Office to set
# ===============================

# Pull additional properties so we can read/modify cleanly
$Users = Get-ADUser -SearchBase $OuDn -Filter * -Properties Description, DisplayName, GivenName, Surname, Name, physicalDeliveryOfficeName

foreach ($u in $Users) {
    try {
        # 1) Prepare new Description value
        $descToSet = $NewDescription

        # 2) Prepare new DisplayName value
        # Use existing DisplayName if present; otherwise fall back to "GivenName Surname" or Name
        $baseDisplay = if ($u.DisplayName) {
            $u.DisplayName
        } elseif ($u.GivenName -or $u.Surname) {
            ($u.GivenName + " " + $u.Surname).Trim()
        } else {
            $u.Name
        }

        # Avoid double-appending the suffix
        $displayToSet = if ($baseDisplay -like "*$DisplayNameSuffix") {
            $baseDisplay
        } else {
            $baseDisplay + $DisplayNameSuffix
        }

        # 3) Prepare Office value
        $officeToSet = $OfficeName

        # Apply all updates in one call
        Set-ADUser -Identity $u.DistinguishedName `
                   -Description $descToSet `
                   -DisplayName $displayToSet `
                   -Office $officeToSet `
                   -ErrorAction Stop

        Write-Host ("Updated {0}: Description='{1}', DisplayName='{2}', Office='{3}'" -f `
            $u.SamAccountName, $descToSet, $displayToSet, $officeToSet) -ForegroundColor Green
    }
    catch {
        Write-Host "Failed $($u.SamAccountName): $($_.Exception.Message)" -ForegroundColor Red
    }
}
