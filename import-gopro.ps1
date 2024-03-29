$path = "D:\GoProVideos"
$cameras = @{
	1 = "Max"
	2 = "Hero10-1"
	3 = "Unknown"
}
foreach ($camera in $cameras.Keys) {
	$camerasString = "$($camera).) $($cameras[$camera])`n$($camerasString)"
}
$cameraPrompt = @"
Which Camera are you importing files from? (Enter Number)
$camerasString
"@
while ($true) {
	$cameraChoice = Read-Host $cameraPrompt
	if ($cameras.ContainsKey([int]$cameraChoice)){break}
	Write-Host "Please Enter a Valid Camera Number" -ForegroundColor Red
}
$deletePrompt = "Do you want to delete the files after import? (y/n)"
while ($true) {
	$deleteChoice = Read-Host $deletePrompt
	if ($deleteChoice -eq "y" -or $deleteChoice -eq "n"){break}
	Write-Host "Please y for Yes and n for No" -ForegroundColor Red
}
$cameraPath = "$($cameras[[int]$cameraChoice])"
$pictureFiles = (Get-ChildItem | where {$_.extension -in ".JPG"})
$videoFiles = (Get-ChildItem | where {$_.extension -in ".mp4", ".360", ".wav"})
$extraFiles = (Get-ChildItem | where {$_.extension -in ".LRV", ".THM"})
function folderStructure {
	param([object]$file, $cameraPath)
	$m,$d,$y,$t = $file.CreationTime -split '[/, ]'
	$abbvMonth = (Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($m)
	$script:outPath = "$($path)\$($y)\$($m)-$($abbvMonth)\$($d)\$($cameraPath)"
	if (-not(test-path -path $outPath)) {
		New-Item -Path $outPath -ItemType "directory"
	}
}
foreach ($file in $pictureFiles) {
	folderStructure $file $cameraPath
	Start-BitsTransfer -source $file.FullName -Destination $outPath\$file -Description "Importing $($file) to $($outPath)\$($file.name)" -DisplayName "Import GoPro Pictures"
	if ($deleteChoice -eq "y") {
		Remove-Item $file
	}
}
foreach ($file in $videoFiles) {
	$extension = $file.Extension
	$filename = $file.BaseName
	$video = $filename.SubString(4,4)
	$chap = $filename.SubString(2,2)
	$fileType = $filename.SubString(0,2)
	folderStructure $file $cameraPath
	Start-BitsTransfer -source $file.FullName -Destination $outPath\$filetype"_v"$video"_ch"$chap$extension -Description "Importing $($file) to $($outPath)\$($filetype)_v$($video)_ch$($chap)$($extension)" -DisplayName "Import GoPro Video"
	if ($deleteChoice -eq "y") {
		Remove-Item $file
	}
}
if ($deleteChoice -eq "y") {
	foreach ($file in $extraFiles) {
		Remove-Item $file
	}
}
Write-Output "Import Complete at $(Get-Date)"