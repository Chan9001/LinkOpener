# Link Opener - Professional GUI Application
# Author: HC
# License: MIT Open Source
# Version: 2.0
# GitHub: https://github.com/YourUsername/link-opener

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Browser paths
$browsers = @{
    'Chrome' = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
    'Firefox' = 'C:\Program Files\Mozilla Firefox\firefox.exe'
    'Edge' = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    'Brave' = 'C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe'
    'Helium' = "$env:LOCALAPPDATA\imput\Helium\Application\chrome.exe"
}

# Registry path for preferences
$regPath = "HKCU:\Software\LinkOpenerPro"

# Load saved preferences
function Load-Preferences {
    if (Test-Path $regPath) {
        $savedBrowser = Get-ItemProperty -Path $regPath -Name "LastBrowser" -ErrorAction SilentlyContinue
        $savedPrivate = Get-ItemProperty -Path $regPath -Name "PrivateMode" -ErrorAction SilentlyContinue
        $savedRemember = Get-ItemProperty -Path $regPath -Name "RememberPreferences" -ErrorAction SilentlyContinue
        
        return @{
            Browser = if ($savedBrowser) { $savedBrowser.LastBrowser } else { 'Chrome' }
            Private = if ($savedPrivate) { $savedPrivate.PrivateMode -eq 1 } else { $false }
            Remember = if ($savedRemember) { $savedRemember.RememberPreferences -eq 1 } else { $false }
        }
    }
    return @{ Browser = 'Chrome'; Private = $false; Remember = $false }
}

# Save preferences
function Save-Preferences {
    param($browser, $private, $remember)
    
    if ($remember) {
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "LastBrowser" -Value $browser
        Set-ItemProperty -Path $regPath -Name "PrivateMode" -Value ([int]$private)
        Set-ItemProperty -Path $regPath -Name "RememberPreferences" -Value 1
    }
}

# Load preferences
$prefs = Load-Preferences

# Create main form - Fluent Design Style
$form = New-Object System.Windows.Forms.Form
$form.Text = "Link Opener"
$form.Size = New-Object System.Drawing.Size(620, 720)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Sizable"
$form.MaximizeBox = $true
$form.MinimumSize = New-Object System.Drawing.Size(620, 720)
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# File selection group
$fileGroupBox = New-Object System.Windows.Forms.GroupBox
$fileGroupBox.Text = "Select File"
$fileGroupBox.Location = New-Object System.Drawing.Point(20, 20)
$fileGroupBox.Size = New-Object System.Drawing.Size(560, 120)
$fileGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($fileGroupBox)

# File path textbox
$filePathBox = New-Object System.Windows.Forms.TextBox
$filePathBox.Location = New-Object System.Drawing.Point(15, 35)
$filePathBox.Size = New-Object System.Drawing.Size(450, 30)
$filePathBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$filePathBox.ReadOnly = $true
$filePathBox.BackColor = [System.Drawing.Color]::White
$filePathBox.AllowDrop = $true
$fileGroupBox.Controls.Add($filePathBox)

# Browse button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(475, 33)
$browseButton.Size = New-Object System.Drawing.Size(70, 30)
$browseButton.Text = "Browse"
$browseButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$browseButton.FlatStyle = "Flat"
$browseButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$browseButton.ForeColor = [System.Drawing.Color]::White
$browseButton.FlatAppearance.BorderSize = 0
$browseButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$fileGroupBox.Controls.Add($browseButton)

# Drag & drop label
$dragDropLabel = New-Object System.Windows.Forms.Label
$dragDropLabel.Location = New-Object System.Drawing.Point(15, 75)
$dragDropLabel.Size = New-Object System.Drawing.Size(530, 30)
$dragDropLabel.Text = "Or drag & drop a .txt file here"
$dragDropLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$dragDropLabel.ForeColor = [System.Drawing.Color]::FromArgb(96, 96, 96)
$dragDropLabel.TextAlign = "MiddleCenter"
$fileGroupBox.Controls.Add($dragDropLabel)

# Browser selection group
$browserGroupBox = New-Object System.Windows.Forms.GroupBox
$browserGroupBox.Text = "Browser"
$browserGroupBox.Location = New-Object System.Drawing.Point(20, 155)
$browserGroupBox.Size = New-Object System.Drawing.Size(560, 100)
$browserGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($browserGroupBox)

