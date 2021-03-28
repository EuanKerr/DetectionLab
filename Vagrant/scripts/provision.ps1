# Purpose: Sets timezone to UTC, sets hostname, creates/joins domain.
# Source: https://github.com/StefanScherer/adfs2

$ProfilePath = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting timezone to UTC..."
c:\windows\system32\tzutil.exe /s "UTC"

If (!(Test-Path $ProfilePath)) {
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Disabling the Invoke-WebRequest download progress bar globally for speed improvements." 
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) See https://github.com/PowerShell/PowerShell/issues/2138 for more info"
  New-Item -Path $ProfilePath | Out-Null
  If (!(Get-Content $Profilepath| % { $_ -match "SilentlyContinue" } )) {
    Add-Content -Path $ProfilePath -Value "$ProgressPreference = 'SilentlyContinue'"
  }
}

if ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Current domain is set to 'workgroup'. Time to join the domain!"

  if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing bginfo..."
    . c:\vagrant\scripts\install-bginfo.ps1
    # Set background to be "fitted" instead of "tiled"
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '6'
    # Set Task Manager prefs
    reg import "c:\vagrant\resources\windows\TaskManager.reg" 2>&1 | out-null
  }

  if ($env:COMPUTERNAME -imatch 'dc') {
    . c:\vagrant\scripts\create-domain.ps1 10.21.25.100
  } else {
    . c:\vagrant\scripts\join-domain.ps1
  }
} else {
  Write-Host -fore green "$('[{0:HH:mm}]' -f (Get-Date)) I am domain joined!"
  if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Installing bginfo..."
    . c:\vagrant\scripts\install-bginfo.ps1
  }

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Setting the registry for auto-login..."
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1 -Type String
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "user"
  Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "E3b;70GpB%0j3x7"
  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Provisioning after joining domain..."
}
