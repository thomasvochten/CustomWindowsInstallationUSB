Import-Module C:\Dev\CustomWindowsInstallationUSB -Force -Verbose

$newCustomWindowsInstallationUSBSplat = @{
    DriverPath = 'C:\Users\thomas\Documents\WinInstall\Drivers'
    WindowsVersion = "Windows 10 Enterprise"
    UpdatesPath = 'C:\Users\thomas\Documents\WinInstall\Updates'
    USBDriveLetter = 'F'
    ExtraPath = 'C:\Users\thomas\Documents\WinInstall\Extra'
    ISOFile        = 'C:\Users\thomas\Documents\WinInstall\ISO\SW_DVD9_Win_Pro_Ent_Edu_N_10_1809_64-bit_English_MLF_X21-96501.ISO'
    USBDriveLabel = 'WIN10'
}

New-CustomWindowsInstallationUSB @newCustomWindowsInstallationUSBSplat