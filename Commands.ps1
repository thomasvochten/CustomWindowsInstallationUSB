Import-Module C:\Dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Dev\WinInstall\Drivers'
    WindowsVersion = "Windows 11 Enterprise"
    UpdatesPath = 'C:\Dev\WinInstall\Updates'
    USBDriveLetter = 'D'
    ExtraPath = 'C:\Dev\WinInstall\Extra'
    ISOFile        = 'C:\Dev\WinInstall\ISO\en-us_windows_11_business_editions_version_22h2_updated_march_2023_x64_dvd_4b362179.iso'
    USBDriveLabel = 'WIN11'
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat
