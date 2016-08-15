;; drawing in 3d
Func append3(ByRef $points, $x, $y, $z)
	Local $p[3] = [$x, $y, $z]
	Local $size = UBound($points)
	ReDim $points[$size + 1]
	$points[$size] = $p ;
EndFunc   ;==>append3

Func append4(ByRef $points, $x, $y, $z, $color)
	Local $p[4] = [$x, $y, $z, $color]
	Local $size = UBound($points)
	ReDim $points[$size + 1]
	$points[$size] = $p ;
EndFunc   ;==>append4

Func drawPoly3d(ByRef $points, ByRef $immo)
	Local $nPoints = UBound($points) - 1
	Local $factor = $xsize / 4
	Local $center = $xsize / 2
	Local $color = -1
	For $i = 1 To $nPoints
		Local $p[3]
		$p = $points[$i]
		Local $x = $p[0] * $factor
		Local $y = $p[1] * $factor
		Local $z = $p[2] * $factor
		If UBound($p) > 3 Then
			$color = $p[3]
		EndIf

		;; Rotation !
		RotateXYZ($immo[$iifx], $immo[$iify], $immo[$iifz], $x, $y, $z)

		;; MsgBox(0,"x y z c",$x & " " & $y & " " &$z & " " &$color)
		If $color >= 0 Then
			GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color)
		EndIf

		Local $zfak = 4 * $factor / (-$z + (4 * $factor))
		;;MsgBox(0, "X Y Zfak", $x & " " & $y & " " & $zfak, 0.3)
		$x = $x * $zfak
		$y = $y * $zfak

		If $color < 0 Then
			GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, $x + $center, -$y + $center)
		Else
			GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $x + $center, -$y + $center)
		EndIf

	Next
EndFunc   ;==>drawPoly3d
