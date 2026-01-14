
Import-Module ActiveDirectory

# OU path (change to your actual DN)
$OU                  = "OU=Year1,OU=Students,DC=your,DC=domain,DC=local"

# Fixed password to set (ensure it meets policy)
$NewPassword         = "Year1"    
$SecurePwd           = ConvertTo-SecureString -String $NewPassword -AsPlainText -Force

# Options
$ForceChangeAtLogon  = $false     # We do NOT want to force a change
$Unlock              = $true      # Unlock accounts after reset (optional)
$DisallowUserChange  = $true      # Prevent users from changing their password
$NeverExpirePwd      = $true      # Optional: set password to never expire (usually NOT recommended)

# Get users ONLY in this OU (no child OUs)
$users = Get-ADUser -Filter * -SearchBase $OU -SearchScope OneLevel

foreach ($u in $users) {
    try {
        # 1) Set the password (reset)
        Set-ADAccountPassword -Identity $u.DistinguishedName -NewPassword $SecurePwd -Reset -ErrorAction Stop

        # 2) Optional actions
        if (-not $ForceChangeAtLogon) { Set-ADUser -Identity $u -ChangePasswordAtLogon $false }
        if ($Unlock)                  { Unlock-ADAccount -Identity $u }
        if ($DisallowUserChange)      { Set-ADUser -Identity $u -CannotChangePassword $true }
        if ($NeverExpirePwd)          { Set-ADUser -Identity $u -PasswordNeverExpires $true }

        Write-Host "OK: $($u.SamAccountName)" -ForegroundColor Green
    }
    catch {
        Write-Host "ERR: $($u.SamAccountName) -> $($_.Exception.Message)" -ForegroundColor Red
    }
}
