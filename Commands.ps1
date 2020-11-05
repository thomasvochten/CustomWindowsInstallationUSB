Import-Module C:\Dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Dev\WinInstall\Drivers'
    WindowsVersion = "Windows 10 Enterprise"
    UpdatesPath = 'C:\Dev\WinInstall\Updates'
    USBDriveLetter = 'F'
    ExtraPath = 'C:\Dev\WinInstall\Extra'
    ISOFile        = 'C:\Dev\WinInstall\ISO\en_windows_10_business_editions_version_20h2_x64_dvd_4788fb7c.iso'
    USBDriveLabel = 'WIN10'
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat
