#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

If $CmdLine[0]<1 Then Exit

$txt=FileRead($CmdLine[1])
$e=@error
$cur=ver($txt)
$nxt=Int($cur)+1

MsgBox(0,0,'['&$CmdLine[1]&']'&@CRLF&"["&$cur&"]"&@CRLF&$txt&@CRLF&$e&@CRLF&@extended&@CRLF&FileGetSize($CmdLine[1]))

$txt="0:"&$nxt&"M ### NOTE: This is an interval version file, it does not represent a revision number."


ConsoleWrite($txt)

FileDelete($CmdLine[1])
Sleep(1000)
FileWrite($CmdLine[1],$txt)

Exit

Func ver($s)
	$s = StringStripWS($s, 8)
	If StringLen($s) = 0 Then Return SetError(1, 0, 0)
	Local $a = StringSplit($s, ':')
	Local $max = 0
	For $i = 1 To UBound($a) - 1
		$a[$i] = Int($a[$i])
		If $a[$i] > $max Then $max = $a[$i]
	Next
	If $max = 0 Then Return SetError(2, 0, 0)
	Return SetError(0, 0, $max)
EndFunc   ;==>ver




