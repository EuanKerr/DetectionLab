secedit /export /cfg C:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
rm -force C:\secpol.cfg -confirm:$false
net user bglocaladmin P@ssw0rd1 /add /y
net localgroup administrators bglocaladmin /add
powershell.exe -c "Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private"
Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
powershell.exe -c "winrm set winrm/config '@{MaxTimeoutms=\`"1800000\`"}'"
powershell.exe -c "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\`"800\`"}'"
powershell.exe -c "winrm set winrm/config/service '@{AllowUnencrypted=\`"true\`"}'"
powershell.exe -c "winrm set winrm/config/service/auth '@{Basic=\`"true\`"}'"
powershell.exe -c "winrm set winrm/config/client/auth '@{Basic=\`"true\`"}'"
powershell.exe -c "winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port=\`"5985\`"}'"
powershell.exe -c "winrm set winrm/config/client '@{TrustedHosts=\`"*\`"}'"
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /v StartWinRM /t REG_SZ /f /d "cmd.exe /c 'sc config winrm start= auto & sc start winrm'"
Restart-Service winrm

