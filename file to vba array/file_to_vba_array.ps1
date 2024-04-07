param
(
    [String]$filePath = "",
    [String]$outputPath = ""
)

function generate_function($funcNumber, $segments, $path) 
{
    $functionStart = "Sub save_payload_to_disk_$funcNumber(filePath As String)`r`n"
    $declarationString = "`tDim hexDataArray(1 To $($segments.Count)) As String`r`n`t"
    $functionEnd = "`r`nEnd Sub`r`n"
    $comment = "`r`n`r`n`t' write_to_disk filePath, hexDataArray"
    $finalOutput = $functionStart + $declarationString + ($segments -join "`r`n`t") + $comment + $functionEnd
    Add-Content -Path $path -Value $finalOutput -Encoding ASCII
}

$fileStream = [io.file]::OpenRead($filePath)

# Store file contents into an array of bytes
$fileContent = New-Object Byte[] $fileStream.Length
$fileStream.Read($fileContent, 0, $fileStream.Length)
$fileStream.Close()

$maxLength = 38 # Determines the length of each hex string in the array.
$segmentStrings = @() # Array to hold each hex string
$hexString = ""
$index = 1
$functionNumber = 1
$elementsPerFunction = 2500

foreach ($byte in $fileContent) 
{
    $hexString += $byte.ToString("X2")
    if ($hexString.Length -ge $maxLength) 
    {
        if ($index -le $elementsPerFunction) 
        {
            $segmentStrings += "hexDataArray($index) = `"$hexString`""
            $index++
        }
        else 
        {
            generate_function $functionNumber $segmentStrings $outputPath
            $functionNumber++
            $segmentStrings = @()
            $index = 1
            $segmentStrings += "hexDataArray($index) = `"$hexString`""
            $index++
        }
        $hexString = ""
    }
}

if ($hexString.Length -gt 0) 
{
    $segmentStrings += "hexDataArray($index) = `"$hexString`""
}

if ($segmentStrings.Count -gt 0) 
{
    generate_function $functionNumber $segmentStrings $outputPath
}
