Import-Module C:\Users\ThomasVochten\dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Users\ThomasVochten\dev\WinInstall\Drivers'
    WindowsVersion = "Windows 11 Enterprise"
    UpdatesPath = 'C:\Users\ThomasVochten\dev\WinInstall\Updates'
    USBDriveLetter = 'D'
    ExtraPath = 'C:\Users\ThomasVochten\dev\WinInstall\Extra'
    ISOFile        = 'C:\Users\ThomasVochten\dev\WinInstall\ISO\en-us_windows_11_business_editions_version_23h2_x64_dvd_a9092734.iso'
    USBDriveLabel = 'WIN11'
    WorkingDirectory = 'C:\Users\ThomasVochten\dev\temp'
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat
