<# 
.SYNOPSIS 
   Returns the MIME-Type of a file 
.DESCRIPTION 
   This PS function uses the System.Web.MimeMapping assembly to identify the  
   the MIME-Type of a file 
.PARAMETER CheckFile 
   Input file to check for the Mimetype 
.EXAMPLE  
    Write the MIME-Type to Console 
    Get-MimeType -CheckFile "C:\tmp\mySheet.xls" 
.EXAMPLE  
    Write the MIME-Type to a variable 
    $myMimeType = $(Get-MimeType -CheckFile "C:\tmp\myFile.png") 
#> 
function Get-MimeType() { 
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)][ValidateNotNullorEmpty()][System.IO.FileInfo]$CheckFile) 
    begin { 
        Add-Type -AssemblyName "System.Web"         
        [System.IO.FileInfo]$check_file = $CheckFile 
        [string]$mime_type = $null 
    } 
    process { 
        if ($check_file.Exists) {  
            $mime_type = [System.Web.MimeMapping]::GetMimeMapping($check_file.FullName)  
        } 
        else { 
            $mime_type = "false" 
        } 
    } 
    end { return $mime_type } 
}