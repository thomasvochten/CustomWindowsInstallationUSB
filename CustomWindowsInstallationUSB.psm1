function CheckRunAsAdmin () {
    Write-Verbose "Running as admin - CHECKING"
    $WindowsIdentity = [system.security.principal.windowsidentity]::GetCurrent()
    $Principal = New-Object System.Security.Principal.WindowsPrincipal($WindowsIdentity)
    $AdminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    if ($Principal.IsInRole($AdminRole)) {
        Write-Verbose "Running as admin - SUCCESS"
        return $true
    }
    else {
        Write-Verbose "Running as admin - FAIL"
        return $false
    }
}

function FormatUSBDrive () {
    if ($USBDriveLabel) {
        Format-Volume -DriveLetter $USBDriveLetter -FileSystem "FAT32" -NewFileSystemLabel $USBDriveLabel
    }
    else {
        Format-Volume -DriveLetter $USBDriveLetter -FileSystem "FAT32"
    }

}

function ValidateUSBDrive([string]$DriveLetter) {

    $Drives = Get-Volume | Where-Object -Property DriveType -eq "Removable" | Select-Object -ExpandProperty DriveLetter
    if ($Drives -contains $DriveLetter) {
        $true
    }
}

function ValidateDirectory([string]$DirectoryPath) {
    If (Test-Path $DirectoryPath -PathType 'Container') {
        $true
    }
    else {
        Throw "The specified directory does not exist."
    }
}


# TODO: Only remove created folders
function CleanWorkingDirectory ([string]$WorkingDirectory) {
    Get-ChildItem -Path $WorkingDirectory | Remove-Item -Recurse -Force
}

function InitializeWorkingDirectory ([string]$WorkingDirectory) {
    $Subfolders = "Mount", "Output", "Wim"
    foreach ($folder in $subfolders) {
        New-Item -ItemType Directory -Path $WorkingDirectory\$folder -Force
    }
}

