
$properties = @(
    'Name',
    'UserPrincipalName',
    'SamAccountName',
    'Description'
)

$searchBase = 'OU=Year1,OU=Students,DC=your,DC=domain,DC=local' # Adjust this to your target OU

Get-ADUser -Filter * -SearchBase $searchBase -Properties $properties |
    Select-Object -Property $properties |
    Export-Csv -Path 'C:\temp\ExportedList.csv' -NoTypeInformation -Encoding UTF8
# REPLACE 'C:\temp\ExportedList.csv' with your desired output path