# Radio buttons for browsers
$radioButtons = @{}
$browserNames = @('Chrome', 'Firefox', 'Edge', 'Brave', 'Helium')
$xPositions = @(20, 130, 240, 350, 460)

for ($i = 0; $i -lt $browserNames.Count; $i++) {
    $radio = New-Object System.Windows.Forms.RadioButton
    $radio.Location = New-Object System.Drawing.Point($xPositions[$i], 40)
    $radio.Size = New-Object System.Drawing.Size(100, 40)
    $radio.Text = $browserNames[$i]
    $radio.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $radio.Checked = ($browserNames[$i] -eq $prefs.Browser)
    
    # Check if browser exists
    if (-not (Test-Path $browsers[$browserNames[$i]])) {
        $radio.Enabled = $false
        $radio.ForeColor = [System.Drawing.Color]::Gray
    }
    
    $browserGroupBox.Controls.Add($radio)
    $radioButtons[$browserNames[$i]] = $radio
}

# Options group
$optionsGroupBox = New-Object System.Windows.Forms.GroupBox
$optionsGroupBox.Text = "Options"
$optionsGroupBox.Location = New-Object System.Drawing.Point(20, 270)
$optionsGroupBox.Size = New-Object System.Drawing.Size(560, 90)
$optionsGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($optionsGroupBox)

# Private mode checkbox
$privateCheckBox = New-Object System.Windows.Forms.CheckBox
$privateCheckBox.Location = New-Object System.Drawing.Point(20, 35)
$privateCheckBox.Size = New-Object System.Drawing.Size(250, 30)
$privateCheckBox.Text = "Private/Incognito Mode"
$privateCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$privateCheckBox.Checked = $prefs.Private
$optionsGroupBox.Controls.Add($privateCheckBox)

# Remember preferences checkbox
$rememberCheckBox = New-Object System.Windows.Forms.CheckBox
$rememberCheckBox.Location = New-Object System.Drawing.Point(290, 35)
$rememberCheckBox.Size = New-Object System.Drawing.Size(250, 30)
$rememberCheckBox.Text = "Remember my preferences"
$rememberCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$rememberCheckBox.Checked = $prefs.Remember
$optionsGroupBox.Controls.Add($rememberCheckBox)

# Preview group
$previewGroupBox = New-Object System.Windows.Forms.GroupBox
$previewGroupBox.Text = "Preview"
$previewGroupBox.Location = New-Object System.Drawing.Point(20, 375)
$previewGroupBox.Size = New-Object System.Drawing.Size(560, 180)
$previewGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($previewGroupBox)

# Preview textbox
$previewBox = New-Object System.Windows.Forms.TextBox
$previewBox.Location = New-Object System.Drawing.Point(15, 30)
$previewBox.Size = New-Object System.Drawing.Size(530, 135)
$previewBox.Multiline = $true
$previewBox.ScrollBars = "Vertical"
$previewBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$previewBox.ReadOnly = $true
$previewBox.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
$previewBox.Text = "No file selected..."
$previewGroupBox.Controls.Add($previewBox)

# Open button - Elegant Design
$openButton = New-Object System.Windows.Forms.Button
$openButton.Location = New-Object System.Drawing.Point(220, 575)
$openButton.Size = New-Object System.Drawing.Size(160, 45)
$openButton.Text = "OPEN"
$openButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$openButton.FlatStyle = "Flat"
$openButton.BackColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
$openButton.ForeColor = [System.Drawing.Color]::White
$openButton.FlatAppearance.BorderSize = 0
$openButton.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($openButton)

# Status bar
$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Location = New-Object System.Drawing.Point(20, 640)
$statusBar.Size = New-Object System.Drawing.Size(560, 30)
$statusBar.Text = "Ready"
$statusBar.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$statusBar.ForeColor = [System.Drawing.Color]::FromArgb(96, 96, 96)
$statusBar.TextAlign = "MiddleLeft"
$form.Controls.Add($statusBar)

# Update preview function
function Update-Preview {
    param($filePath)
    
    if (Test-Path $filePath) {
        $links = Get-Content -Path $filePath -ErrorAction SilentlyContinue
        if ($links) {
            $preview = ($links | Select-Object -First 5) -join "`r`n"
            $previewBox.Text = $preview
            $totalCount = $links.Count
            if ($totalCount -gt 5) {
                $previewBox.Text += "`r`n`r`n... and $($totalCount - 5) more links"
            }
        }
    }
}

