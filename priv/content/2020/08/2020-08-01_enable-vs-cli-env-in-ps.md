---
%{
  title: "Enable Visual Studio CLI environment in PowerShell",
  date: ~D[2020-08-01],
  author: "Adam Piontek",
  tags: ["coding", "tech", "elixir", "windows", "powershell", "scripting"],
}
---

My initial problem: I have an elixir project I'm building primarily on linux, but I want it to work on Windows, too, and I'm using [bcrypt](https://github.com/riverrun/bcrypt_elixir), which [needs nmake to compile](https://github.com/riverrun/comeonin/wiki/Requirements#windows) on Windows.

One must install Visual Studio (VS), but that's not enough.<!--more--> Your terminal/PowerShell CLI environment won't know about VS by default. VS includes batch files to set up a dev environment, but if you run them in PowerShell, they bring you into a CMD environment, which is no help if you want to use PowerShell.

Luckily, thanks to [Michael Teter's blog](https://michaelteter.com/2018/07/06/compiling-Elixir-modules-in-Windows.html), and posts on github that mentioned the [VS Setup PS Module](https://github.com/microsoft/vssetup.powershell), I was able to put together a solution that works for me:

The built-in PowerShell (5.1 right now) will load a [profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1) from (under user Documents folder): `WindowsPowerShell\Microsoft.PowerShell_profile.ps1` — and PS 7 (pwsh.exe) will load its [profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7) from the slightly different (under user Documents folder): `PowerShell\Microsoft.PowerShell_profile.ps1`

For each version where I want the environment set up, I place the following code in the profile:

```powershell
function Invoke-CmdScript {
  param(
    [String] $scriptName 
  )
  $cmdLine = """$scriptName"" $args & set"
  & $Env:SystemRoot\system32\cmd.exe /c $cmdLine |
  select-string '^([^=]*)=(.*)$' | foreach-object {
    $varName = $_.Matches[0].Groups[1].Value
    $varValue = $_.Matches[0].Groups[2].Value
    set-item Env:$varName $varValue
  }
}

$installationPath  = (Get-VSSetupInstance -All | Select-Object InstallationPath).InstallationPath
$vcvars64Path = Join-Path -Path $installationPath -ChildPath "VC\Auxiliary\Build\vcvars64.bat"

if ($installationPath -and (Test-Path -Path $vcvars64Path)) {
  Invoke-CmdScript $vcvars64Path
}
```

As Michael explains:

> The function allows you to run a script, the one that makes the build tools visible, but instead of losing the context after that script ends, the settings are propogated back to the calling shell (Powershell).

> The profile then uses that Invoke-CmdScript function to call the vcvars64.bat script...

My addition is just to get the VS installation path from that VS Setup PS Module's `Get-VSSetupInstance` and build the script path from that. Hopefully that will survive future VS upgrades?
