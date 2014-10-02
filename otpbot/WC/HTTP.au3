
#include-once
Global Enum $_INETREAD_BUILTIN=0, $_INETREAD_MANUAL,$_INETREAD_MODES
Global $_INETREAD_MODE=$_INETREAD_MANUAL
Global $_HTTP_Event_Debug=''
Global $_HTTP_Client_Name="UnknownHTTPClient"
Global $_HTTP_Client_Version="1.0"
Global $_HTTP_DebugRequests=1



;TCPStartup()
Func _InetRead($url,$opt=0)
	ConsoleWrite("Read: "&$url&@CRLF)
	Local $ts=TimerInit()
	Local $ret,$err,$ext
	Switch $_INETREAD_MODE
		Case $_INETREAD_BUILTIN
			$ret=InetRead($url,$opt)
			$err=@error
			$ext=@extended
		Case $_INETREAD_MANUAL
			$ret=_InetRead_Manual($url,$opt)
			$err=@error
			$ext=@extended
	EndSwitch
	If TimerDiff($ts)>11000 And StringLen($_HTTP_Event_Debug) Then
		Call($_HTTP_Event_Debug,"HTTP: Took more than 10s to load url="&$url&" opt="&$opt&" inetreadmode="&$_INETREAD_MODE)
		$_INETREAD_MODE=Mod($_INETREAD_MODE+1,$_INETREAD_MODES)
	EndIf
	Return SetError($err,$ext,$ret)
EndFunc
Func _InetRead_Manual($url,$opt=0)
	Local $sRecv_Out=''
	Local $req=__HTTP_Req('GET', $url)
	__HTTP_Transfer($req, $sRecv_Out,100000,100000);10s max
	If StringLen($sRecv_Out)=0 Then Return SetError(1,0,'')
	;ConsoleWrite(@CRLF&$sRecv_Out&@CRLF)
#cs
	Local $iPos=StringInStr($sRecv_Out,@LF&@LF)+2
	If $iPos<=2 Then $iPos=StringInStr($sRecv_Out,@CRLF&@CRLF)+4
	If $iPos>4 Then
		$sRecv_Out=StringMid($sRecv_Out,$iPos)
	Else
		$sRecv_Out=""
	EndIf
#ce
	_HTTP_StripToContent($sRecv_Out)
	Return StringToBinary($sRecv_Out)
EndFunc
Func _HTTP_StripToContent(ByRef $sRecvd)
	Local $iPos=StringInStr($sRecvd,@LF&@LF)+2
	Local $iPosB=StringInStr($sRecvd,@CRLF&@CRLF)+4
	If $iPosB<$iPos Or $iPos<=2 Then $iPos=$iPosB
	If $iPos>4 Then
		$sRecvd=StringMid($sRecvd,$iPos)
	Else
		$sRecvd=""
	EndIf
EndFunc
Func __HTTP_Req($Method = 'GET', $url = 'http://example.com/', $Content = '', $extraHeaders = '')
	;ConsoleWrite($Method&' '&$url&@CRLF)
	Local $aRet[4]
	$url = StringTrimLeft($url, StringInStr($url, '://') + 2)
	Local $pos = StringInStr($url, '/')
	Local $HOST = StringLeft($url, $pos - 1)
	Local $PORT = 80
	Local $pColon = StringInStr($HOST, ':')
	If $pColon > 0 Then
		$PORT = StringMid($HOST, $pColon + 1)
		$HOST = StringLeft($HOST, $pColon - 1)
	EndIf
	$url = StringMid($url, $pos)
	Local $HTTPRequest = $Method & ' ' & $url & ' HTTP/1.0' & @CRLF & _
			'Accept-Language: en-US,en;q=0.5' & @CRLF & _
			'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' & @CRLF & _
			'Host: ' & $HOST & @CRLF & _
			'Cache-Control: no-cache' & @CRLF & _
			'User-Agent: Mozilla/1.0 (Windows; like MS-DOS) CDHTTPAU3/1.0 '&$_HTTP_Client_Name&'/'&$_HTTP_Client_Version & @CRLF & _
			'Connection: close' & @CRLF
	If StringLen($extraHeaders) > 0 Then $HTTPRequest &= $extraHeaders
	If StringLen($Content) > 0 Then
		$HTTPRequest &= 'Content-Length: ' & StringLen($Content) & @CRLF
		$HTTPRequest &= @CRLF & $Content;&@CRLF
	Else
		$HTTPRequest &= @CRLF
	EndIf
	$aRet[0] = $HOST
	$aRet[1] = $url; now a URI
	$aRet[2] = $HTTPRequest
	$aRet[3] = $PORT
	If $_HTTP_DebugRequests Then ConsoleWrite($HTTPRequest&@CRLF)
	Return $aRet
EndFunc   ;==>__HTTP_Req
Func __HTTP_Transfer(ByRef $aReq, ByRef $sRecv_Out, $limit = 0, $timeout=0)
	;ConsoleWrite($aReq[2]&@CRLF)
	$sRecv_Out = ""
	Local $error = 0
	Local $addr=_TCPNameToIP($aReq[0])
	Local $SOCK = _TCPConnect($addr, $aReq[3])
	If @error<>0 Or $SOCK=-1 Then _HTTP_ErrorEx($aReq,$addr,$SOCK,$error,'Connect',$sRecv_Out)
	If $_HTTP_DebugRequests Then ConsoleWrite($addr&@CRLF)
	;ConsoleWrite('HTTPSock: '&$aReq[0]&'//'&$aReq[3]&'//'&$sock&'//'&@error&@CRLF)
	_TCPSend($SOCK, $aReq[2])
	If @error<>0 Then _HTTP_ErrorEx($aReq,$addr,$SOCK,$error,'SendRequest',$sRecv_Out)