function New-CustomWindowsInstallationUSB {
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter(mandatory = $true)]
        [ValidateSet(
            "Windows 10 Education",
            "Windows 10 Education N",
            "Windows 10 Enterprise",
            "Windows 10 Enterprise N",
            "Windows 10 Pro",
            "Windows 10 Pro N",
            "Windows 10 Pro Education",
            "Windows 10 Pro Education N",
            "Windows 10 Pro for Workstations",
            "Windows 10 Pro N for Workstations",
            "Windows 11 Education",
            "Windows 11 Education N",
            "Windows 11 Enterprise",
            "Windows 11 Enterprise N",
            "Windows 11 Pro",
            "Windows 11 Pro N",
            "Windows 11 Pro Education",
            "Windows 11 Pro Education N",
            "Windows 11 Pro for Workstations",
            "Windows 11 Pro N for Workstations")]
        [string] $WindowsVersion,

        [Parameter(mandatory = $true)]
        [ValidateScript( {

                If (Test-Path $PSItem -PathType 'Leaf') {
                    $true
                }
                else {
                    Throw "The specified ISO file does not exist."
                }
            }
        )]
        [string] $ISOFile,

        [Parameter(mandatory = $true)]
        [ValidateScript( { if (ValidateUSBDrive($PSItem)) {
                    $true
                }
                else {
                    Throw "The specified drive does not exist or is not a valid USB flash drive."
                }
            }
        )]
        [string] $USBDriveLetter,

        [Parameter(mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $USBDriveLabel,

        [Parameter(mandatory = $false)]
        [ValidateScript( { ValidateDirectory($PSItem) } )]
        [string] $DriverPath,

        [Parameter(mandatory = $false)]
        [ValidateScript( { ValidateDirectory($PSItem) } )]
        [string] $UpdatesPath,

        [Parameter(mandatory = $false)]
        [ValidateScript( { ValidateDirectory($PSItem) } )]
        [string] $ExtraPath,

        [Parameter(mandatory = $false)]
        [ValidateScript( { ValidateDirectory($PSItem) } )]
        [string] $WorkingDirectory

    )
    begin {

        # Check if the script is run using administrative privileges

        if (!(CheckRunAsAdmin)) {
            Write-Output "You should run this module as administrator"
            break
        }

        # Generate a unique working directory name
        $uniqueID = [System.IO.Path]::GetRandomFileName()

        # Clean & initialize the working directory

        if (!$WorkingDirectory) {
            $WorkingDirectory = Join-Path -Path $env:TEMP -ChildPath "$($uniqueID)\CustomWindowsInstallationUSB"
            New-Item $WorkingDirectory -ItemType Directory -Force    <# Action to perform if the condition is true #>
        }        

        CleanWorkingDirectory($WorkingDirectory)
        InitializeWorkingDirectory($WorkingDirectory)



    }
    process {

        # Format the USB flash drive

        if ($PSCmdlet.ShouldProcess("Formatting the USB Drive")) {
            FormatUSBDrive
        }

        # Mount the provided ISO file as a DVD drive

        if ($PSCmdlet.ShouldProcess("Mounting the ISO file as a DVD drive")) {
            $mountResult = Mount-DiskImage -ImagePath $ISOFile -PassThru
            $mountedDriveLetter = $mountResult | Get-Volume | Select-Object -ExpandProperty DriveLetter
        }

        # Copy everything from the ISO file to a temporary location

        # Copy-Item -Path "$mountedDriveLetter`:\*" -Destination $WorkingDirectory\FromISO -Recurse

        # Extract boot.wim and install.wim fils to a temporary location

        Copy-Item -Path $mountedDriveLetter`:\sources\*.wim -Destination $WorkingDirectory\Wim

        # Make sure the .wim files are not readonly

        $wimFiles = Get-ChildItem $WorkingDirectory\Wim
        foreach ($wim in $wimFiles) {
            Set-ItemProperty -Path $wim.FullName -name IsReadOnly -value $false
        }

        # When custom drivers have to be integrated

        if (($DriverPath) -and (Get-ChildItem -Path $DriverPath)) {

            # Mount WinPE and Setup images from boot.wim to include custom drivers

            $images = Get-WindowsImage -ImagePath $WorkingDirectory\wim\boot.wim

            foreach ($image in $images) {
                Mount-WindowsImage -ImagePath $WorkingDirectory\wim\boot.wim -Path $WorkingDirectory\Mount -Name $image.ImageName
                Add-WindowsDriver -Recurse -Driver $DriverPath -Path $WorkingDirectory\Mount
                Dismount-WindowsImage -Path $WorkingDirectory\Mount -Save
            }
        }

        # Get the OS images contained in install.wim and remove the unwanted ones to save space

        $images = Get-WindowsImage -ImagePath $WorkingDirectory\Wim\install.wim
        $removeMe = $images | Where-Object -Property ImageName -NE $WindowsVersion
        foreach ($image in $removeMe) { Remove-WindowsImage -ImagePath $WorkingDirectory\Wim\install.wim -Name $image.ImageName }

        # Mount install.wim, integrate drivers and cumulative updates
        # Only execute if Drivers are specified

        Mount-WindowsImage -ImagePath $WorkingDirectory\Wim\install.wim -Path $WorkingDirectory\Mount -Index 1

        if (($DriverPath) -and (Get-ChildItem -Path $DriverPath)) {
            Add-WindowsDriver -Recurse -Driver $DriverPath -Path $WorkingDirectory\Mount
        }

        # Only execute if Udates are specified

        $updatesToInstall = Get-ChildItem -Path $UpdatesPath -Filter *.msu

        if ($updatesToInstall) {
            foreach ($update in $updatesToInstall) {
                Add-WindowsPackage -PackagePath $update.FullName -Path $WorkingDirectory\Mount
            }
        }

        Dismount-WindowsImage -Path $WorkingDirectory\Mount\ -Save

        # Optimize install.wim size, move to the Output directory and split into multiple files for FAT32 compatibility

        Export-WindowsImage -SourceImagePath $WorkingDirectory\Wim\install.wim -SourceIndex 1 -DestinationImagePath $WorkingDirectory\Output\install.wim
        Split-WindowsImage -ImagePath $WorkingDirectory\Output\install.wim -SplitImagePath $WorkingDirectory\Output\install.swm -FileSize 1024
        Remove-Item -Path $WorkingDirectory\Output\install.wim -Force
        Remove-Item -Path  $WorkingDirectory\Wim\install.wim -Force


        # Move the optimized boot.wim file to the output directory
        Move-Item $WorkingDirectory\Wim\boot.wim -Destination $WorkingDirectory\Output

        # Copy the installation files and the .wim files to the USB drive
        Copy-Item -Path $mountedDriveLetter`:\* -Destination "$USBDriveLetter`:\" -Recurse -Exclude *.wim
        Move-Item -Path $WorkingDirectory\Output\*.* -Destination "$USBDriveLetter`:\sources"

        # Copy the extra folder to the root of the USB drive
        Copy-Item -Path $ExtraPath -Destination "$USBDriveLetter`:\extra\" -Recurse -Container

    }
    end {

        CleanWorkingDirectory($WorkingDirectory)
        Dismount-DiskImage -ImagePath $ISOFile

    }
}

Export-ModuleMember -Function *-*