# Browse button click
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
    $openFileDialog.Title = "Select links file"
    
    if ($openFileDialog.ShowDialog() -eq "OK") {
        $filePathBox.Text = $openFileDialog.FileName
        Update-Preview -filePath $openFileDialog.FileName
        $statusBar.Text = "File loaded: $($openFileDialog.FileName)"
        $statusBar.ForeColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
    }
})

# Drag & Drop events
$filePathBox.Add_DragEnter({
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = 'Copy'
    }
})

$filePathBox.Add_DragDrop({
    $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
    if ($files.Count -gt 0 -and $files[0] -match '\.txt$') {
        $filePathBox.Text = $files[0]
        Update-Preview -filePath $files[0]
        $statusBar.Text = "File loaded: $($files[0])"
        $statusBar.ForeColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
    }
})

# Open button click
$openButton.Add_Click({
    $filePath = $filePathBox.Text
    
    if (-not (Test-Path $filePath)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a valid file!", "Error", "OK", "Error")
        return
    }
    
    # Get selected browser
    $selectedBrowser = $null
    foreach ($key in $radioButtons.Keys) {
        if ($radioButtons[$key].Checked) {
            $selectedBrowser = $key
            break
        }
    }
    
    if (-not $selectedBrowser) {
        [System.Windows.Forms.MessageBox]::Show("Please select a browser!", "Error", "OK", "Error")
        return
    }
    
    # Save preferences
    Save-Preferences -browser $selectedBrowser -private $privateCheckBox.Checked -remember $rememberCheckBox.Checked
    
    # Get links
    $links = Get-Content -Path $filePath | Where-Object { $_.Trim() -ne '' }
    
    if ($links.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No valid links found in the file!", "Error", "OK", "Error")
        return
    }
    
    $linkCount = $links.Count
    
    # Update status
    $statusBar.Text = "Opening $linkCount links in $selectedBrowser..."
    $statusBar.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $form.Refresh()
    
    # Get browser path
    $browserPath = $browsers[$selectedBrowser]
    
    # Open links
    try {
        if ($selectedBrowser -eq 'Firefox') {
            if ($privateCheckBox.Checked) {
                # Firefox private - open each link separately
                foreach ($link in $links) {
                    Start-Process -FilePath $browserPath -ArgumentList @('-private-window', $link)
                    Start-Sleep -Milliseconds 800
                }
            } else {
                # Firefox normal
                $arguments = @('-new-tab')
                foreach ($link in $links) {
                    $arguments += '-url'
                    $arguments += $link
                }
                Start-Process -FilePath $browserPath -ArgumentList $arguments
            }
        } else {
            # Chrome, Edge, Brave, Helium
            if ($privateCheckBox.Checked) {
                $flag = if ($selectedBrowser -eq 'Edge') { '-inprivate' } else { '--incognito' }
                $arguments = @($flag) + $links
                Start-Process -FilePath $browserPath -ArgumentList $arguments
            } else {
                Start-Process -FilePath $browserPath -ArgumentList $links
            }
        }
        
        Start-Sleep -Milliseconds 1500
        $statusBar.Text = "Done! Opened $linkCount links successfully"
        $statusBar.ForeColor = [System.Drawing.Color]::FromArgb(16, 124, 16)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error opening links: $_", "Error", "OK", "Error")
        $statusBar.Text = "Error opening links"
        $statusBar.ForeColor = [System.Drawing.Color]::FromArgb(196, 43, 28)
    }
})

# Show form
$form.Add_Resize({
    # Calculate center position for OPEN button
    $buttonX = ($form.ClientSize.Width - $openButton.Width) / 2
    $buttonY = $form.ClientSize.Height - $openButton.Height - 80
    $openButton.Location = New-Object System.Drawing.Point($buttonX, $buttonY)
    
    # Adjust status bar position
    $statusBar.Location = New-Object System.Drawing.Point(20, $form.ClientSize.Height - 40)
    $statusBar.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 40, 30)
    
    # Adjust file group width
    $fileGroupBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 40, 120)
    $filePathBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 125, 30)
    $browseButton.Location = New-Object System.Drawing.Point($form.ClientSize.Width - 115, 33)
    $dragDropLabel.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 70, 30)
    
    # Adjust browser group width
    $browserGroupBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 40, 100)
    
    # Adjust options group width
    $optionsGroupBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 40, 90)
    
    # Adjust preview group width
    $previewGroupBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 40, 180)
    $previewBox.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 70, 135)
})

[void]$form.ShowDialog()