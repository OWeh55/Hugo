;; Funktionen zum Aufruf von gleis.dll

Global $DLLGleisStruct = DllStructCreate("double g[" & $TrackDataLen & "]")
Global $DLLGleisPtr = DllStructGetPtr($DLLGleisStruct)

Global $GleisDLL = DllOpen("gleis.dll")
If $GleisDLL == -1 Then
	FatalError("gleis.dll nicht gefunden");
EndIf

Func GleisToStruct(ByRef $gleis)
	For $i = 0 To $TrackDataLen - 1
		DllStructSetData($DLLGleisStruct, 1, $gleis[$i], $i + 1)
	Next
EndFunc   ;==>GleisToStruct

Func GleisFromStruct(ByRef $gleis)
	For $i = 0 To $TrackDataLen - 1
		$gleis[$i] = DllStructGetData($DLLGleisStruct, 1, $i + 1)
	Next
EndFunc   ;==>GleisFromStruct

Func GetTrack(ByRef $Verbindung, $idx)
	Local $gleis[$TrackDataLen]
	Local $res = DllCall($GleisDLL, "int", "gGetTrack", "int", $idx, "ptr", $DLLGleisPtr)
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	If $res[0] == 0 Then
		GleisFromStruct($gleis)
		;;_ArrayDisplay($gleis)
		CopyTrackToArray($gleis, $Verbindung, $idx)
		;;_ArrayDisplay($verbindung)
	Else
		FatalError("Index-Fehler in GetTrack");
	EndIf
EndFunc   ;==>GetTrack

Func GetTrackParameter(ByRef $gleis, $idx)
	Local $res = DllCall($GleisDLL, "int", "gGetTrackParameter", "int", $idx, "ptr", $DLLGleisPtr)
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	If $res[0] == 0 Then
		GleisFromStruct($gleis)
	Else
		FatalError("GetTrackParameter");
	EndIf
EndFunc   ;==>GetTrackParameter

Func SetTrackParameter(ByRef $gleis, $idx)
	GleisToStruct($gleis)
	Local $res = DllCall($GleisDLL, "int", "gSetTrackParameter", "ptr", $DLLGleisPtr, "int", $idx)
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf
	If $res[0] <> 0 Then
		FatalError("SetTrackParameter");
	EndIf
EndFunc   ;==>SetTrackParameter

Func ErgaenzeGleis(ByRef $gleis)
	SetTrackParameter($gleis, 0)
	GetTrackParameter($gleis, 0)
EndFunc   ;==>ErgaenzeGleis

Func InvertiereGleis(ByRef $gleis)
	SetTrackParameter($gleis, 0)
	Local $res = DllCall($GleisDLL, "int", "gInvert")
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf
	If $res[0] <> 0 Then
		FatalError("InvertiereGleis");
	EndIf
	GetTrackParameter($gleis, 0)
EndFunc   ;==>InvertiereGleis

Func VerschiebeGleis(ByRef $gleis, $d, $dh)
	SetTrackParameter($gleis, 0)
	Local $res = DllCall($GleisDLL, "int", "gShift", "double", $d, "double", $dh)
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	If $res[0] <> 0 Then
		FatalError("VerschiebeGleis");
	EndIf
	GetTrackParameter($gleis, 0)
EndFunc   ;==>VerschiebeGleis

Func Optimize1(ByRef $StartGleis, ByRef $EndGleis, ByRef $Verbindung, $mode)
	SetTrackParameter($StartGleis, 0)
	SetTrackParameter($EndGleis, 1)

	Local $res = DllCall($GleisDLL, "int", "gOptimize1", "int", $SollGleisAnz, "int", $mode)

	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	Return $res[0]
EndFunc   ;==>Optimize1

Func Optimize2(ByRef $StartGleis, ByRef $EndGleis, ByRef $Verbindung, $rad)
	SetTrackParameter($StartGleis, 0)
	SetTrackParameter($EndGleis, 1)

	Local $res = DllCall($GleisDLL, "int", "gOptimize2", "double", $rad)
	;;MsgBox(0,"Optimize","optimize: " & $res[0])
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	Return $res[0]

EndFunc   ;==>Optimize2

Func GenerateGKG(ByRef $StartGleis, ByRef $EndGleis, ByRef $Verbindung, $rad)
	SetTrackParameter($StartGleis, 0)
	SetTrackParameter($EndGleis, 1)

	Local $res = DllCall($GleisDLL, "int", "gGenerateGKG", "double", $rad)
	;;MsgBox(0,"Optimize","optimize: " & $res[0])
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	Return $res[0]

EndFunc   ;==>GenerateGKG

Func GenerateKG(ByRef $StartGleis, ByRef $EndGleis, ByRef $Verbindung)
	SetTrackParameter($StartGleis, 0)
	SetTrackParameter($EndGleis, 1)

	Local $res = DllCall($GleisDLL, "int", "gGenerateKG")
	If @error <> 0 Then
		FatalError("Fehler in gleis.dll");
	EndIf

	Return $res[0]

EndFunc   ;==>GenerateKG

Func Optimize(ByRef $StartGleis, ByRef $EndGleis, ByRef $Verbindung, $mode)
	Local $res;
	Switch ($mode)
		Case 1 To 2
			$res = Optimize1($StartGleis, $EndGleis, $Verbindung, $mode)
		Case 3
			$res = GenerateKG($StartGleis, $EndGleis, $Verbindung)
		Case 4
			$res = Optimize2($StartGleis, $EndGleis, $Verbindung, $TrackRad)
		Case 5
			$res = GenerateGKG($StartGleis, $EndGleis, $Verbindung, $TrackRad)
	EndSwitch

	If $res > 0 Then
		$res = DllCall($GleisDLL, "int", "gSplit", "double", $TrackMaxLen)
		If $samft > 0 Then
			$res = DllCall($GleisDLL, "int", "gOptHeight")
		Else
			$res = DllCall($GleisDLL, "int", "gLinHeight")
		EndIf
		If @error <> 0 Then
			FatalError("Fehler in gleis.dll: " & @error);
		EndIf

		$IstGleisAnz = $res[0]
		If $IstGleisAnz > $MaxGleise Then
			Return -1
		EndIf

		For $i = 0 To $IstGleisAnz - 1
			GetTrack($Verbindung, $i)
		Next
		;;_ArrayDisplay($verbindung)
		Return 1

	EndIf

	Return $res
EndFunc   ;==>Optimize
