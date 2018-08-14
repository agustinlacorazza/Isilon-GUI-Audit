<#

 ISILON Gathering informacion for FIDS. 

 - This software Collect information about:
    - Quotas
    - Shares
    - FS
    - Packages
    - Pool
    - Serial 
    - Nodes 

 - Please, run it with Root User in order to get a correct function. 

 For any technical issue please contact Agustin Lacorazza agustin.lacorazza@ar.ey.com


#>


Write-Host "Warning! This software is property of Ernst & Young. 
It's forbhiden the reproduction of the same for any different use."

Write-Host "If you experience any issues please contacto to Agustin Lacorazza - agustin.lacorazza@ar.ey.com"
function Show-InputForm()
{
    #create input form
    $inputForm               = New-Object System.Windows.Forms.Form 
    $inputForm.Text          = $args[0]
    $inputForm.Size          = New-Object System.Drawing.Size(330, 100) 
    $inputForm.StartPosition = "CenterScreen"
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #handle button click events
    $inputForm.KeyPreview = $true
    $inputForm.Add_KeyDown(
    {   
        if ($_.KeyCode -eq "Enter")  
        {
            $inputForm.Close() 
        } 
    })
    $inputForm.Add_KeyDown(
    {
        if ($_.KeyCode -eq "Escape") 
        {
            $inputForm.Close() 
        } 
    
    })

    #create OK button
    $okButton          = New-Object System.Windows.Forms.Button
    $okButton.Size     = New-Object System.Drawing.Size(75, 23)
    $okButton.Text     = "OK" 
    $okButton.Add_Click(
    {
        $inputForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
    })
    $inputForm.Controls.Add($okButton)
    $inputForm.AcceptButton = $okButton

    #create Cancel button
    $cancelButton          = New-Object System.Windows.Forms.Button 
    $cancelButton.Size     = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text     = "Cancel"
    $inputForm.Controls.Add($cancelButton)
    $inputForm.CancelButton = $cancelButton

    [System.Collections.Generic.List[System.Windows.Forms.TextBox]] $txtBoxes = New-Object System.Collections.Generic.List[System.Windows.Forms.TextBox]
    $y = -15;
    for($i=1;$i -lt $args.Count;$i++)
    {
        $y+=30
        $inputForm.Height += 30

        #create label
        $objLabel          = New-Object System.Windows.Forms.Label
        $objLabel.Location = New-Object System.Drawing.Size(10,  $y)
        $objLabel.Size     = New-Object System.Drawing.Size(280, 20)
        $objLabel.Text     = $args[$i] +":"
        $inputForm.Controls.Add($objLabel)
        $y+=20
        $inputForm.Height+=20
        
        #create TextBox
        $objTextBox          = New-Object System.Windows.Forms.TextBox 
        $objTextBox.Location = New-Object System.Drawing.Size(10,  $y)
        $objTextBox.Size     = New-Object System.Drawing.Size(290, 20) 
        $inputForm.Controls.Add($objTextBox)

        $txtBoxes.Add($objTextBox)

        $cancelButton.Location = New-Object System.Drawing.Size(165, (35+$y))
        $okButton.Location     = New-Object System.Drawing.Size(90, (35+$y))

        if ($args[$i].Contains("*"))
        {
            $objLabel.Text = ($objLabel.Text -replace '\*','')
            $objTextBox.UseSystemPasswordChar = $true 
        }
    }

    $inputForm.Topmost = $true 
    $inputForm.MinimizeBox = $false
    $inputForm.MaximizeBox = $false
    
    $inputForm.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
    $inputForm.SizeGripStyle = [System.Windows.Forms.SizeGripStyle]::Hide
    $inputForm.Add_Shown({$inputForm.Activate(); $txtBoxes[0].Focus()})
    if ($inputForm.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK)
    {
        exit
    }

    return ($txtBoxes | Select-Object {$_.Text} -ExpandProperty Text)
}

Add-Type -AssemblyName "system.windows.forms"

