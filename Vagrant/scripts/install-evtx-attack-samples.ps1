# Purpose: Downloads and indexes the EVTX samples from https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES/ into Splunk

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Indexing EVTX Attack Samples into Splunk..."

$ProgressPreference = 'SilentlyContinue'
md c:\Tools\
git clone https://github.com/sbousseaden/EVTX-ATTACK-SAMPLES.git c:\Tools\EVTX-ATTACK-SAMPLES

$inputsConf = "C:\Program Files\SplunkUniversalForwarder\etc\apps\Splunk_TA_windows\local\inputs.conf"

If (!(Select-String -Path $inputsConf -Pattern "evtx_attack_sample")) {
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Splunk inputs.conf has not yet been modified. Adding stanzas for these evtx files now..."
        Add-Content -Path "$inputsConf" -Value '
[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\AutomatedTestingTools\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Command and Control\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Credential Access\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Defense Evasion\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Discovery\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Execution\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Lateral Movement\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Other\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Persistence\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt

[monitor://c:\Tools\EVTX-ATTACK-SAMPLES\Privilege Escalation\*.evtx]
index = evtx_attack_samples
sourcetype = preprocess-winevt'
        # Restart the forwarder to pick up changes
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Restarting the Splunk Forwarder..."
        Try { 
          Restart-Service -Name SplunkForwarder -Force -ErrorAction Stop 
        } Catch {
          Start-Sleep 10
          Stop-Service -Name SplunkForwarder -Force
          Start-Service -Name SplunkForwarder
        }
        Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Done! Look in 'index=EVTX-ATTACK-SAMPLES' in Splunk to query these samples."
    }
} Else {
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) EVTX attack samples were already installed. Moving On."
}
