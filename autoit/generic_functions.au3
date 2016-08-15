;; generic functions
Func Bool($val)
	If IsBool($val) Then
		Return $val;
	Else
		Return $val = "True"
	EndIf
EndFunc   ;==>Bool
;;
Func C2RegExp($str)
	;; C Formatstring in einen regulären Ausdruck umsetzen
	;; versteht zur zeit %d, %s
	Local $res
	$res = StringRegExpReplace($str, "%[0-9.]*d", "[0-9]*")
	$res = StringRegExpReplace($res, "%[0-9]*s", ".*")
	$res = StringRegExpReplace($res, "\(", "\\(")
	$res = StringRegExpReplace($res, "\)", "\\)")

	Return $res
EndFunc   ;==>C2RegExp

;; Funktionen zur Verwaltung von Bit-Werten in einem int
Func BitSet(ByRef $val, $mask)
	$val = BitOR($val, $mask)
EndFunc   ;==>BitSet

Func BitReset(ByRef $val, $mask)
	$val = BitAND($val, BitNOT($mask))
EndFunc   ;==>BitReset

Func BitTest($val, $mask)
	Return (BitAND($val, $mask) > 0)
EndFunc   ;==>BitTest