#variables for the source Server  prompt window
$sourceLogin    =  Show-InputForm "FIDS Isilon login"  "Hostname" "IP From Host" "User" "Password*" "Localoutput"
$sourceServer   = $sourceLogin[1]
$sourceip     = $sourceLogin[2]
$sourceuser1 = $sourceLogin[3]
$sourcepasswd = $sourceLogin[4]
$sourcedestination = $sourceLogin[5]


Write-Host "Geting Shares, Quotas and hardware Information from device" $sourceLogin[0]

Write-Host "The Selected Ip addres is:"  $sourceLogin[1]

Write-Host "Final Destination is:"  $sourceLogin[4]

 #codedbash

$Base64shares = "aXNpIHpvbmUgbGlzdCAtYSAteiB8IGF3ayAne3ByaW50ICQxfScgfCB3aGlsZSByZWFkIEwxOyBkbw0KCVoxPSIkKGVjaG8gJEwxfGF3ayAne3ByaW50ICQxfScpIg0KCWlzaSBzbWIgc2hhcmUgbGlzdCAtdiAteiAtYSAtLWZvcm1hdCBjc3YgLS16b25lICRaMQ0KZG9uZQ=="
$Base64quotas = "aXNpIHpvbmUgbGlzdCAtYSAteiB8IGF3ayAne3ByaW50ICQxfScgfCB3aGlsZSByZWFkIEwxOyBkbw0KCVoxPSIkKGVjaG8gJEwxfGF3ayAne3ByaW50ICQxfScpIg0KCWlzaSBxdW90YSBsaXN0IC16IC0tZm9ybWF0IGNzdiAtLXpvbmUgJFoxDQpkb25l"
$base64disk = "dmVyMT0iJCh1bmFtZSAtYSB8IGF3ayAneyBwcmludCAkNCB9JyB8IGF3ayAtRi4gJ3twcmludCAkMX0nKSINCmlmIFsgIiR2ZXIxIiA9IHY4IF07IHRoZW4NCiBpc2kgZGV2aWNlcyBkcml2ZSBsaXN0IC0tbm9kZS1sbm4gYWxsIC1hIC16IHwgYXdrICd7IHByaW50ICQxLCQzfScgfCB3aGlsZSByZWFkIEwxOyBkbw0KICBub2QxPSIkKGVjaG8gJEwxIHwgYXdrICd7cHJpbnQgJDF9JykiDQogIGJheTE9IiQoZWNobyAkTDEgfCBhd2sgJ3twcmludCAkMn0nKSINCiAgaXNpIGRldmljZXMgZHJpdmUgdmlldyAiJGJheTEiIC0tbm9kZS1sbm4gIiRub2QxIg0KIGRvbmUNCmVsc2UNCiBpc2lfZm9yX2FycmF5IGlzaSBkZXZpY2VzIHwgZ3JlcCBCYXkgfCBhd2sgJ3sgcHJpbnQgJDEgJDMgfScgfCBhd2sgLUYtICd7cHJpbnQgJDJ9JyB8IHdoaWxlIHJlYWQgTDE7IGRvDQogIGQxPSIkKGVjaG8gJEwxIHwgYXdrICd7cHJpbnQgJDF9JykiDQogIGlzaSBkZXZpY2VzIC1kICIkZDEiIHwgZ3JlcCAtRSAiTm9kZSB8U3RhdHVzOnwgYmxrcyINCiBkb25lDQpmaQ0K"
$base64packages = "aXNpX2Zvcl9hcnJheSAtc1ggaXNpIHVwZ3JhZGUgcGF0Y2hlcyBsaXN0IC0tZm9ybWF0IGNzdg0K"
$base64poolinfo = "aXNpIHN0b3JhZ2Vwb29sIGxpc3QgLS1mb3JtYXQgY3N2"
$base64versionnodes = "aXNpX2Zvcl9hcnJheSAtc1ggdW5hbWUgLWENCg0K"
$base64productnodes = "aXNpX2Zvcl9hcnJheSAtc1ggaXNpX2h3X3N0YXR1cyB8IGdyZXAgUHJvZHVjdA=="
$base64serialinfoall = "aXNpX2Zvcl9hcnJheSAtc1ggaXNpX2h3X3N0YXR1cyB8IGdyZXAgU2VyTm8="

