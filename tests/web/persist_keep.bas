Dim s As String
If _FileExists("keep.txt") Then
    Open "keep.txt" For Input As #1
    Line Input #1, s
    Close #1
    Print "FOUND:" + s
Else
    Print "NEW"
End If
Open "keep.txt" For Output As #1
Print #1, "saved" + Str$(Timer > -1)
Close #1
MkDir "sub"
Open "sub/b.bin" For Binary As #2
Put #2, , s
Close #2
Open "gone.txt" For Output As #3
Print #3, "x"
Close #3
Kill "gone.txt"
Print "SEES gone:" + Str$(_FileExists("gone.txt"))
Print "SEES sub/b.bin:" + Str$(_FileExists("sub/b.bin"))