;Call($_HTTP_Event_Debug,"HTTP: SConnection error="&@error&" ("&Hex(@error)&") inetreadmode="&$_INETREAD_MODE)
	Local $ts=TimerInit()
	While $SOCK <> -1
		Local $recv = _TCPRecv($SOCK, 50000, 1)
		If @error <> 0 Then $error = @error
		If $timeout > 0 And TimerDiff($ts)>$timeout Then $error=0xB33F
		If $limit > 0 And StringLen($sRecv_Out) > $limit Then $error = 0xBEEF
		If IsBinary($recv) Then $recv = BinaryToString($recv)
		$sRecv_Out &= $recv
		If $error <> 0 Then
			;MsgBox(0,0,$error)
			If $error<>-1 And $error<>0xB33F And $error<>0xBEEF Then _HTTP_ErrorEx($aReq,$addr,$SOCK,$error,'ReceiveResponseLoop',$sRecv_Out)
			;If $SOCK<>-1 Then TCPCloseSocket($SOCK)
			;$SOCK = -1
			ExitLoop
		EndIf


		;Sleep(50)
WEnd
;ConsoleWrite($sRecv_Out&@CRLF)
	If $SOCK<>-1 Then TCPCloseSocket($SOCK)
	;ConsoleWrite('HTTPSockError: '&$error&@CRLF)
EndFunc   ;==>__HTTP_Transfer
Func _TCPNameToIP($hostname)
	ConsoleWrite("NameToIP: "&$hostname&@CRLF)
	Local $r=TCPNameToIP($hostname)
	Local $e=@error
	Local $x=@extended
	If $e==0 Then
		Switch StringLeft($r,3)
			Case '127','10.','239.'
				$e=0xBADF00D
				$r=''
		EndSwitch
	EndIf
	If $e<>0 Then _TCP_Error($e,"NameToIP",$hostname,$r,0,0,0)
	Return SetError($e,$x,$r)
EndFunc
Func _TCPConnect($addr,$port)
	;ConsoleWrite("conn"&@CRLF)
	Opt('TCPTimeout',250)
	Local $r=TCPConnect($addr,$port)
	Local $e=@error
	Local $x=@extended
	;ConsoleWrite("retu"&@CRLF)
	If $e<>0 Then _TCP_Error($e,"Connect",$addr,$port,$r,0,0)
	Return SetError($e,$x,$r)
EndFunc
Func _TCPRecv(ByRef $sock,$len,$flag=0)
	If $sock=-1 Then Return
	Opt('TCPTimeout',250)
	Local $r=TCPRecv($sock,$len,$flag)
	Local $e=@error
	Local $x=@extended
	;ConsoleWrite("recv "&$sock&' '&StringLen($r)&'/'&$len&' '&$flag&' Err:'&$e&' Ext:'&$x&@CRLF)
	If $e=0 And $x<>0 Then $e=0xBAD000+$x
	If $e<>0 Then _TCP_Error($e,"Recv",'','',$sock,StringLen($r)&'/'&$len,$flag)
	If $e=-1 Or $e=-2 Then;socket invalid or not connected
		TCPCloseSocket($sock)
		$sock=-1
	EndIf
	Return SetError($e,$x,$r)
EndFunc
Func _TCPSend($sock,$data)
	If $sock=-1 Then Return
	Local $r=TCPSend($sock,$data)
	Local $e=@error
	Local $x=@extended
	If StringLen($data)=0 And BinaryLen($data)=0 Then $e=0xBADF00D
	If $e<>0 Then _TCP_Error($e,"Send",'','',$sock,$r&'/'&StringLen($data),0)
	Return SetError($e,$x,$r)
EndFunc
Func _TCP_Error($error,$state,$addr,$port,$sock,$len,$flag)
	Call($_HTTP_Event_Debug,StringFormat("TCP: Error %s (%s) During %s on host %s:%s. socket %s. Buffer size: %s. Flag: %s", _
	$error,Hex($error),$state,$addr,$port,$sock,$len,$flag))
EndFunc
Func _HTTP_Error($aReq,$address,$sock,$error,$state)
	Local $buffer=""
	_HTTP_ErrorEx($aReq,$address,$sock,$error,$state,$buffer)
EndFunc
Func _HTTP_ErrorEx($aReq,$address,$sock,$error,$state, ByRef $buffer)
	 Call($_HTTP_Event_Debug,StringFormat("HTTP: Error %s (%s) during %s on host %s (%s) socket %s. Buffer size: %s. Inetreadmode: %s", _
	 $error, Hex($error), $state, $aReq[0], $address, $sock, StringLen($buffer),$_INETREAD_MODE))
EndFunc
; Thanks Progandy
Func _URIEncode($sData)
	; Prog@ndy
	Local $aData = StringSplit(BinaryToString(StringToBinary($sData, 4), 1), "")
	Local $nChar
	$sData = ""
	For $i = 1 To $aData[0]
		$nChar = Asc($aData[$i])
		Switch $nChar
			Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
				$sData &= $aData[$i]
			Case 32
				$sData &= "+"
			Case Else
				$sData &= "%" & Hex($nChar, 2)
		EndSwitch
	Next
	Return $sData
EndFunc   ;==>_URIEncode