$Content = [System.Convert]::FromBase64String($Base64shares )
Set-Content -Path $env:temp\shares.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($Base64quotas )
Set-Content -Path $env:temp\quotas.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($base64disk )
Set-Content -Path $env:temp\disk.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($base64packages )
Set-Content -Path $env:temp\packagesinfo.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($base64poolinfo )
Set-Content -Path $env:temp\poolinfo.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($base64versionnodes )
Set-Content -Path $env:temp\versionnodes.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($base64productnodes )
Set-Content -Path $env:temp\productnodes.txt -Value $Content -Encoding Byte

$Content = [System.Convert]::FromBase64String($base64serialinfoall )
Set-Content -Path $env:temp\base64serialinfoall.txt -Value $Content -Encoding Byte

$quotasandzones = "$env:temp\shares.txt" 
$sharesandzones = "$env:temp\quotas.txt"
$diskinfo = "$env:temp\disk.txt"
$packagesinfo = "$env:temp\packagesinfo.txt"
$poolinfo = "$env:temp\poolinfo.txt"
$versionnodes = "$env:temp\versionnodes.txt"
$productnodes = "$env:temp\productnodes.txt"
$serialinfoall = "$env:temp\base64serialinfoall.txt"


#decodebash

$username = $sourceLogin[2]
$password = $sourceLogin[3]
$hostname = $sourceLogin[1]

function Invoke-Plink {
    param (
        [string] $ipa,
        [string] $cmd,
        [string] $usr,
        [string] $pwd,
        [string] $m
    )

    if ($cmd) {
        echo y | .\plink.exe $usr@$ipa -pw $pwd $cmd
    } else {
        echo y | .\plink.exe $usr@$ipa -pw $pwd -m $m
    }
}


function getquotas {
    $ssh1 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $quotasandzones 
    $Output1 += $ssh1
    $finalpatch = $sourceLogin[4] + "\" + $sourceLogin[0] + "_quotas_info.txt"
    Write-Output $Output1 | Out-File $finalpatch
}

function getshares {
     $ssh2 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $sharesandzones 
     $Output2 += $ssh2
     $finalpatch2 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_shares_info.txt"
     Write-Output $Output2 | Out-File $finalpatch2
    }

function getdisk {
     $ssh3 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $diskinfo  
     $Output3 += $ssh3
     $finalpatch3 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_disk_info.txt"
     Write-Output $Output3 | Out-File $finalpatch3  
    } 
        
function getpackages {
     $ssh4 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $packagesinfo  
     $Output4 += $ssh4
     $finalpatch4 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_packages_info.txt"
     Write-Output $Output4 | Out-File $finalpatch4  
    }
    
function getpool {
     $ssh5 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $poolinfo  
     $Output5 += $ssh5
     $finalpatch5 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_pool_info.txt"
     Write-Output $Output5 | Out-File $finalpatch5  
       }

function getversionall {
     $ssh6 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $versionall  
     $Output6 += $ssh6
     $finalpatch6 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_versionall_info.txt"   
     Write-Output $Output6 | Out-File $finalpatch6  
  }
         
function getversionnodes {
  $ssh7 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $versionnodes  
  $Output7 += $ssh7
  $finalpatch7 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_versionnodes_info.txt"   
  Write-Output $Output7 | Out-File $finalpatch7    
}

function getproductnodes {
  $ssh8 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $productnodes  
  $Output8 += $ssh8
  $finalpatch8 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_productnodes_info.txt"   
  Write-Output $Output8 | Out-File $finalpatch8  
       
    }

function getserialinfoall {
    $ssh9 =  Invoke-Plink -ipa $hostname  -usr $username -pw $password -m $serialinfoall  
    $Output9 += $ssh9
    $finalpatch9 = $sourceLogin[4] + "\" + $sourceLogin[0] + "_serialinfoall_info.txt"   
    Write-Output $Output9 | Out-File $finalpatch9         
          }

getshares
getquotas
getdisk
getpackages
getpool
getversionnodes
getproductnodes
getserialinfoall


write-host "Done!"