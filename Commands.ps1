Import-Module C:\Dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Users\thomas\Documents\WinInstall\Drivers'
    WindowsVersion = "Windows 10 Enterprise"
    UpdatesPath = 'C:\Users\thomas\Documents\WinInstall\Updates'
    USBDriveLetter = 'F'
    ExtraPath = 'C:\Users\thomas\Documents\WinInstall\Extra'
    ISOFile = 'C:\Users\thomas\Documents\WinInstall\ISO\en_windows_10_business_editions_version_1803_updated_march_2018_x64_dvd_12063333.iso'
    USBDriveLabel = 'WIN10'
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat