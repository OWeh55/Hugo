Func BinarySearch2(Const ByRef $avArray, $vValue)
	Local $iUBound = UBound($avArray) - 1

	; Bounds checking
	Local $iEnd = $iUBound
	Local $iStart = 0

	Local $iMid = Int(($iEnd + $iStart) / 2)

	If $avArray[$iStart][0] > $vValue Or $avArray[$iEnd][0] < $vValue Then Return -1

	; Search
	While $iStart <= $iMid And $vValue <> $avArray[$iMid][0]
		If $vValue < $avArray[$iMid][0] Then
			$iEnd = $iMid - 1
		Else
			$iStart = $iMid + 1
		EndIf
		$iMid = Int(($iEnd + $iStart) / 2)
	WEnd

	If $iStart > $iEnd Then Return -1 ; Entry not found

	Return $iMid
EndFunc   ;==>BinarySearch2

Func ReadLanguageFile(ByRef $skv, $file)
	Local $sname = IniReadSectionNames($file)
	If @error Then
		FatalError($file & " invalid")
	EndIf

	Local $nsection = $sname[0]

	Dim $skv[$nsection][2]
	For $i = 0 To $nsection - 1
		Local $sectionname = $sname[$i + 1]
		$skv[$i][0] = $sectionname
		Local $section = IniReadSection($file, $sectionname)
		Local $nkey = $section[0][0]
		Local $kv[$nkey][2]
		For $k = 0 To $nkey - 1
			$kv[$k][0] = $section[$k + 1][0]
			$kv[$k][1] = $section[$k + 1][1]
		Next
		_ArraySort($kv)
		$skv[$i][1] = $kv
	Next

	_ArraySort($skv)
	#cs
		_ArrayDisplay($skv)

		For $i = 0 To $nsection - 1
		_ArrayDisplay($skv[$i][1])
		Next
	#ce
EndFunc   ;==>ReadLanguageFile

Func Msg2(Const ByRef $sect, $key)
     ;; search for key in section
	Local $midx = BinarySearch2($sect, $key)
	If $midx < 0 Then
		FatalError("Fehlender Text : " & $key)
	Else
		Return $sect[$midx][1]
	EndIf
EndFunc   ;==>Msg2

Func Msg(Const ByRef $skv, $section, $key)
     ;; search for section
	Local $sidx = BinarySearch2($skv, $section)
	If $sidx < 0 Then
		FatalError("Fehlender Text in " & $skv & ": " & $section & "/" & $key)
	Else
	;; search for message in section
		Return Msg2($skv[$sidx][1], $key)
	EndIf
EndFunc   ;==>Msg

Func MsgH($section, $key)
	Return Msg($hugo_lang, $section, $key)
EndFunc   ;==>MsgH

Func MsgE($section, $key)
	Return Msg($eep_lang, $section, $key)
EndFunc   ;==>MsgE
