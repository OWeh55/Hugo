;; geometry (with angle in degree)
Func SinD($phi)
	Return Sin($phi * $degToRad)
EndFunc   ;==>SinD

Func CosD($phi)
	Return Cos($phi * $degToRad)
EndFunc   ;==>CosD

Func Rotate($phi, ByRef $rx, ByRef $ry)
	;; rotate about origin (or z axis)
	Local $x = $rx
	Local $y = $ry
	Local $cc = CosD($phi)
	Local $ss = SinD($phi)
	$rx = $cc * $x - $ss * $y
	$ry = $ss * $x + $cc * $y
EndFunc   ;==>Rotate

Func Shift($dx, $dy, ByRef $rx, ByRef $ry)
	$rx = $rx + $dx
	$ry = $ry + $dy
EndFunc   ;==>Shift

Func RotateXYZ($phiX, $phiY, $phiZ, ByRef $x, ByRef $y, ByRef $z)
	;; rotation about x axis
	Rotate($phiX, $y, $z)
	;; rotation about y axis
	Rotate($phiY, $z, $x)
	;; rotation about z axis
	Rotate($phiZ, $x, $y)
EndFunc   ;==>RotateXYZ

Func RotateFromTo($phiX, $phiY, $phiZ, $xs, $ys, $zs, ByRef $x, ByRef $y, ByRef $z)
	$x = $xs
	$y = $ys
	$z = $zs
	;; rotation about x axis
	Rotate($phiX, $y, $z)
	;; rotation about y axis
	Rotate($phiY, $z, $x)
	;; rotation about z axis
	Rotate($phiZ, $x, $y)
EndFunc   ;==>RotateFromTo
