Import-Module C:\Users\ThomasVochten\dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Users\ThomasVochten\dev\WinInstall\Drivers'
    WindowsVersion = "Windows 11 Pro"
    UpdatesPath = 'C:\Users\ThomasVochten\dev\WinInstall\Updates'
    USBDriveLetter = 'D'
    ExtraPath = 'C:\Users\ThomasVochten\dev\WinInstall\Extra'
    ISOFile        = 'C:\Users\ThomasVochten\dev\WinInstall\ISO\en-gb_windows_11_business_editions_version_24h2_updated_sep_2025_x64_dvd_3bb1c3a0.iso'
    USBDriveLabel = 'WIN11'
    WorkingDirectory = 'C:\Users\ThomasVochten\dev\temp'
}

if (-not (Test-Path $newCustomWindowsInstallationUSBSplat.WorkingDirectory)) {
    New-Item -Path $newCustomWindowsInstallationUSBSplat.WorkingDirectory -ItemType Directory
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat
