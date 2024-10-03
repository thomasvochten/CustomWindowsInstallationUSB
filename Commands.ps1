Import-Module C:\Users\ThomasVochten\dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Users\ThomasVochten\dev\WinInstall\Drivers'
    WindowsVersion = "Windows 11 Enterprise"
    UpdatesPath = 'C:\Users\ThomasVochten\dev\WinInstall\Updates'
    USBDriveLetter = 'D'
    ExtraPath = 'C:\Users\ThomasVochten\dev\WinInstall\Extra'
    ISOFile        = 'C:\Users\ThomasVochten\dev\WinInstall\ISO\en-us_windows_11_business_editions_version_24h2_x64_dvd_59a1851e.iso'
    USBDriveLabel = 'WIN11'
    WorkingDirectory = 'C:\Users\ThomasVochten\dev\temp'
}

if (-not (Test-Path $newCustomWindowsInstallationUSBSplat.WorkingDirectory)) {
    New-Item -Path $newCustomWindowsInstallationUSBSplat.WorkingDirectory -ItemType Directory
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat
