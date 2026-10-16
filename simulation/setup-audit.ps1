<#
 setup-audit.ps1  -  Lab preparation for TGT-LAB01 (Windows 11 Pro VM)
 Run as labadmin in an elevated PowerShell, BEFORE any simulated activity.

 !! RECONSTRUCTED from the settings recorded in the project notes (auditing table,
 !! snapshot 02-Lab-Ready). It is not a copy of the commands typed during the lab.
 !! Compare with your PowerShell history and replace this file with the original
 !! if they differ. Delete this banner before publishing.

 Lab only. Run it on a throwaway VM, never on a machine you care about.
#>

# --- 1. Audit policy (events 4688, 4624/4625, 4720, 4663) -------------------------
auditpol /set /subcategory:"Process Creation"        /success:enable /failure:enable
auditpol /set /subcategory:"Logon"                   /success:enable /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"File System"             /success:enable /failure:enable

# --- 2. Put the full command line into event 4688 ---------------------------------
$p = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'
New-Item -Path $p -Force | Out-Null
Set-ItemProperty -Path $p -Name ProcessCreationIncludeCmdLine_Enabled -Value 1 -Type DWord

# --- 3. PowerShell script block logging (event 4104) ------------------------------
$p = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
New-Item -Path $p -Force | Out-Null
Set-ItemProperty -Path $p -Name EnableScriptBlockLogging -Value 1 -Type DWord

# --- 4. Security log of 256 MB so nothing is overwritten --------------------------
wevtutil sl Security /ms:268435456

# --- 5. Hibernate off, so shutdown is a full clean shutdown -----------------------
powercfg /hibernate off

# --- 6. Prefetch should already be on (EnablePrefetcher = 3) - verify only --------
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' |
    Select-Object EnablePrefetcher
Get-Service SysMain | Select-Object Name, Status

# --- 7. Working folders under C:\TargetSim ----------------------------------------
$root = 'C:\TargetSim'
'Tools','POS_Data','Staging','ExfilDrop' | ForEach-Object {
    New-Item -ItemType Directory -Path (Join-Path $root $_) -Force | Out-Null
}

# --- 8. File-system audit rule on C:\TargetSim (reads, writes, deletes -> 4663) ---
$rights = [System.Security.AccessControl.FileSystemRights]'Read,Write,Delete'
$inherit = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
$flags = [System.Security.AccessControl.AuditFlags]'Success,Failure'
$rule = New-Object System.Security.AccessControl.FileSystemAuditRule('Everyone', $rights, $inherit, 'None', $flags)
$acl = Get-Acl $root
$acl.AddAuditRule($rule)
Set-Acl -Path $root -AclObject $acl

# --- 9. The standard user that stands in for the third-party HVAC vendor ----------
# (event 4720 records this account being created; that is lab setup, not attack activity)
$pw = Read-Host -AsSecureString 'Password for hvac_vendor'
New-LocalUser -Name 'hvac_vendor' -Password $pw -FullName 'HVAC Vendor (simulated)' -PasswordNeverExpires

Write-Host 'Audit configuration finished. Take snapshot 02-Lab-Ready now.'
