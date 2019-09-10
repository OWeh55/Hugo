#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=hugo.ico
#AutoIt3Wrapper_Outfile=hugo.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiButton.au3>
#include <GuiListView.au3>
#include <Constants.au3>
#include <WinAPI.au3>
#include <GDIPlus.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>

AutoItSetOption("MustDeclareVars", 1)
Opt("WinTitleMatchmode", -1)

; Konstanten
Global Const $PName = "hugo"

Global Const $Version = "2.2.4"

Global Const $MaxGleise = 150
Global Const $SpeedLogSize = 120

; indices in track data array
Global Const $TrackDataLen = 15

;; basic data from input
;; enough to call gleis.dll
Global Const $ix = 0
Global Const $iy = 1
Global Const $idir = 2
Global Const $iangle = 3
Global Const $ilen = 4
Global Const $ih1 = 5
Global Const $igrad = 6

;; extended data
;; delivered by gleis.dll
;; used by graphic, ...

Global Const $ieh2 = 7
Global Const $ixe = 8
Global Const $iye = 9
Global Const $ixm = 10
Global Const $iym = 11
Global Const $irad = 12
Global Const $ifi1 = 13
Global Const $ifi2 = 14

; control id for property window

Global Const $id_angle = 1352
Global Const $id_len = 1356
Global Const $id_x = 1354
Global Const $id_y = 1359
Global Const $id_h1 = 1351
Global Const $id_dir = 1360
Global $id_steigung = 1310

Global Const $id_parmode = 1289

; indexes in object data
Global Const $iiname = 0
Global Const $iix = 1
Global Const $iiy = 2
Global Const $iiz = 3
Global Const $iizr = 4
Global Const $iifx = 5
Global Const $iify = 6
Global Const $iifz = 7
Global Const $iisc = 8
Global Const $iilight = 9

; control id for immo_property window
Global Const $iid_x = 1144
Global Const $iid_y = 1145
Global Const $iid_z = 1142
Global Const $iid_zr = 1143
Global Const $iid_fx = 1309
Global Const $iid_fy = 1378
Global Const $iid_fz = 1379
Global Const $iid_sc = 1394
Global Const $iid_light = 1103

Global Const $color[6] = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x00ffff, 0xffffff]
Global Const $BitMask[8] = [1, 2, 4, 8, 16, 32, 64, 128]

Global Const $degToRad = 3.14159265 / 180.0

;; button list is 2-dimensional array with editor and function as index
;; indices of editors in editor/button array
Global Const $eid_track = 0 ; index of track editor
Global Const $eid_tram = 1 ; index of tram editor
Global Const $eid_road = 2 ; index of road editor
Global Const $eid_water = 3 ; index of water editor

;; indices of buttons in editor/button array
Global Const $bid_track = 0; index of track button
Global Const $bid_switch = 1; index of Switch button
Global Const $bid_switch3 = 2; index of switch3 button
Global Const $bid_end = 3; index of End button
Global Const $bid_del = 4; index of del button
Global Const $bid_level = 5; index of level button
Global Const $bid_obj = 6; index of Obj button
Global Const $bid_copy = 7; index of copy button
Global Const $bid_left = 8; index of left button
Global Const $bid_forward = 9; index of forward button
Global Const $bid_right = 10; index of right button
Global Const $bid_inv = 11; index of inv button

;; status of graphics display
Global Const $TrackDisplay = 1
Global Const $ImmoDisplay = 2
Global Const $CombiDisplay = 3
Global Const $SpeedDisplay = 4

;; ini-Datei mit Nutzereinstellungen
Global Const $inifile = @ScriptDir & "\" & $PName & ".ini"

;; gespeicherte Werte für Immobilien...
Global Const $valfile = @ScriptDir & "\" & $PName & ".val"

;; Sprachdatei für Texte in hugo
Global Const $langfile = @ScriptDir & "\" & $PName & ".lng"

;; Sprachdatei von EEP, wird noch ermittelt
Global $eep_langfile

;; Arrays mit texten
Global $hugo_lang
Global $eep_lang

;; EEP-version - zunächst "unbekannt"
Global $EEPVersion = 0

;; registry section and directory path
Global $EEPSection
Global $EEPDir

; =============================================================================
;; werte für Gleis

Global $SollGleisAnz = 5; // Startwert soll-gleisanzahl

Global $StartGleis[$TrackDataLen] = [-99, 0, 0, 0, 99, 0.6, 0.6, False, 0, 0, 0]

Global $EndGleis[$TrackDataLen] = [300, -80, -20, 0, 99, 0.6, 0.6, False, 0, 0, 0]

;; Gleisverbindung
Global $Verbindung[$MaxGleise][$TrackDataLen]
Global $IstGleisAnz;  // Anzahl der Gleise in Verbindung

;; Startwerte für Positionen Immobilien
Global $ImmoPos1[10] = ["", 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $iValid = False

;; Startwert Verschiebung in x-Richtung
Global $ShiftX = 10
Global $ShiftY = 10

Global $doShiftXp = True
Global $doShiftXm = False
Global $doShiftYp = False
Global $doShiftYm = False
#cs
    Global $egalHeight = 0
    Global $egalRel = False
#ce
Global $LogStep = 4

#cs
    ;; Gleiskombination
    Global $cslen = 41
    Global $cswidth = 4.5

    Global $csx = 0
    Global $csy = 0
    Global $csdir = 0
    Global $csdir_rad = 0
    Global $csh1 = 0.6
    Global $csdhx = 0
    Global $csdhy = 0

    Global $csdirselect = 0x3f
    Global $cstrackselect[$TrackDataLen]

    Global $csOld[5][5]
    For $i = 0 To 4
    For $j = 0 To 4
    $csOld[$i][$j] = 0
    Next
    Next
#ce
;; Gleisbogenberechnung
Global $trackrad = 300
Global $samft = 0

Global $calculated = False ;; Gleis bereits berechnet ?
Global $trackstatus = 0 ;; (berechnetes) Gleis zulässig ?
Global $track_shift_x = 0 ;; keine Verschiebung
Global $track_shift_h = 0 ;; keine Verschiebung
Global $track_trans = 100
Global $track_short = 10
Global $minlen = 0
Global $maxlen = 100000
Global $minrad = 11
Global $minx = 0
Global $maxx = 0
Global $miny = 0
Global $maxy = 0

Global $xsize = 80
Global $ysize = 80

;; Gleis ersetzen / kopieren
Global $track2_shift_x = 0 ;; keine Verschiebung
Global $track2_shift_h = 0 ;; keine Verschiebung

Global $CurrentTime
Global $CurrentTimeMod

;; Timetable
Global $cycle = 24 * 3600
Global $ncycle = 2
Global $bgcolor = 0xbbbbbb
Global $gridcolor = 0xeeeeee

Global $LastParsedTime = 0

Global $gtimetable = 0
Global $tt_plan
Global $tt_selected_route = 1
Global $tt_route

;; GUI
Global $oldeditor = -1
Global $actionlist

Global $ScreenSize
;; Handler for EEP-Window
Global $eep
Global $editorlist

Global $CombiTab
Global $ImmoTab
Global $TrackTab

Global $TrackTab
Global $CombiTab
Global $Track2Tab
Global $ImmoTab
Global $TTTab
Global $SignalTab
Global $OptionTab

Global $DisplayStat = $TrackDisplay
Global $LastDisplay = $TrackDisplay
Global $DisplayNeedsRedraw = 0

Global $clockbutton

Global $editor = -77 ; Aktueller Editor (EEP-Nummer): zunächst "nichts"
Global $trackeditoridx = -1; Aktueller Gleis-Editor (Index in Tabelle der Buttons)
Global $objeditoridx = -1 ; Aktueller Objekt-Editor

Global $lasttime = 0
Global $getxlasttime = 0
Global $LastIndex = 0

;;_ArrayDisplay($labels)

Dim $speed[$SpeedLogSize]
Dim $sspeed[$SpeedLogSize]
Global $logcount = 0

Global $previewa

;; GUI TrackTab

Global $davorbutton
Global $danachbutton
Global $inverse1cb
Global $null1cb

Global $invflag = False
Global $nullflag = False

Global $gleisanzInput
Global $radinput

Global $modecombo

Global $tistanz
Global $tlen
Global $trad

Global $txx
Global $tyy

Global $PutTrackButton

Global $levelcb
Global $copycb

Global $dxinput
Global $dhinput

Global $samftcb
Global $transinput
Global $shortinput

;; GUI CombiTab
Global $csposbutton
Global $csinverse1cb
Global $csnull1cb

;; Gui ImmoTab

Global $getposbutton
Global $immodata

Global $shiftxinput

Global $shiftxpcb
Global $shiftxmcb

Global $shiftyinput

Global $shiftypcb
Global $shiftymcb

Global $setposbutton
Global $hrelcb

Global $save_as_default_cb

;; Clock
Global $clock_reset_button

;; allgemeine Funktionen
Func Bool($val)
    If IsBool($val) Then
        Return $val;
    Else
        Return $val = "True"
    EndIf
EndFunc   ;==>Bool

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

;; geometry (with angle in degree)
Func SinD($phi)
    Return Sin($phi * $degToRad)
EndFunc   ;==>SinD

Func CosD($phi)
    Return Cos($phi * $degToRad)
EndFunc   ;==>CosD

Func Rotate($phi, ByRef $rx, ByRef $ry)
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

Func Inside($winpos, $x, $y)
    Return $x > $winpos[0] And $x < $winpos[0] + $winpos[2] And $y > $winpos[1] And $y < $winpos[1] + $winpos[3]
EndFunc   ;==>Inside

Func WinListChildren($hWnd, ByRef $avArr)
    If UBound($avArr, 0) <> 2 Then
        Local $avTmp[10][2] = [[0]]
        $avArr = $avTmp
    EndIf

    Local $hChild = _WinAPI_GetWindow($hWnd, $GW_CHILD)

    While $hChild
        If $avArr[0][0] + 1 > UBound($avArr, 1) - 1 Then ReDim $avArr[$avArr[0][0] + 10][2]
        $avArr[$avArr[0][0] + 1][0] = $hChild
        ;; $avArr[$avArr[0][0]+1][1] = _WinAPI_GetWindowText($hChild)
        $avArr[$avArr[0][0] + 1][1] = ControlGetText($eep, "", $hChild)
        ControlSetText($eep, "", $hChild, "child" & $avArr[0][0])
        ;; _WinAPI_GetWindowText($hChild)

        $avArr[0][0] += 1
        WinListChildren($hChild, $avArr)
        $hChild = _WinAPI_GetWindow($hChild, $GW_HWNDNEXT)
    WEnd

    ReDim $avArr[$avArr[0][0] + 1][2]
EndFunc   ;==>WinListChildren

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
            $res = Optimize2($StartGleis, $EndGleis, $Verbindung, $trackrad)
        Case 5
            $res = GenerateGKG($StartGleis, $EndGleis, $Verbindung, $trackrad)
    EndSwitch

    If $res > 0 Then
        If $samft > 0 Then
            $res = DllCall($GleisDLL, "int", "gOptHeight", "double", $track_trans, "double", $track_short)
        Else
            $res = DllCall($GleisDLL, "int", "gLinHeight");
        EndIf
        If @error <> 0 Then
            FatalError("Fehler in gleis.dll: " & @error);
        EndIf

        $istgleisanz = $res[0]
        If $istgleisanz > $MaxGleise Then
            Return -1
        EndIf

        For $i = 0 To $istgleisanz - 1
            GetTrack($Verbindung, $i)
        Next
        ;;_ArrayDisplay($verbindung)
        Return 1

    EndIf

    Return $res
EndFunc   ;==>Optimize

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
    Local $midx = BinarySearch2($sect, $key)
    If $midx < 0 Then
        FatalError("Fehlender Text : " & $key)
    Else
        Return $sect[$midx][1]
    EndIf
EndFunc   ;==>Msg2

Func Msg(Const ByRef $skv, $section, $key)
    Local $sidx = BinarySearch2($skv, $section)
    If $sidx < 0 Then
        FatalError("Fehlender Text in " & $skv & ": " & $section & "/" & $key)
    Else
        Return Msg2($skv[$sidx][1], $key)
    EndIf
EndFunc   ;==>Msg

Func MsgH($section, $key)
    Return Msg($hugo_lang, $section, $key)
EndFunc   ;==>MsgH

Func MsgE($section, $key)
    Return Msg($eep_lang, $section, $key)
EndFunc   ;==>MsgE


;; Initialisierungen
;; Werte die aus der aktuellen Konfiguration zu bestimmen sind:
;; - Nutzereinstellungen
;; - eep-Installation
;; - Sprachdateien

Func LoadOptions()

    $EEPVersion = Int(IniRead($inifile, "gui", "EEPVersion", 0))

    Global $WinWaitDelay = Int(IniRead($inifile, "gui", "WinWaitDelay", -1))

    Global $top = Int(IniRead($inifile, "gui", "top", -1))
    Global $left = Int(IniRead($inifile, "gui", "left", -1))

    Global $eeptop = Int(IniRead($inifile, "eep", "top", -1))
    Global $eepleft = Int(IniRead($inifile, "eep", "left", -1))
    Global $eepwidth = Int(IniRead($inifile, "eep", "width", -1))
    Global $eepheight = Int(IniRead($inifile, "eep", "height", -1))

    Global $eeppos[4] = [$eeptop, $eepleft, $eepwidth, $eepheight]

    Global $tttop = Int(IniRead($inifile, "timetable", "top", -1))
    Global $ttleft = Int(IniRead($inifile, "timetable", "left", -1))
    Global $ttwidth = Int(IniRead($inifile, "timetable", "width", -1))
    Global $ttheight = Int(IniRead($inifile, "timetable", "height", -1))

    Global $ttpos[4] = [$tttop, $ttleft, $ttwidth, $ttheight]

    Global $tt_file = IniRead($inifile, "timetable", "file", "<undefined>")

    Global $copy = Bool(IniRead($inifile, "track", "copy", False))
    Global $level = Bool(IniRead($inifile, "track", "level", False))
    Global $mode = Int(IniRead($inifile, "track", "mode", 1));

    Global $trackrad = Int(IniRead($inifile, "track", "trackrad", 300))
    #cs
        Global $egallevel = Bool(IniRead($inifile, "track2", "egallevel", False))
    #ce
    Global $auto_val = Bool(IniRead($inifile, "immo", "auto_val", False))
    Global $hrel = Bool(IniRead($inifile, "immo", "hrel", False))

    Global $auto_ok = Int(IniRead($inifile, "options", "auto_ok", 0))

    Global $clockmode = IniRead($inifile, "clock", "mode", "startstop")
    Global $clockdmode = IniRead($inifile, "clock", "dmode", "hms")
    Global $clockmodulo = IniRead($inifile, "clock", "modulo", 0)

    Global $keydefstring = IniRead($inifile, "hotkey", "keydef", "<undefined>")
    ;;MsgBox(0,"keydef",$keydefstring)
    If ($keydefstring == "<undefined>") Then
        ;; hier Vorzugswerte ansetzen
        $keydefstring = "^a:before|^e:after|^p:puttrack|^i:inverse|^m:null|^r:replacetrack|"
        #cs
            $keydefstring &= "^g:getobject|^s:setobject|!k:setcombi|"
        #ce
        $keydefstring &= "^g:getobject|^s:setobject|"
        $keydefstring &= "^f:signal2|^h:signal1|^2:signal3|^t:clock|!h:activatehugo|!e:activateeep"
    Else
        ;; weitere Definitionen anhängen
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef1", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef2", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef3", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef4", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef5", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef6", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef7", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef8", "")
        $keydefstring &= "|" & IniRead($inifile, "hotkey", "keydef9", "")
    EndIf
    ;;MsgBox(0,"keydef",$keydefstring)

    ; Buttons SignalTab

    Global Const $mtext_signal_button1 = IniRead($inifile, "SignTab", "Button1", "Fahrt");
    Global Const $mtext_signal_button2 = IniRead($inifile, "SignTab", "Button2", "Halt / Abzweig");
    Global Const $mtext_signal_button3 = IniRead($inifile, "SignTab", "Button3", "Richtung 2");
    Global Const $mtext_signal_button4 = IniRead($inifile, "SignTab", "Button4", "");

    Global Const $setting_signal_button1 = StringSplit(IniRead($inifile, "SignTab", "Setting1", "sfBesx|wfBEsx"), "|", 2);
    Global Const $setting_signal_button2 = StringSplit(IniRead($inifile, "SignTab", "Setting2", "sfBegx|wfBEgx"), "|", 2);
    Global Const $setting_signal_button3 = StringSplit(IniRead($inifile, "SignTab", "Setting3", "wFbx|sFbx"), "|", 2);
    Global Const $setting_signal_button4 = StringSplit(IniRead($inifile, "SignTab", "Setting4", ""), "|", 2);

EndFunc   ;==>LoadOptions

Func IniSaveGE($section, $key, $val)
    If $val >= 0 Then
        IniWrite($inifile, $section, $key, $val);
    EndIf
EndFunc   ;==>IniSaveGE

Func SaveOptions()

    Dim $pos[4]

    IniWrite($inifile, "gui", "top", $top);
    IniWrite($inifile, "gui", "left", $left);

    IniSaveGE("eep", "top", $eeptop)
    IniSaveGE("eep", "left", $eepleft)
    IniSaveGE("eep", "width", $eepwidth)
    IniSaveGE("eep", "height", $eepheight)

    IniSaveGE("timetable", "top", $tttop)
    IniSaveGE("timetable", "left", $ttleft)
    IniSaveGE("timetable", "width", $ttwidth)
    IniSaveGE("timetable", "height", $ttheight)

    IniWrite($inifile, "timetable", "file", $tt_file)

    IniSaveGE("gui", "WinWaitDelay", $WinWaitDelay);

    IniWrite($inifile, "track", "level", $level);
    IniWrite($inifile, "track", "copy", $copy);
    IniWrite($inifile, "track", "mode", $mode);
    IniWrite($inifile, "track", "trackrad", $trackrad);
    #cs
        IniWrite($inifile, "track2", "egallevel", $egallevel);
    #ce
    IniWrite($inifile, "immo", "auto_val", $auto_val);
    IniWrite($inifile, "immo", "hrel", $hrel);

    IniWrite($inifile, "options", "auto_ok", $auto_ok)

    IniWrite($inifile, "clock", "mode", $clockmode)
    IniWrite($inifile, "clock", "dmode", $clockdmode)
    IniWrite($inifile, "clock", "modulo", $clockmodulo)

    Local $actionstring = _ArrayToString($actionlist, ",");
    IniWrite($inifile, "hotkey", "possible_actions", $actionstring);
    IniWrite($inifile, "hotkey", "last_used", $keydefstring);

    IniWrite($inifile, "SignTab", "Button1", $mtext_signal_button1);
    IniWrite($inifile, "SignTab", "Button2", $mtext_signal_button2);
    IniWrite($inifile, "SignTab", "Button3", $mtext_signal_button3);
    IniWrite($inifile, "SignTab", "Button4", $mtext_signal_button4);

    Local $bs = _ArrayToString($setting_signal_button1, "|");
    IniWrite($inifile, "SignTab", "Setting1", $bs);
    Local $bs = _ArrayToString($setting_signal_button2, "|");
    IniWrite($inifile, "SignTab", "Setting2", $bs);
    Local $bs = _ArrayToString($setting_signal_button3, "|");
    IniWrite($inifile, "SignTab", "Setting3", $bs);
    Local $bs = _ArrayToString($setting_signal_button4, "|");
    IniWrite($inifile, "SignTab", "Setting4", $bs);
EndFunc   ;==>SaveOptions

Func ReadLang($section, $key)
    Local $val = IniRead($langfile, $section, $key, "<undefined>")
    If $val = "<undefined>" Then
        FatalError($PName & ".lng: " & $key & " in section " & $section & " undefined")
        Return ""
    EndIf
    Return $val;
EndFunc   ;==>ReadLang

Func ReadEEP($section, $key)
    Local $val = IniRead($eep_langfile, $section, $key, "<undefined>")
    If $val = "<undefined>" Then
        FatalError($eep_langfile & ": " & $key & " in section " & $section & " undefined")
        Return ""
    EndIf
    Return $val;
EndFunc   ;==>ReadEEP

;; Meldungen und andere Texte einlesen
;; das ist eine neue Variante, die keine Einzelvariablen sondern ein Array verwendet
ReadLanguageFile($hugo_lang, $langfile)

;; Global messages
;; have default here to allow exit with message
Global Const $msg_error = IniRead($langfile, "Base", "Error", "Fehler");
Global Const $msg_warning = IniRead($langfile, "Base", "Warning", "Warnung");
Global Const $msg_tip = IniRead($langfile, "Base", "Tip", "Tipp");

;; Mode-Liste Tracktool

Global Const $ModeList[5] = [MsgH("TrackTab", "Optimization1"), MsgH("TrackTab", "Optimization2"), MsgH("TrackTab", "Construction_line_circle"), MsgH("TrackTab", "Construction_circle_line_circle"), MsgH("TrackTab", "Construction_line_circle_line")]

;Global Const $mtext_speedlog = ReadLang("Options", "SpeedLog")
;;

;; eventuelle Nutzereinstellung laden
LoadOptions()

Local $vorhanden = 0

;; test auf eep6
Local Const $eepsection6 = "HKEY_CLASSES_ROOT\Software\Software Untergrund\EEXP"
Local $eepdir6 = RegRead($eepsection6, "Directory");
If @error Then
    $eepdir6 = ""
Else
    $vorhanden = $vorhanden + 1
EndIf

;; test auf eep7

Local Const $eepsection7 = "HKEY_LOCAL_MACHINE\SOFTWARE\Trend\EEP 7.00\EEXP"
Local $eepdir7 = RegRead($eepsection7, "Directory");
If @error Then
    $eepdir7 = ""
Else
    $vorhanden = $vorhanden + 2
EndIf

;; test auf eep8
Local Const $eepsection8 = "HKEY_LOCAL_MACHINE\SOFTWARE\Trend\EEP 8.00\EEXP"
Local $eepdir8 = RegRead($eepsection8, "Directory");
If @error Then
    $eepdir8 = ""
Else
    $vorhanden = $vorhanden + 4
EndIf

;; test auf eepX
Local Const $eepsection10 = "HKEY_LOCAL_MACHINE64\SOFTWARE\Trend\EEP 10.00\EEXP"
Local $eepdir10 = RegRead($eepsection10, "Directory");
If @error Then
    $eepdir10 = ""
Else
    $vorhanden = $vorhanden + 8
EndIf

Switch $vorhanden
    Case 0
        MsgBox(0, $msg_error, MsgH("EEP", "EEP_NOT_FOUND"))
        Exit 1
    Case 1
        ;; only eep < 7 exists
        If $EEPVersion > 6 Then
            MsgBox(0, $msg_error, MsgH("EEP", "EEP6_NOT_FOUND"))
            Exit 1
        EndIf
        $EEPVersion = 6
    Case 2
        ;; only eep 7 exists
        If $EEPVersion <> 7 And $EEPVersion > 0 Then
            MsgBox(0, $msg_error, MsgH("EEP", "EEP7_NOT_FOUND"))
            Exit 1
        EndIf
        $EEPVersion = 7
    Case 4
        ;; only eep 8 exists
        If $EEPVersion <> 8 And $EEPVersion > 0 Then
            MsgBox(0, $msg_error, MsgH("EEP", "EEP8_NOT_FOUND"))
            Exit 1
        EndIf
        $EEPVersion = 8
    Case 8
        ;; only eep X
        If $EEPVersion <> 10 And $EEPVersion > 0 Then
            MsgBox(0, $msg_error, MsgH("EEP", "EEPX_NOT_FOUND"))
            Exit 1
        EndIf
        $EEPVersion = 10

    Case 3, 5, 6, 7
        ;; more versions exist
        If $EEPVersion = 0 Then ;; no user selection
            MsgBox(0, $msg_error, MsgH("EEP", "MANY_EEPS_FOUND"))
            Exit 1
        EndIf
EndSwitch

Switch Number($EEPVersion)
    Case 1 To 6
        $eepsection = $eepsection6
        $eepdir = $eepdir6
    Case 7
        $eepsection = $eepsection7
        $eepdir = $eepdir7
    Case 8
        $eepsection = $eepsection8
        $eepdir = $eepdir8
    Case 10
        $eepsection = $eepsection10
        $eepdir = $eepdir10
EndSwitch

;; ---- Data for EEP ----

$eep_langfile = $eepdir & "\" & "eep.lng"

ReadLanguageFile($eep_lang, $eep_langfile)

;; Texte zur Identifizierung von Fenstern

Global $main_title = ReadEEP("DLG_STANDARD_MESSAGE", "IDR_MAINFRAME");
;; eep 10 :  IDR_MAINFRAME ="EEP %s- Eisenbahn.exe"

;MsgBox(0,"Title",$main_title)
If StringInStr($main_title, "%s") Then
    Local $MainTitleParts = StringSplit($main_title, "%s", 1)
    $main_title = "[REGEXPTITLE:" & $MainTitleParts[1] & ".*" & $MainTitleParts[2] & "]"
EndIf
;MsgBox(0,"Title",$main_title)
;; IDR_MAINFRAME				="EEP %s- Eisenbahn.exe"

Global Const $time_statusbar = ReadEEP("DLG_STANDARD_MESSAGE", "ID_TIME_STATUSBAR");

Local $timestring = StringFormat($time_statusbar, 11, 22, 33);
Global Const $time_index_hour = StringInStr($timestring, "11", 1, 1);
Global Const $time_index_minute = StringInStr($timestring, "22", 1, 1);
Global Const $time_index_second = StringInStr($timestring, "33", 1, 1);

Global Const $immo_prop_text1 = ReadEEP("DLG_OBJECT_PROPERTIES", "IDC_STATIC_ROTZ");
Global Const $immo_prop_text2 = ReadEEP("DLG_OBJECT_PROPERTIES", "IDC_STATIC");

Global Const $track_prop_text1 = ReadEEP("DLG_TRACK_PROPERTIES", "IDC_STATIC_FRAME1");
Global Const $track_prop_text2 = ReadEEP("DLG_TRACK_PROPERTIES", "IDC_STATIC_RAISE");

Global Const $ok_window_text1 = ReadEEP("DLG_STANDARD_MESSAGE", "IDS_REPORT_SAVED");
Global $ok_window_text2 = ReadEEP("DLG_STANDARD_MESSAGE", "IDS_BESTEHENDE_ANLAGE_SPEICHERN");

;; MsgBox(1,"windowtext2",$ok_window_text2 & " => " & C2RegExp($ok_window_text2));

;; Dieser text enthält substitionen (%s)
;; zur Zeit: Nur längsten der festen Textteile nutzen
;; in feste Textteile zerlegen

Dim $harray = StringSplit($ok_window_text2, "%s", 1)

;; längsten text-Teil suchen

$ok_window_text2 = "";
For $i = 1 To $harray[0]
    If (StringLen($harray[$i]) > StringLen($ok_window_text2)) Then
        $ok_window_text2 = $harray[$i];
    EndIf
Next

Global Const $status_ready = ReadEEP("DLG_STANDARD_MESSAGE", "AFX_IDS_IDLEMESSAGE")

Global $rasterwarning;
Global $description;

If $EEPVersion > 6 Then
    $rasterwarning = StringLeft(ReadEEP("OTHER", "ANLERR1"), 30);; Trick: nur 30 Zeichen, um [e] für Enter zu umgehen.
    $description = ReadEEP("DLG_DESCRIPTION", "Caption");
EndIf

;MsgBox(1,"description",$description);
;MsgBox(1,"rasterwarning",$rasterwarning);
;MsgBox(1,"status_ready",$status_ready);

;; Text in speedcontrol
;; werden für Control-Suche gleich in reguläre Ausdrücke umgewandelt
Global Const $actualspeed = C2RegExp(ReadEEP("DLG_CONTROL_AUTOMATIC", "IDC_STAT_ISTVELOC"))
Global Const $targetspeed = C2RegExp(ReadEEP("DLG_CONTROL_AUTOMATIC", "IDC_STAT_SOLLVELOC"))
;; MsgBox(0,"speed",$actualspeed & " " & $targetspeed)

;; Texte der Editorliste(ComboBox)

Global Const $editor_signal = ReadEEP("TOOLBAR", "COMBOBOX_A_0");
Global Const $editor_surface = ReadEEP("TOOLBAR", "COMBOBOX_A_1");
Global Const $editor_landscape = ReadEEP("TOOLBAR", "COMBOBOX_A_2");
Global Const $editor_immo = ReadEEP("TOOLBAR", "COMBOBOX_A_3");
Global Const $editor_goods = ReadEEP("TOOLBAR", "COMBOBOX_A_4");
Global Const $editor_traffic = ReadEEP("TOOLBAR", "COMBOBOX_A_5");
Global Const $editor_track = ReadEEP("TOOLBAR", "COMBOBOX_A_6");
Global Const $editor_road = ReadEEP("TOOLBAR", "COMBOBOX_A_7");
Global Const $editor_tram = ReadEEP("TOOLBAR", "COMBOBOX_A_8");
Global Const $editor_water = ReadEEP("TOOLBAR", "COMBOBOX_A_9");

Global Const $TrackEditorList[4] = [$editor_track, $editor_road, $editor_tram, $editor_water];

Global Const $controls = 16
Global $Button[4][$controls] ; 4 editors * (12 "buttons" + 4 "edits")

For $i = 0 To 3
    For $k = 0 To $controls - 1
        $Button[$i][$k] = 0
    Next
Next

Global $Button_Immo_del = 0
Global $Button_LE_del = 0

Global Const $caption_contact_signal = ReadEEP("DLG_CONTACT_POINT_SIGNAL", "CAPTION");
Global Const $caption_contact_switch = ReadEEP("DLG_CONTACT_POINT_SWITCH", "CAPTION");

;; Vorbereitungen Gleis
ErgaenzeGleis($StartGleis)
ErgaenzeGleis($EndGleis)

Global Const $caption_control = ReadEEP("DLG_CTRL", "CAPTION")

If $tt_file <> "<undefined>" Then
    ReadPlan($tt_file, $tt_plan)
EndIf

Func GetEditor()
    ;; global $editorlist, $eep
    Local $sel = -1; not found yet
    If $EEPVersion < 10 Then
        If (ControlCommand($eep, "", $editorlist, "IsEnabled", "") > 0) Then
            Local $stat = ControlCommand($eep, "", $editorlist, "GetCurrentSelection")
            $sel = ControlCommand($eep, "", $editorlist, "FindString", $stat);
        EndIf
        ;;MsgBox(0,"Editor",$sel,1)
    Else
        ;; for v10 no solution for objecteditors yet
        Local $selectstring;
        If ControlCommand($eep, "", $Button[0][$bid_switch], "isVisible") Then
            $sel = 6
            $selectstring = $selectstring & "6"
        ElseIf ControlCommand($eep, "", $Button[1][$bid_switch], "isVisible") Then
            $sel = 8
            $selectstring = $selectstring & "8"
        ElseIf ControlCommand($eep, "", $Button[2][$bid_switch], "isVisible") Then
            $sel = 7
            $selectstring = $selectstring & "7"
        ElseIf ControlCommand($eep, "", $Button[3][$bid_switch], "isVisible") Then
            $sel = 9
            $selectstring = $selectstring & "9"
        ElseIf ControlCommand($eep, "", $Button_Immo_del, "isVisible") Then
            $sel = 3
            $selectstring = $selectstring & "3"
        ElseIf ControlCommand($eep, "", $Button_LE_del, "isVisible") Then
            $sel = 2
            $selectstring = $selectstring & "2"
        EndIf
    EndIf
    Return $sel;
EndFunc   ;==>GetEditor

Func SetEditorVars($edit)
    ;; MsgBox(0, "Editoren", "Alt:" & $OldEditor & "  neu:" & $editor)
    Global $trackeditoridx = -1;
    Global $objeditoridx = -1;
    Global $editor = $edit
    Switch $edit
        Case 2
            ;; landschaft
            $objeditoridx = 0
        Case 3
            ;; immobilien
            $objeditoridx = 1
            ;;case 4     ;; Noch nicht nutzbar
            ;; güter
            ;; $objeditoridx=2
        Case 6
            ;; Bahn
            $trackeditoridx = $eid_track;
        Case 7
            ;; Strasse
            $trackeditoridx = $eid_road;
        Case 8
            ;; Strassenbahn
            $trackeditoridx = $eid_tram;
        Case 9
            ;; Wasser/Luft
            $trackeditoridx = $eid_water;
    EndSwitch
EndFunc   ;==>SetEditorVars

Func SetEditor($edit)
    Local $sel = ControlGetHandle($eep, "", $editorlist)
    ControlClick($eep, "", $sel);
    ControlCommand($eep, "", $sel, "SetCurrentSelection", $edit)
    SetEditorVars($edit)
EndFunc   ;==>SetEditor

Func SetEffekt($h, $edit)
    Local $sel = ControlGetHandle($h, "", 1465)
    ;; ControlClick($h,"",$sel);
    ControlCommand($h, "", $sel, "SetCurrentSelection", $edit)
EndFunc   ;==>SetEffekt

Func IsVisible($handle)
    ;; is window visible
    If BitAND(WinGetState($handle), 2) Then
        Return 1
    Else
        Return 0
    EndIf
EndFunc   ;==>IsVisible

Func Click($btn)
    Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client
    WinActivate($eep)
    If $EEPVersion < 10 Then
        Select
            Case $btn == 0
                MouseClick("left", 500, 500, 1, 1)
            Case $btn == 1
                MouseClick("right", 500, 500, 1, 1)
            Case $btn == 2
                MouseClick("left", 500, 500, 1, 1)
                MouseClick("right", 500, 500, 1, 1)
        EndSelect
    Else
        Select
            Case $btn == 0
                MouseClick("left")
            Case $btn == 1
                MouseClick("right")
            Case $btn == 2
                MouseClick("left")
                MouseClick("right")
        EndSelect
    EndIf
EndFunc   ;==>Click

Func RightClick()
    Click(1)
EndFunc   ;==>RightClick

Func FindProp1($text1, $text2)
    ;; Search track property window
    ;; global $eep
    Local $hw = 0
    Local $var = WinList()
    For $i = 1 To $var[0][0]
        ;;		If $var[$i][0] <> "" AND IsVisible($var[$i][1]) Then
        If $var[$i][0] <> "" And BitAND(WinGetState($var[$i][1]), 2) Then
            Local $title = $var[$i][0]
            Local $handle = $var[$i][1];
            Local $title3 = StringLower(StringLeft($title, 3))
            ;; Das EEP-Fenster darf nicht weiter abgefragt werden, da es dadurch zerstört wird
            If $title3 <> "eep" Then
                ;; If $handle <> $eep Then
                Local $text = WinGetText($handle);
                If StringInStr($text, $text1) And StringInStr($text, $text2) Then
                    $hw = $var[$i][1];  found!
                    ExitLoop
                EndIf
            EndIf
        EndIf
    Next
    Return $hw
EndFunc   ;==>FindProp1

Func FindProp($text1, $text2)
    ;; MsgBox(1,"FindProp",$text1 & "  " & $text2)
    ;; property window open ??
    Local $rc = FindProp1($text1, $text2)
    If ($rc == 0) Then
        ;; retry with rightclick
        RightClick()
        Local $i = 0;
        While ($rc == 0 And $i < 40)
            Sleep(100)
            $rc = FindProp1($text1, $text2)
            $i = $i + 1;
        WEnd
    EndIf
    Return $rc
EndFunc   ;==>FindProp

Func FindEdit()
    Return FindProp($track_prop_text1, $track_prop_text2);
EndFunc   ;==>FindEdit

Func FindImmo()
    Return FindProp($immo_prop_text1, $immo_prop_text2);
EndFunc   ;==>FindImmo

Func AutoOK()
    If BitTest($auto_ok, 1) Then
        ;;MsgBox(0,"auto1",$auto_ok);
        ;;		if WinActive("eep",$ok_window_text1) OR WinActive("EEP",$ok_window_text1) OR WinActive("eep",$ok_window_text2) OR WinActive("EEP",$ok_window_text2) Then
        If WinActive("eep", $ok_window_text1) Or WinActive("eep", $ok_window_text2) Then
            ;;		If WinExists("eep", $ok_window_text1) Or WinExists("eep", $ok_window_text2) Then
            ;;MsgBox(0,"auto1","Enter");
            Send("{ENTER}");
        EndIf
    EndIf
    If $EEPVersion > 6 Then
        If BitTest($auto_ok, 2) Then
            ;;MsgBox(0,"auto2",$auto_ok);
            If WinActive($description) Then
                ;;MsgBox(0,"auto2","Enter");
                Send("{ENTER}");
            EndIf
            If WinActive("eep", $rasterwarning) Then
                ;;MsgBox(0,"auto2b","Enter");
                Send("{ENTER}");
            EndIf
        EndIf
    EndIf
EndFunc   ;==>AutoOK

Func GetSpeed2(ByRef $valid, ByRef $soll, ByRef $ist, $sel)
    $valid = 0
    ;; Local $speedstring=ControlGetText($eep,"","[CLASS:Static;INSTANCE:57]");
    ;; Local $speedstring=ControlGetText($eep,"","[CLASS:Static;INSTANCE:51]");
    ;;	Local $speedstring = ControlGetText($eep, "", $actualspeedcontrol);
    Local $speedstring

    If $sel > 0 Then
        $speedstring = ControlGetText($eep, "", 1283);
        ;;MsgBox(1,"speed","EEP " & $speedstring,1)
    Else
        $speedstring = ControlGetText($caption_control, "", 1283);
        ;;MsgBox(1,"speed","Steuer " & $speedstring,1)
    EndIf
    Local $aspeed = StringRegExp($speedstring, '\(([-0-9]*).*\)', 1)
    If @error == 0 Then
        $ist = Abs(Number($aspeed[0]))
        ;;$speedstring=ControlGetText($eep,"","[CLASS:Static;INSTANCE:58]");
        ;;$speedstring=ControlGetText($eep,"","[CLASS:Static;INSTANCE:52]");
        ;;$speedstring = ControlGetText($eep, "", $targetspeedcontrol);
        If $sel > 0 Then
            $speedstring = ControlGetText($eep, "", 1284);
        Else
            $speedstring = ControlGetText($caption_control, "", 1284);
        EndIf
        ;; msgbox(1,"speedstring",$speedstring);
        $aspeed = StringRegExp($speedstring, '\(([-0-9]*).*\)', 1)
        If @error == 0 Then
            $soll = Abs(Number($aspeed[0]))
            $valid = 1
        EndIf
    EndIf
EndFunc   ;==>GetSpeed2

Func GetSpeed(ByRef $valid, ByRef $soll, ByRef $ist)
    GetSpeed2($valid, $soll, $ist, 0)
    If $valid = 0 Then
        GetSpeed2($valid, $soll, $ist, 1)
    EndIf
EndFunc   ;==>GetSpeed



; Functions to communicate with eep

;; Read and write to controls
Func SetText($h, $id, $val)
    ;; wer hat den Focus ?
    ;;Local $ah = ControlGetFocus($h)
    ;; on some fields ControlSetText needs focus (!?)
    ControlFocus($h, "", $id)
    ControlSetText($h, "", $id, $val)
    ;; Focus zurückgeben
    ;;ControlFocus($h,"",$ah)
EndFunc   ;==>SetText

Func GetNumber($handle, $id)
    ;; Get data from window as number
    Return Number(ControlGetText($handle, "", $id))
EndFunc   ;==>GetNumber

;; get track data from eep
Func GetTrackData(ByRef $gleis, $delete = False)
    WinActivate($eep)
    Local $handle = FindEdit()
    If $handle == 0 Then
        Error(MsgH("EEP", "NO_WINDOW"));
        Return False;
    Else
        WinActivate($handle);
        ControlCommand($handle, "", $id_parmode, "SetCurrentSelection", 0)
        $gleis[$iangle] = GetNumber($handle, $id_angle)
        $gleis[$ilen] = GetNumber($handle, $id_len)
        $gleis[$ix] = GetNumber($handle, $id_x)
        $gleis[$iy] = GetNumber($handle, $id_y)
        $gleis[$ih1] = GetNumber($handle, $id_h1)
        $gleis[$idir] = GetNumber($handle, $id_dir)
        Local $steigung = GetNumber($handle, $id_steigung)
        $gleis[$igrad] = $steigung / $gleis[$ilen]

        ErgaenzeGleis($gleis)

        Send("!A");
            Sleep(100)
        If $delete Then
            WinActivate($eep);
            Sleep(100)
            Send("!E")
            Sleep(100)
            Send("L");
            Sleep(100)
        EndIf

        Return True;
    EndIf

EndFunc   ;==>GetTrackData

Func GetImmoData(ByRef $immo, $delete = False)
    WinActivate($eep)
    Local $handle = FindImmo()
    If $handle == 0 Then
        Error(MsgH("EEP", "NO_WINDOW"))
        Return False;
    Else
        WinActivate($handle);
        $immo[0] = WinGetTitle($handle);
        $immo[$iix] = GetNumber($handle, $iid_x)
        $immo[$iiy] = GetNumber($handle, $iid_y)
        $immo[$iiz] = GetNumber($handle, $iid_z)
        $immo[$iizr] = GetNumber($handle, $iid_zr)
        $immo[$iifx] = GetNumber($handle, $iid_fx)
        $immo[$iify] = GetNumber($handle, $iid_fy)
        $immo[$iifz] = GetNumber($handle, $iid_fz)
        $immo[$iisc] = GetNumber($handle, $iid_sc)

        Send("{ESCAPE}");

        If $delete Then
            WinActivate($eep);
            Sleep(100)
            Send("!E")
            Send("L");
        EndIf

        Return True;
    EndIf

EndFunc   ;==>GetImmoData

Func SetImmoData(ByRef $immo, $rel = True)

    WinActivate($eep)

    Local $handle = FindImmo()
    If $handle == 0 Then
        Error(MsgH("EEP", "NO_WINDOW"));
        Return False;
    Else
        WinActivate($handle);
        $immo[0] = WinGetTitle($handle);
        SetText($handle, $iid_x, $immo[$iix])
        SetText($handle, $iid_y, $immo[$iiy])

        If ($rel == False) Then
            SetText($handle, $iid_z, $immo[$iiz])
        Else
            SetText($handle, $iid_zr, $immo[$iizr])
        EndIf

        SetText($handle, $iid_fx, $immo[$iifx])
        SetText($handle, $iid_fy, $immo[$iify])
        SetText($handle, $iid_fz, $immo[$iifz])
        SetText($handle, $iid_sc, $immo[$iisc])

        ;; abhängige Werte zurücklesen
        If ($rel == False) Then
            $immo[$iizr] = GetNumber($handle, $iid_zr)
        Else
            $immo[$iiz] = GetNumber($handle, $iid_z)
        EndIf

        Send("{ENTER}");

        Return True;
    EndIf

EndFunc   ;==>SetImmoData

Func SetTrack(ByRef $gleis)

    Local $handle = FindEdit() ;; Eigenschaftsfenster öffnen

    If $handle <> 0 Then
        ;; Modus Länge + Winkel einstellen
        ControlCommand($handle, "", 1289, "SetCurrentSelection", 0)

        While ($gleis[$idir] > 360)
            $gleis[$idir] -= 360;
        WEnd
        While ($gleis[$idir] < -360)
            $gleis[$idir] += 360;
        WEnd

        SetText($handle, $id_x, $gleis[$ix])
        SetText($handle, $id_y, $gleis[$iy])
        SetText($handle, $id_dir, $gleis[$idir])
        SetText($handle, $id_h1, $gleis[$ih1])
        SetText($handle, $id_len, $gleis[$ilen]);
        Local $steigung = $gleis[$igrad] * $gleis[$ilen];
        SetText($handle, $id_steigung, $steigung)
        Local $angle = $gleis[$iangle]
        If Abs($angle) < 0.001 Then
            $angle = 0
        EndIf
        SetText($handle, $id_angle, $angle);
        ;;MsgBox(1,"DEBUG","hier")
        Send("!O") ;; OK
        Return True;
    Else
        Error(MsgH("EEP", "NO_WINDOW"));
        Return False;
    EndIf
EndFunc   ;==>SetTrack

Func PutTrack(ByRef $gleis, $typ)
    ;;	WinActivate($eep)  ;; EEP aktiviert

    If $Button[$trackeditoridx][$bid_track] = 0 Then
        Error(MsgH("EEP", "NO_TRACK_BUTTON"))
        Return False;
    EndIf
    If $typ == 1 Then
        ControlClick($eep, "", $Button[$trackeditoridx][$bid_track]) ;; Gleis
    ElseIf $typ == 2 Then
        ControlClick($eep, "", $Button[$trackeditoridx][$bid_switch]) ;; Weiche
    ElseIf $typ == 3 Then
        ControlClick($eep, "", $Button[$trackeditoridx][$bid_switch3]) ;; Weiche3
    ElseIf $typ == 0 Then
        ControlClick($eep, "", $Button[$trackeditoridx][$bid_end]) ;; Prellbock
    Else
        FatalError("Systemfehler: Falscher Gleistyp");
    EndIf
    Click(2) ;; Links-Click = Gleis ablegen, Rechts-Click = Eigenschaftsfenster

    Return SetTrack($gleis)
EndFunc   ;==>PutTrack

Global $gx1, $gx2, $gy1, $gy2, $dd
Global $ff, $ox, $oy

Func ToScreen($xi, $yi, ByRef $xo, ByRef $yo)
    ; $xo = ($xi - $gx1) * $xsize / $dd
    ; $yo = $ysize - ($yi - $gy1) * $ysize /$dd
    $xo = $xi * $ff + $ox
    $yo = -$yi * $ff + $oy
EndFunc   ;==>ToScreen
; =========================================
Func UpdateLimits($x, ByRef $x1, ByRef $x2)
    If $x > $x2 Then
        $x2 = $x
    EndIf
    If $x < $x1 Then
        $x1 = $x
    EndIf
EndFunc   ;==>UpdateLimits
; =========================================
Func MaxCoor(Const ByRef $gleis, $anz)
    For $i = 0 To $anz - 1
        UpdateLimits($gleis[$i][$ix], $gx1, $gx2)
        UpdateLimits($gleis[$i][$iy], $gy1, $gy2)
    Next
EndFunc   ;==>MaxCoor
; =========================================
Func Draw1Gleis(ByRef $graf, Const ByRef $gleis)
    Local $x, $y
    ;;	MsgBox(0,"Gleis","Von " & $gleis[$ix] & " " & $Gleis[$iy] & " naxm " & $gleis[$ixe] & " " & $Gleis[$iye] );
    ToScreen($gleis[$ix], $gleis[$iy], $x, $y)
    GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $x, $y)
    ;; _ArrayDisplay($gleis)
    If $gleis[$irad] <> 0 Then
        Local $rad = $gleis[$irad];
        ;; MsgBox(0,"schleife",$gleis[$ifi1] & " .. " & $gleis[$ifi2] & "  " & $gleis[$iangle] & "/" & $gleis[$ilen] );
        Local $step = 10 ;; steps of 10 M
        If $step * 5 < $gleis[$ilen] Then
            $step = $gleis[$ilen] / 5
        EndIf

        $step = $gleis[$iangle] / $gleis[$ilen] * $step ;; steps of 10 meters
        If $step == 0.0 Then ;; avoid endless loops
            $step = 1
        EndIf

        For $i = $gleis[$ifi1] To $gleis[$ifi2] Step $step
            ;;		for $i=0 to 360 step 1
            Local $xg = $gleis[$ixm] + $rad * CosD($i)
            Local $yg = $gleis[$iym] + $rad * SinD($i)
            ToScreen($xg, $yg, $x, $y)
            GUICtrlSetGraphic($graf, $GUI_GR_LINE, $x, $y)
        Next
    EndIf
    ToScreen($gleis[$ixe], $gleis[$iye], $x, $y)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $x, $y)
EndFunc   ;==>Draw1Gleis

Func DrawGleis(ByRef $graf, Const ByRef $davor, Const ByRef $gleis, $anz, Const ByRef $danach)
    Local $x, $y

    $gx1 = $danach[$ix]
    $gy1 = $danach[$iy]
    $gx2 = $gx1
    $gy2 = $gy1

    MaxCoor($gleis, $anz)
    UpdateLimits($davor[$ix], $gx1, $gx2)
    UpdateLimits($davor[$iy], $gy1, $gy2)
    UpdateLimits($danach[$ixe], $gx1, $gx2)
    UpdateLimits($danach[$iye], $gy1, $gy2)

    Local $fx = $xsize * 0.8 / ($gx2 - $gx1)
    Local $fy = $ysize * 0.8 / ($gy2 - $gy1)
    If ($fx > $fy) Then
        $ff = $fy
    Else
        $ff = $fx
    EndIf

    $ox = 0.5 * $xsize - $ff * 0.5 * ($gx1 + $gx2)
    $oy = 0.5 * $ysize + $ff * 0.5 * ($gy1 + $gy2)

    NGResetGraph($graf)

    ;GUICtrlSetGraphic($graf,$GUI_GR_HINT, 1)

    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $color[0])
    Draw1Gleis($graf, $davor)

    Local $cnr = 1

    For $i = 0 To $anz - 1
        GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $color[$cnr])
        Dim $hgleis[$TrackDataLen]
        For $h = 0 To $TrackDataLen - 1
            $hgleis[$h] = $gleis[$i][$h]
        Next

        If $cnr == 1 Then
            $cnr = 2
        Else
            $cnr = 1
        EndIf

        Draw1Gleis($graf, $hgleis)
    Next

    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $color[0])
    Draw1Gleis($graf, $danach)

    GUICtrlSetGraphic($graf, $GUI_GR_REFRESH);
EndFunc   ;==>DrawGleis

Func Pfeil(ByRef $graf, $xs, $ys, $ll, $fi)
    Local $co = CosD($fi)
    Local $si = SinD($fi)

    Local $l1 = $ll * 0.15
    Local $l2 = $ll * 0.8

    GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $xs - $ll * $co, $ys + $ll * $si)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $ll * $co, $ys - $ll * $si)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $l2 * $co - $l1 * $si, $ys - $l2 * $si - $l1 * $co)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $ll * $co, $ys - $ll * $si)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $l2 * $co + $l1 * $si, $ys - $l2 * $si + $l1 * $co)

EndFunc   ;==>Pfeil

Func Pfeil2(ByRef $graf, $xs, $ys, $ll, $fi, $color)
    Local $co = CosD($fi)
    Local $si = SinD($fi)

    Local $l1 = $ll * 0.15
    Local $l2 = $ll * 0.8

    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $color)

    ;;	GUICtrlSetGraphic($graf,$GUI_GR_MOVE,$xs,$ys)
    GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $xs + $l2 * $co, $ys - $l2 * $si)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $ll * $co, $ys - $ll * $si)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $l2 * $co - $l1 * $si, $ys - $l2 * $si - $l1 * $co)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $ll * $co, $ys - $ll * $si)
    GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xs + $l2 * $co + $l1 * $si, $ys - $l2 * $si + $l1 * $co)

EndFunc   ;==>Pfeil2

Func Rect(ByRef $graf, $xs, $ys, $fi)
    Local $pts[10] = [-1, -1, 1, -1, 1, 1, -1, 1, -1, -1]
    For $i = 0 To 9 Step 2
        Local $x = $pts[$i] * 0.075 * $xsize;
        Local $y = $pts[$i + 1] * 0.075 * $xsize;
        Rotate(-$fi, $x, $y)
        Shift($xs, $ys, $x, $y)
        If $i == 0 Then
            GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $x, $y)
        Else
            GUICtrlSetGraphic($graf, $GUI_GR_LINE, $x, $y)
        EndIf
    Next
EndFunc   ;==>Rect

Func DrawXKW(ByRef $graf, $xs, $ys, $fi, $dirselect)
    Local $pts[60] = [-1, -1, -0.5, -0.5, -1, 0, -0.5, 0, -1, 1, -0.5, 0.5, _
            1, -1, 0.5, -0.5, 1, 0, 0.5, 0, 1, 1, 0.5, 0.5, _
             - 0.5, -0.5, 0.5, -0.5, -0.5, 0.5, 0.5, 0.5, _
             - 0.5, -0.5, 0.5, 0, -0.5, 0.5, 0.5, 0, _
             - 0.5, 0, 0.5, -0.5, -0.5, 0, 0.5, 0.5, _
             - 0.5, -0.5, 0.5, 0.5, -0.5, 0, 0.5, 0, -0.5, 0.5, 0.5, -0.5]
    Local $trackselect[$TrackDataLen]
    If $dirselect == 0 Then
        $dirselect = $csdirselect
        GUICtrlSetGraphic($graf, $GUI_GR_COLOR, 0x008800)
    Else
        GUICtrlSetGraphic($graf, $GUI_GR_COLOR, 0x000088)
    EndIf

    DirToTrack($dirselect, $trackselect)
    ;_ArrayDisplay($trackselect)
    Local $xa
    Local $ya
    Local $tracknr = 0
    For $i = 0 To 56 Step 4
        If $trackselect[$tracknr] > 0 Then
            Local $xa = $pts[$i] * 0.075 * $xsize;
            Local $ya = $pts[$i + 1] * 0.075 * $xsize;
            Local $xe = $pts[$i + 2] * 0.075 * $xsize;
            Local $ye = $pts[$i + 3] * 0.075 * $xsize;
            Rotate(-$fi, $xa, $ya)
            Shift($xs, $ys, $xa, $ya)
            Rotate(-$fi, $xe, $ye)
            Shift($xs, $ys, $xe, $ye)
            GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $xa, $ya)
            GUICtrlSetGraphic($graf, $GUI_GR_LINE, $xe, $ye)
        EndIf
        $tracknr += 1
    Next
EndFunc   ;==>DrawXKW

Func DrawImmo(ByRef $graf, ByRef $immopos)
    Local $fi = $immopos[$iifz]

    NGResetGraph($graf)

    Local $xm = $xsize * 0.5
    Local $ym = $ysize * 0.5
    Local $ll = $xsize * 0.4

    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, 0)

    Pfeil($graf, $xm, $ym, $ll, $fi)
    Pfeil($graf, $xm, $ym, $ll, $fi + 90)

    GUICtrlSetGraphic($graf, $GUI_GR_REFRESH)
EndFunc   ;==>DrawImmo

Func DrawCombi(ByRef $graf)
    NGResetGraph($graf)

    Local $fi = $csdir;

    Local $xm = $xsize * 0.5
    Local $ym = $ysize * 0.5

    Local $ll = $xsize * 0.4

    Local $dx = 0.15 * $xsize * CosD($fi)
    Local $dy = 0.15 * $xsize * SinD($fi)

    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, 0)

    For $j = 0 To 4
        Local $jr = $j - 2
        For $i = 0 To 4
            Local $ir = $i - 2
            If ($csOld[$i][$j] > 0) Or ($j == 2 And $i == 2) Then
                ;; Rect($graf,$xm+$ir*$dx-$jr*$dy,$ym-$jr*$dx-$ir*$dy,$fi)
                DrawXKW($graf, $xm + $ir * $dx - $jr * $dy, $ym - $jr * $dx - $ir * $dy, $fi, $csOld[$i][$j])
            EndIf
        Next
    Next

    Pfeil2($graf, $xm, $ym, $ll, $fi + 90, 0xff0000);
    Pfeil2($graf, $xm, $ym, $ll, $fi, 0xffff00);
    Pfeil2($graf, $xm, $ym, $ll, $fi - 90, 0x00ff00);
    Pfeil2($graf, $xm, $ym, $ll, $fi - 180, 0x0000ff);

    GUICtrlSetGraphic($graf, $GUI_GR_REFRESH);

EndFunc   ;==>DrawCombi

Func DrawSpeed(ByRef $graf, ByRef $speed, ByRef $sspeed, $firstindex)

    Local $xs = $xsize - 10;
    Local $ys = $ysize - 10;

    NGResetGraph($graf)

    Local $smax = 50;; minimale Maximalgeschwindigkeit
    For $i = 0 To $SpeedLogSize - 1
        If $speed[$i] > $smax Then
            $smax = $speed[$i]
        EndIf
        If $sspeed[$i] > $smax Then
            $smax = $sspeed[$i]
        EndIf
    Next

    Local $hx, $hy;

    For $i = 0 To 45
        ;;		Local $col=0x88cc00
        Local $col = 0x88ff88
        If Mod($i, 5) == 0 Then
            ;;			$col=0x44cc00
            $col = 0x44ff44
        EndIf
        If Mod($i, 10) == 0 Then
            ;;			$col=0x008800
            $col = 0x00ff00
        EndIf

        GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $col)

        $hy = -$i * 10 * $ys / ($smax + 1) + $ys + 5
        If $hy >= 5 Then
            If $hy <= $ys Then
                GUICtrlSetGraphic($graf, $GUI_GR_MOVE, 5, $hy)
                GUICtrlSetGraphic($graf, $GUI_GR_LINE, 5 + $xs, $hy)
            EndIf
        EndIf
    Next

    Local $first = True

    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $color[2])
    For $i = 0 To $SpeedLogSize - 1
        Local $ii = Mod($i + $firstindex, $SpeedLogSize);
        If $sspeed[$ii] >= 0 Then
            $hx = $xs * $i / $SpeedLogSize + 5;
            $hy = -$sspeed[$ii] * $ys / ($smax + 1) + $ys + 5 ;
            If $first == True Then
                GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $hx, $hy)
                $first = False
            Else
                GUICtrlSetGraphic($graf, $GUI_GR_LINE, $hx, $hy)
            EndIf
        EndIf
    Next

    $first = True
    GUICtrlSetGraphic($graf, $GUI_GR_COLOR, $color[0])
    For $i = 0 To $SpeedLogSize - 1
        Local $ii = Mod($i + $firstindex, $SpeedLogSize);
        If $speed[$ii] >= 0 Then
            $hx = $xs * $i / $SpeedLogSize + 5;
            $hy = -$speed[$ii] * $ys / ($smax + 1) + $ys + 5 ;
            If $first == True Then
                GUICtrlSetGraphic($graf, $GUI_GR_MOVE, $hx, $hy)
                $first = False
            Else
                GUICtrlSetGraphic($graf, $GUI_GR_LINE, $hx, $hy)
            EndIf
        EndIf
    Next


    GUICtrlSetGraphic($graf, $GUI_GR_REFRESH);

EndFunc   ;==>DrawSpeed

Func SetDisplay($TabSelection)
    Local $OldDisplayStat = $DisplayStat
    Switch ($TabSelection)
        Case $CombiTab
            $DisplayStat = $CombiDisplay
        Case $ImmoTab
            $DisplayStat = $ImmoDisplay
        Case $TrackTab
            $DisplayStat = $TrackDisplay
    EndSwitch
    If $DisplayStat <> $OldDisplayStat Then
        $DisplayNeedsRedraw = 1
    EndIf
EndFunc   ;==>SetDisplay

Func SetTab($TabSelection)
    GUICtrlSetState($TabSelection, $GUI_SHOW);
    SetDisplay($TabSelection)
EndFunc   ;==>SetTab

;; Gui-Funktionen der 2. Generation
;; verwaltet 2 Spalten

Func FatalError($msg)
    MsgBox(48, "error", $msg)
    ;;MsgBox(48,$msg_error,$msg)
    Exit 1
EndFunc   ;==>FatalError

Func Error($msg)
    ;;Global Const $msg_error
    MsgBox(48, $msg_error, $msg, 5)
EndFunc   ;==>Error

Func Warning($msg)
    ;;Global Const $msg_warning
    MsgBox(64, $msg_warning, $msg, 5)
EndFunc   ;==>Warning

;;------------------------------------------------
Func ValidWindowPos($wpos)
    ;;	_ArrayDisplay($wpos)
    ;;	_ArrayDisplay($screensize)
    Local $valid = 0
    If $wpos[0] >= $ScreenSize[0] Then
        If $wpos[1] >= $ScreenSize[1] Then
            If $wpos[0] + $wpos[2] <= $ScreenSize[0] + $ScreenSize[2] Then
                If $wpos[1] + $wpos[3] <= $ScreenSize[1] + $ScreenSize[2] Then
                    $valid = 1
                EndIf
            EndIf
        EndIf
    EndIf
    Return $valid
EndFunc   ;==>ValidWindowPos
;;------------------------------------------------
Global $NG_HEIGHT = 755
Global $NG_WIDTH = 210

Global $NG_BORDER = 5
Global $NG_XL1 = $NG_BORDER ;; linker Rand der linken spalte
Global $NG_XL2 = ($NG_WIDTH - $NG_BORDER) / 2 ;; rechter Rand der linken spalte
Global $NG_XR1 = $NG_XL2 + $NG_BORDER ;; linker Rand der rechten spalte
Global $NG_XR2 = $NG_WIDTH - $NG_BORDER ;; rechter Rand der rechten Spalte
Global $NG_XG1 = $NG_XL1 ;; linker rand des ganzen Fensters
Global $NG_XG2 = $NG_XR2 ;; rechter Rand der ganzen Fensters

Global $NG_TABY = 0;
Global $NG_TABHEIGHT = 370

;; Konstanten zur Auswahl der Spalte
Global Const $NG_LEFT = 1
Global Const $NG_RIGHT = 2
Global Const $NG_BOTH = 3

Global $NG_YLA = 5;
Global $NG_YRA = 5;
;;Global $Labels[1]

;----------- Local helper functions ------------------------
Func NGGetPos($pos, ByRef $x1, ByRef $x2, ByRef $y)
    ;; nächste zu verwendende Position
    Switch ($pos)
        Case $NG_LEFT
            $x1 = $NG_XL1
            $x2 = $NG_XL2
            $y = $NG_YLA;
        Case $NG_RIGHT
            If $NG_XR1 < 0 Then
                Return True
            EndIf

            $x1 = $NG_XR1
            $x2 = $NG_XR2
            $y = $NG_YRA;
        Case $NG_BOTH
            $x1 = $NG_XG1
            $x2 = $NG_XG2
            If $NG_YLA > $NG_YRA Then
                $y = $NG_YLA
            Else
                $y = $NG_YRA
            EndIf
    EndSwitch
    Return False
EndFunc   ;==>NGGetPos

Func NGNextPos($step, $where)
    ;; weiterrücken der Position in y-Richtung
    Switch ($where)
        Case $NG_LEFT
            $NG_YLA = $NG_YLA + $step;
        Case $NG_RIGHT
            $NG_YRA = $NG_YRA + $step;
        Case $NG_BOTH
            Local $y
            If $NG_YLA > $NG_YRA Then
                $y = $NG_YLA
            Else
                $y = $NG_YRA
            EndIf
            $NG_YLA = $y + $step
            $NG_YRA = $y + $step
    EndSwitch
EndFunc   ;==>NGNextPos

#cs
    Global $Acceleratorkey[1]=[0]
    Global $Acceleratorhandle[1]=[0]

    Func NGSetAccelerators()
    ;;_ArrayDisplay($Acceleratorkey)
    if UBound($Acceleratorkey)>1 Then
    Dim $AccelKeys[UBound($Acceleratorkey)-1][2]
    for $i=1 to UBound($Acceleratorkey)-1
    $AccelKeys[$i-1][0]=$Acceleratorkey[$i]
    $AccelKeys[$i-1][1]=$Acceleratorhandle[$i]
    ;;MsgBox(0,"Accel",$acceleratorkey[$i])
    Next
    ;;_ArrayDisplay($AccelKeys)
    GUISetAccelerators($AccelKeys)
    EndIf

    EndFunc
#Ce

Func OnlyTitle($mtext)
    Local $textarray = StringSplit($mtext, "|")
    Return $textarray[1]
EndFunc   ;==>OnlyTitle

Func SplitTitle($mtext, ByRef $title, ByRef $tooltip, ByRef $accel)
    Local $textarray = StringSplit($mtext, "|")
    $title = $textarray[1]
    $tooltip = ""
    If $textarray[0] > 1 Then
        $tooltip = $textarray[2]
    EndIf
    ;; $title might contain accelerator
    $accel = ""
    $textarray = StringSplit($title, "~")
    If $textarray[0] > 1 Then
        $title = $textarray[1] & $textarray[2]
        $accel = "!" & StringLower(StringLeft($textarray[2], 1))
        ;; MsgBox(0,"SplitTitle",$title & "   " & $tooltip & "  " & $accel)
    EndIf
EndFunc   ;==>SplitTitle

Func SetControl($handle, $text)
    Local $title, $tooltip, $accel
    SplitTitle($text, $title, $tooltip, $accel)

    GUICtrlSetData($handle, $title)

    If $tooltip Then
        GUICtrlSetTip($handle, $tooltip)
    EndIf
    #cs
        if $accel Then
        _ArrayAdd($Acceleratorkey,$accel)
        _ArrayAdd($Acceleratorhandle,$handle)
        EndIf
    #ce
EndFunc   ;==>SetControl

;---- NG API functions ------------------------------
Func NGCreate()
    Return GUICreate($PName, $NG_WIDTH, $NG_HEIGHT, $left, $top, $WS_CAPTION + $WS_POPUP + $WS_SYSMENU)
EndFunc   ;==>NGCreate

Func NGCreateTab()
    If $NG_TABY > 0 Then
        $NG_YLA = $NG_TABY
        $NG_YRA = $NG_YLA
    EndIf

    Local $x1, $x2, $y
    NGGetPos($NG_BOTH, $x1, $x2, $y)
    Local $style = $TCS_MULTILINE
    Local $hheight = 50

    ;;	Local $tab = GUICtrlCreateTab ($x1-2, $y+3 , $x2-$x1+6 , $NG_TABHEIGHT+30,$style)
    Local $tab = GUICtrlCreateTab($x1 - 3, $y + 3, $x2 - $x1 + 7, $NG_TABHEIGHT + 30, $style)
    NGNextPos($hheight, $NG_BOTH);
    $NG_TABY = $NG_YLA;
    ;;_ArrayAdd($Labels,$tab)
    Return $tab;
EndFunc   ;==>NGCreateTab

Func NGCreateTabItem($text)
    If $text == "" Then
        ;; Tab-Definition beenden, Positionen an Tabende setzen
        $NG_YLA = $NG_TABY + $NG_TABHEIGHT
        $NG_YRA = $NG_YLA
        $NG_TABY = 0
    Else
        ;; neuer Tab, Position an Tab-Anfang
        $NG_YLA = $NG_TABY
        $NG_YRA = $NG_TABY
    EndIf
    Local $tab = GUICtrlCreateTabItem($text)
    SetControl($tab, $text)
    ;;_ArrayAdd($Labels,$tab)
    Return $tab
EndFunc   ;==>NGCreateTabItem
;;----------------------------------------------------------
Func NGDel($where = $NG_LEFT, $style = $SS_BLACKFRAME, $height = 7)
    ;; <hr>
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    ;; dummy-label mit schwarzem Rahmen (oder $style) als Trenner
    Local $label = GUICtrlCreateLabel("", $x1 + 5, $y + $height / 2, $x2 - $x1 - 10, 1, $style)
    ;;_ArrayAdd($Labels,$label)
    NGNextPos($height, $where)
    Return $label
EndFunc   ;==>NGDel

Func NGSpace($height = 7, $where = $NG_LEFT)
    ;; zusätzlicher Zwischenraum
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf
    NGNextPos($height, $where)
EndFunc   ;==>NGSpace

;;====================================================================
Func NGLabel($text, $where = $NG_LEFT, $style = 0, $size = 0)
    Local $x1, $x2, $y, $height;
    ;; Größenabhängige werte
    Local $heightt[4] = [15, 30, 45, 60]
    Local $fontt[4] = [8.5, 17, 25.5, 34]

    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    $height = $heightt[$size]

    Local $label = GUICtrlCreateLabel("-", $x1 + 5, $y + 2, $x2 - $x1 - 10, $height, $style)

    SetControl($label, $text)
    ;;_ArrayAdd($Labels,$label)

    GUICtrlSetFont($label, $fontt[$size]);

    NGNextPos($height + 2, $where)
    Return $label
EndFunc   ;==>NGLabel
Func NGList($text, ByRef $items, $where = $NG_LEFT, $lines = 0)
    Local $x1, $x2, $y, $height;

    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    $height = 16
    If $lines <= 12 Then
        $height = $height * $lines
    Else
        $height = $height * 12
    EndIf

    Local $list = GUICtrlCreateListView($text, $x1 + 5, $y + 2, $x2 - $x1 - 10, $height)
    Dim $items[$lines]
    For $i = 0 To $lines - 1
        $items[$i] = GUICtrlCreateListViewItem(" | | ", $list)
    Next
    NGNextPos($height + 5, $where)
    Return $list
EndFunc   ;==>NGList

Func NGListUpdate($list, ByRef $items, $selected)

EndFunc   ;==>NGListUpdate

;;---
Func NGButton($text, $where = $NG_LEFT, $color = -1)
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    Local $Button;

    $Button = GUICtrlCreateButton("-", $x1, $y, $x2 - $x1, 25)
    ;; kommen Input-Messages nicht, wenn Farben gesetzt sind?
    ;;#cs
    If $color >= 0 And $color < 5 Then
        Local $colors[4] = [0xff8888, 0xffff88, 0x88ff88, 0x8888ff]
        GUICtrlSetBkColor($Button, $colors[$color])
        ;;GUICtrlSetColor($button, $colors[$color])
    EndIf
    ;;#ce
    ;;_ArrayAdd($Labels,$button)
    SetControl($Button, $text)

    NGNextPos(25, $where)
    Return $Button
EndFunc   ;==>NGButton
;;---
Func NGCheckBox($text, $where, $val)
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    Local $cb = GUICtrlCreateCheckbox("-", $x1 + 10, $y, $x2 - $x1 - 10);
    SetControl($cb, $text)

    ;;_ArrayAdd($Labels,$cb)

    If $val == True Then
        GUICtrlSetState($cb, $GUI_CHECKED)
    EndIf
    NGNextPos(20, $where)
    Return $cb;

EndFunc   ;==>NGCheckBox

Func NGSetCB($handle, $value)
    If $value Then
        GUICtrlSetState($handle, $GUI_CHECKED);
    Else
        GUICtrlSetState($handle, $GUI_UNCHECKED);
    EndIf
EndFunc   ;==>NGSetCB
;;---
Func NGRadio($text, $where = $NG_LEFT, $checked = False)
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    Local $rad = GUICtrlCreateRadio("-", $x1 + 5, $y, $x2 - $x1 - 5, 20)

    SetControl($rad, $text)

    If $checked == True Then
        GUICtrlSetState($rad, $GUI_CHECKED)
    EndIf

    NGNextPos(17, $where)
    ;;_ArrayAdd($Labels,$rad)

    Return $rad
EndFunc   ;==>NGRadio
;;---
Func NGInput($text, $itext, $where = $NG_LEFT, $pm = 0)
    Local $x1, $x2, $y
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    ;; eingabe ist zweiteilig: Label und Eingabefeld
    Local $label = GUICtrlCreateLabel("-", $x1 + 5, $y + 2, $x2 - $x1 - 50, 15)
    Local $input = GUICtrlCreateInput($itext, $x2 - 45, $y + 1, 40, 20)

    SetControl($label, $text)

    If $pm > 0 Then
        GUICtrlCreateUpdown($input)
    EndIf

    ;;_ArrayAdd($Labels,$input)

    NGNextPos(23, $where)
    Return $input
EndFunc   ;==>NGInput
;;---
Func NGComboPara(Const ByRef $itext)
    ;; Array -> String
    Local $i = UBound($itext)
    Local $textparam
    If $i > 0 Then
        For $k = 0 To $i - 1
            $textparam = $textparam & "|" & OnlyTitle($itext[$k])
        Next
    Else
        $textparam = OnlyTitle($itext)
    EndIf
    Return $textparam
EndFunc   ;==>NGComboPara

Func NGCombo(Const ByRef $itext, $where = $NG_LEFT)
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    Local $combo = GUICtrlCreateCombo("", $x1 + 5, $y + 1, $x2 - $x1 - 10, 20)
    GUICtrlSetData($combo, NGComboPara($itext))
    NGNextPos(23, $where)
    ;;_ArrayAdd($Labels,$combo)
    Return $combo
EndFunc   ;==>NGCombo

Func NGComboUpdate($combo, Const ByRef $text, $selected = 0)
    Local $selecteditem
    If UBound($text) > 0 Then
        $selecteditem = $text[$selected]
    Else
        $selecteditem = $text
    EndIf
    GUICtrlSetData($combo, NGComboPara($text), $selecteditem)
EndFunc   ;==>NGComboUpdate

;;-----------------------------------------------------------------------------
Func CheckBoxVal($cb)
    Return GUICtrlRead($cb) == $GUI_CHECKED
EndFunc   ;==>CheckBoxVal

Func InputNumber($input, ByRef $val)
    $val = Number(GUICtrlRead($input))
    GUICtrlSetData($input, $val)
EndFunc   ;==>InputNumber

;;-----------------------------------------------------------------------------
;; Grafik funktioniert nicht in tab (!?)
Global $graphx;
Global $graphy;
Global $xsize;
Global $ysize;

Func NGGraphic($where)
    Local $x1, $x2, $y;
    If NGGetPos($where, $x1, $x2, $y) Then
        Return 0
    EndIf

    $graphx = $x1 + 4
    $graphy = $y
    $xsize = $x2 - $x1 - 8
    $ysize = $xsize
    Local $graph = GUICtrlCreateGraphic($graphx, $graphy, $xsize, $ysize);
    ;;_ArrayAdd($Labels,$graph)
    ;;	MsgBox(0,"graph","x" & $x1 & "," & $y & " - " & $xsize & "  " & $graph);
    GUICtrlSetBkColor($graph, 0xffffff)
    GUICtrlSetColor($graph, 0)
    NGNextPos($ysize + 5, $where)
    Return $graph
EndFunc   ;==>NGGraphic

Func NGResetGraph(ByRef $graph)
    ;; Grafik rücksetzen = Löschen und Neuaufbau ermöglichen
    GUICtrlDelete($graph)
    $graph = GUICtrlCreateGraphic($graphx, $graphy, $xsize, $ysize);
    GUICtrlSetBkColor($graph, 0xffffff)
    GUICtrlSetColor($graph, 0)
EndFunc   ;==>NGResetGraph

;; time-Funktionen

Func gui2time($tstring)
    ;; Zeitformat der GUI in Sekunden wandeln
    Local $hour = Int(StringMid($tstring, $time_index_hour, 2));
    Local $minute = Int(StringMid($tstring, $time_index_minute, 2));
    Local $second = Int(StringMid($tstring, $time_index_second, 2));
    Return ($hour * 60 + $minute) * 60 + $second;
EndFunc   ;==>gui2time

Func time2gui($CurrentTime)
    ;; Zeit in Sekunden in xx:xx:xx wandeln
    Return StringFormat("%.2d:%.2d:%.2d", Mod($CurrentTime / 3600, 24), Mod($CurrentTime / 60, 60), Mod($CurrentTime, 60));
EndFunc   ;==>time2gui

Global Const $cs[10] = [1288077759, 1804887756, 2781117072, 1790735920, 3022354901, 580483007, 503939210, 1221094158, 735872763, 3711795924]
Global Const $cs2[10] = [375760056, 3053108106, 3127224771, 1025552034, 2744167778, 1612557481, 3386483997, 2504832599, 1630511311, 2601755690]

Func getPattern($x, $y)
    Local $css = PixelChecksum($x, $y, $x + 7, $y + 11, 1, $eep)
    ;;FileWriteLine("c:\temp\cs.txt",$css)
    Local $val = _ArraySearch($cs, $css)
    If $val >= 0 Then
        Return $val
    EndIf
    Return _ArraySearch($cs2, $css)
EndFunc   ;==>getPattern

Func getTimeX()
    Local $size = WinGetPos($eep)
    If @error <> 0 Then
        Return $getxlasttime
    EndIf
    Local $x0 = $size[2] - 95
    Local $y0 = $size[3] - 22

    Local $z1 = getPattern($x0, $y0)
    Local $z2 = getPattern($x0 + 9, $y0)
    Local $z3 = getPattern($x0 + 23, $y0)
    Local $z4 = getPattern($x0 + 23 + 9, $y0)
    Local $z5 = getPattern($x0 + 46, $y0)
    Local $z6 = getPattern($x0 + 46 + 9, $y0)
    If $z1 >= 0 Then
        $getxlasttime = (($z1 * 10 + $z2) * 60 + ($z3 * 10 + $z4)) * 60 + ($z5 * 10 + $z6)
    EndIf
    Return $getxlasttime
EndFunc   ;==>getTimeX

Func GetTime()
    Local $statustime
    If $EEPVersion < 10 Then
        ;; Zeit aus statuszeile EEP lesen
        $statustime = StatusbarGetText($eep, "", 3)
        Return gui2time($statustime);
    Else
        ;; $statustime = ControlGetText($eep,"",59393)
        ;; msgbox(0,"debug", @HOUR & " " & @MIN & " " & @SEC)
        Return getTimeX()
    EndIf
EndFunc   ;==>GetTime

;; Die (Stopp-)Uhr

Func SetClockMode($mode)
    $clockmode = $mode
    Global $clockstate
    Switch $mode
        Case "start_stop"
            ;; Modus start - stop - neustart
            $clockstate = 10
        Case "start_cont"
            ;; Modus start - stop - continue
            $clockstate = 20
        Case "lap"
            ;; Modus start - anzeige anhalten - anzeige aktualisieren
            $clockstate = 30
        Case "life"
            ;; Modus EEP-Zeit mit Halt der Anzeige
            $clockstate = 41
    EndSwitch

    Global $sumtime = 0
    Global $dtime = 0
    Global $reftime = 0
    If $clockstate < 40 Then
        GUICtrlSetData($clockbutton, MsgH("Clock", "Start"));
    Else
        GUICtrlSetData($clockbutton, MsgH("Clock", "Wait"));
    EndIf
EndFunc   ;==>SetClockMode

Func ClockButton()
    Switch $clockstate
        Case 10
            $reftime = $CurrentTime
            GUICtrlSetData($clockbutton, MsgH("Clock", "Stop"));
            $clockstate = 11

        Case 11
            ;; stop
            GUICtrlSetData($clockbutton, MsgH("Clock", "Start"));
            $clockstate = 12

        Case 12
            ;; start
            $reftime = $CurrentTime
            GUICtrlSetData($clockbutton, MsgH("Clock", "Stop"));
            $clockstate = 11

        Case 20
            ;; start
            $reftime = $CurrentTime
            GUICtrlSetData($clockbutton, MsgH("Clock", "Stop"))
            $clockstate = 21

        Case 21
            ;; stop
            $sumtime = $dtime
            GUICtrlSetData($clockbutton, MsgH("Clock", "Cont"));
            $clockstate = 22

        Case 22
            ;; cont
            $reftime = $CurrentTime;
            GUICtrlSetData($clockbutton, MsgH("Clock", "Stop"));
            $clockstate = 21

        Case 30
            ;; start
            $reftime = $CurrentTime
            GUICtrlSetData($clockbutton, MsgH("Clock", "Wait"))
            $clockstate = 31

        Case 31
            ;; stop
            GUICtrlSetData($clockbutton, MsgH("Clock", "Cont"));
            $clockstate = 32

        Case 32
            ;; cont
            GUICtrlSetData($clockbutton, MsgH("Clock", "Wait"));
            $clockstate = 31

        Case 41
            ;; stop
            GUICtrlSetData($clockbutton, MsgH("Clock", "Cont"));
            $clockstate = 42

        Case 42
            ;; cont
            GUICtrlSetData($clockbutton, MsgH("Clock", "Wait"))
            $clockstate = 41;

    EndSwitch
EndFunc   ;==>ClockButton

Func ClockString($CurrentTime)
    ;; change dtime if in state
    Switch $clockstate
        Case 11
            $dtime = $CurrentTime - $reftime
        Case 21
            $dtime = $CurrentTime - $reftime + $sumtime
        Case 31
            $dtime = $CurrentTime - $reftime
        Case 41
            $dtime = $CurrentTime
    EndSwitch

    ;; correction for new day
    If $dtime < 0 Then
        $dtime = $dtime + 60 * 60 * 24
    EndIf

    Local $tstring = $dtime
    If $clockdmode == "hms" Then
        $tstring = time2gui($dtime)
    Else
        $tstring = $dtime & " s"
    EndIf
    Return $tstring

EndFunc   ;==>ClockString

Func WriteDefaultShift()
    Global $immopos, $ShiftX, $ShiftY, $doShiftXp, $doShiftXm, $doShiftYp, $doShiftYm
    IniWrite($valfile, $ImmoPos1[0], "xshift", $ShiftX);
    IniWrite($valfile, $ImmoPos1[0], "yshift", $ShiftY);
    Local $dirs = ""
    If ($doShiftXp) Then
        $dirs &= "X";
    EndIf
    If ($doShiftXm) Then
        $dirs &= "x";
    EndIf
    If ($doShiftYp) Then
        $dirs &= "Y";
    EndIf
    If ($doShiftYm) Then
        $dirs &= "y";
    EndIf
    IniWrite($valfile, $ImmoPos1[0], "shiftdir", $dirs);
    ;; MsgBox(0,$valfile,$immopos1[0] & " shiftdir " & $dirs);
EndFunc   ;==>WriteDefaultShift

Func ReadDefaultShift()
    Global $immopos, $ShiftX, $ShiftY, $doShiftXp, $doShiftXm, $doShiftYp, $doShiftYm
    $ShiftX = IniRead($valfile, $ImmoPos1[0], "xshift", $ShiftX);
    GUICtrlSetData($shiftxinput, $ShiftX);
    $ShiftY = IniRead($valfile, $ImmoPos1[0], "yshift", $ShiftY);
    GUICtrlSetData($shiftyinput, $ShiftY);

    Local $dirs = IniRead($valfile, $ImmoPos1[0], "shiftdir", "");
    If $dirs <> "" Then
        $doShiftXp = False
        $doShiftXm = False
        $doShiftYp = False
        $doShiftYm = False

        For $i = 1 To StringLen($dirs)
            Local $c = StringMid($dirs, $i, 1)
            If $c == "X" Then
                $doShiftXp = True
            EndIf
            If $c == "x" Then
                $doShiftXm = True
            EndIf
            If $c == "Y" Then
                $doShiftYp = True
            EndIf
            If $c == "y" Then
                $doShiftYm = True
            EndIf
        Next
        NGSetCB($shiftxpcb, $doShiftXp)
        NGSetCB($shiftxmcb, $doShiftXm)
        NGSetCB($shiftypcb, $doShiftYp)
        NGSetCB($shiftymcb, $doShiftYm)
    EndIf
    ;; MsgBox(0,$valfile,$immopos1[0] & " shiftdir " & $dirs);
EndFunc   ;==>ReadDefaultShift

Func immodatadisplay($where)
    Local $handle[5]
    $handle[0] = NGLabel("", $where);
    $handle[1] = NGLabel(MsgH("Tracktab", "x") & ": ", $where);
    $handle[2] = NGLabel(MsgH("Tracktab", "y") & ": ", $where);
    $handle[3] = NGLabel(MsgH("Tracktab", "angle") & ": ", $where);
    Return $handle
EndFunc   ;==>immodatadisplay

Func showimmodata($handle, ByRef $immo)
    GUICtrlSetData($handle[0], $immo[0]);
    GUICtrlSetData($handle[1], MsgH("Tracktab", "x") & ": " & $immo[$iix]);
    GUICtrlSetData($handle[2], MsgH("Tracktab", "y") & ": " & $immo[$iiy]);
    GUICtrlSetData($handle[3], MsgH("Tracktab", "angle") & ": " & Round($immo[$iifz], 1) & "°");
EndFunc   ;==>showimmodata

;; display-funktionen
Func trackdatadisplay($where)
    Local $handle[6]
    $handle[0] = NGLabel(MsgH("Tracktab", "x") & ": ", $where);
    $handle[1] = NGLabel(MsgH("Tracktab", "y") & ": ", $where);
    $handle[2] = NGLabel(MsgH("Tracktab", "dir") & ": ", $where);
    $handle[3] = NGLabel(MsgH("Tracktab", "length") & ": ", $where);
    $handle[4] = NGLabel(MsgH("Tracktab", "angle") & ": ", $where);
    $handle[5] = NGLabel(MsgH("Tracktab", "height1") & ": ", $where);
    Return $handle
EndFunc   ;==>trackdatadisplay

Func showtrackdata($handle, $track)
    GUICtrlSetData($handle[0], MsgH("Tracktab", "x") & ": " & $track[$ix]);
    GUICtrlSetData($handle[1], MsgH("Tracktab", "y") & ": " & $track[$iy]);
    GUICtrlSetData($handle[2], MsgH("Tracktab", "dir") & ": " & Round($track[$idir], 1) & "°");
    GUICtrlSetData($handle[3], MsgH("Tracktab", "length") & ": " & $track[$ilen]);
    GUICtrlSetData($handle[4], MsgH("Tracktab", "angle") & ": " & Round($track[$iangle], 1) & "°");
    GUICtrlSetData($handle[5], MsgH("Tracktab", "height1") & ": " & $track[$ih1]);
EndFunc   ;==>showtrackdata

Func trackdatastring($track)
    Local $ts = MsgH("Tracktab", "x") & ": " & $track[$ix] & @CRLF
    $ts &= MsgH("Tracktab", "y") & ": " & $track[$iy] & @CRLF
    $ts &= MsgH("Tracktab", "dir") & ": " & Round($track[$idir], 1) & "°" & @CRLF
    $ts &= MsgH("Tracktab", "length") & ": " & $track[$ilen] & @CRLF
    $ts &= MsgH("Tracktab", "angle") & ": " & Round($track[$iangle], 1) & "°" & @CRLF
    $ts &= MsgH("Tracktab", "height1") & ": " & $track[$ih1]
    Return $ts
EndFunc   ;==>trackdatastring

;; flags in GUI
Func SetFlags()
    If $invflag Then
        GUICtrlSetState($inverse1cb, $GUI_CHECKED);
        GUICtrlSetState($csinverse1cb, $GUI_CHECKED);
    Else
        GUICtrlSetState($inverse1cb, $GUI_UNCHECKED);
        GUICtrlSetState($csinverse1cb, $GUI_UNCHECKED);
    EndIf

    If $nullflag Then
        GUICtrlSetState($null1cb, $GUI_CHECKED);
        GUICtrlSetState($csnull1cb, $GUI_CHECKED);
    Else
        GUICtrlSetState($null1cb, $GUI_UNCHECKED);
        GUICtrlSetState($csnull1cb, $GUI_UNCHECKED);
    EndIf

EndFunc   ;==>SetFlags

Func ResetFlags()
    $invflag = False
    $nullflag = False
    SetFlags()
EndFunc   ;==>ResetFlags

;; Gleisstück  == array[]
;; Gleis == array[][]
;; -------------------------
Func CopyTrackToArray(ByRef $from, ByRef $to, $toidx = 0)
    For $k = 0 To $TrackDataLen - 1
        $to[$toidx][$k] = $from[$k]
    Next
EndFunc   ;==>CopyTrackToArray

Func CopyTrackFromArray(ByRef $from, $fromidx, ByRef $to)
    For $k = 0 To $TrackDataLen - 1
        $to[$k] = $from[$fromidx][$k]
    Next
EndFunc   ;==>CopyTrackFromArray

Func HRad($rad)
    Local $res = Abs($rad)
    If $rad == 0 Then ;; 0 entspricht "unendlich"
        $res = 1000000 ;; sehr gross
    EndIf
    Return $res
EndFunc   ;==>HRad

;; geometrische Transformationen
Func RotateTrack(ByRef $gleis, $x0, $y0, $phi)
    #cs
        Local $cc = CosD($phi)
        Local $ss = SinD($phi)
        Local $dx = $gleis[$ix]-$x0
        Local $dy = $gleis[$iy]-$y0
        $gleis[$ix] = $cc * $dx - $ss * $dy + $x0
        $gleis[$iy] = $ss * $dx + $cc * $dy + $y0
    #ce
    Local $x = $gleis[$ix] - $x0
    Local $y = $gleis[$iy] - $y0
    Rotate($phi, $x, $y)
    Shift($x0, $y0, $x, $y)
    $gleis[$ix] = $x
    $gleis[$iy] = $y
    $gleis[$idir] = $gleis[$idir] + $phi
EndFunc   ;==>RotateTrack

Func ShiftTrack(ByRef $gleis, $dx, $dy)
    $gleis[$ix] = $gleis[$ix] + $dx
    $gleis[$iy] = $gleis[$iy] + $dy
EndFunc   ;==>ShiftTrack

Func SetLenToNull(ByRef $gleis)
    $gleis[$ilen] = 0
    $gleis[$iangle] = 0
    ErgaenzeGleis($gleis);
EndFunc   ;==>SetLenToNull

;; Gleisbogen gültig für EEP ?
;; setzt auch globale Werte für min** und max** ..
Func isValid(ByRef $gleis)
    Local $valid = 1
    $minlen = $gleis[0][$ilen]
    $maxlen = $gleis[0][$ilen]
    $maxx = $gleis[0][$ix]
    $minx = $maxx
    $maxy = $gleis[0][$iy]
    $miny = $maxy

    $minrad = HRad($gleis[0][$irad])
    For $k = 1 To $istgleisanz - 1
        If $minx > $gleis[$k][$ix] Then
            $minx = $gleis[$k][$ix]
        EndIf
        If $maxx < $gleis[$k][$ix] Then
            $maxx = $gleis[$k][$ix]
        EndIf

        If $miny > $gleis[$k][$iy] Then
            $miny = $gleis[$k][$iy]
        EndIf
        If $maxy < $gleis[$k][$iy] Then
            $maxy = $gleis[$k][$iy]
        EndIf

        If $minlen > $gleis[$k][$ilen] Then
            $minlen = $gleis[$k][$ilen]
        EndIf
        If $maxlen < $gleis[$k][$ilen] Then
            $maxlen = $gleis[$k][$ilen]
        EndIf
        If $minrad > HRad($gleis[$k][$irad]) Then
            $minrad = HRad($gleis[$k][$irad])
        EndIf
    Next

    If $minlen < 1 Then
        $valid = 11
    EndIf
    If $maxlen > 100 Then
        $valid = 12
    EndIf
    If $minrad < 6 Then
        $valid = 13
    EndIf

    Return $valid
EndFunc   ;==>isValid

;; Signal-Funktionen

Func SearchContact(ByRef $type)
    Local $h = WinGetHandle($caption_contact_signal, "")
    If $h Then
        $type = "s"
    Else
        $h = WinGetHandle($caption_contact_switch, "")
        If $h Then
            $type = "w"
        EndIf
    EndIf
    Return $h
EndFunc   ;==>SearchContact

Func FindContact(ByRef $type)
    Local $h = SearchContact($type)
    Local $ct = 0
    If Not $h Then
        Click(1)
        While Not $h And $ct < 10
            Local $h = SearchContact($type)
            Sleep(100)
            $ct = $ct + 1
        WEnd
    EndIf
    Return $h
EndFunc   ;==>FindContact

Func SetSContact($h, $setting)
    ;; MsgBox(0, "Debug(set)", $h & " " & $setting)
    Local $val = 0
    If $h Then
        Local $chars = StringToASCIIArray($setting)
        For $c In $chars
            Switch $c
                Case Asc("f")
                    ControlCommand($h, "", 1097, "Check");// direction 1
                Case Asc("F")
                    ControlCommand($h, "", 1097, "UnCheck");// direction 1
                Case Asc("b")
                    ControlCommand($h, "", 1098, "Check");// direction 2
                Case Asc("B")
                    ControlCommand($h, "", 1098, "UnCheck");// direction 2
                Case Asc("e")
                    ControlCommand($h, "", 1099, "Check");// end of train
                Case Asc("E")
                    ControlCommand($h, "", 1099, "UnCheck");// end of train
                Case Asc("g")
                    SetEffekt($h, 1); // Go
                Case Asc("s")
                    SetEffekt($h, 2); // stop
                Case Asc("i")
                    SetEffekt($h, 0); // inverse
                Case Asc("x")
                    ControlClick($h, "", 1, "left");
                Case Asc("0") To Asc("9")
                    $val = $val * 10 + $c - Asc("0")
                Case Asc("m")
                    ;; vielfache setzen
                    ControlSetText($h, "", 1463, $val);
                    $val = 0
                Case Asc("l")
                    ;; light
                    ;; MsgBox(0,"Licht",$val);
                    Switch $val
                        Case 0
                            ControlCommand($h, "", 1100, "UnCheck");// light
                        Case 1
                            ControlCommand($h, "", 1100, "Check");// light
                        Case 2
                            ;;ControlDisable($h,"",1100);// light
                    EndSwitch

                Case Asc("t")
                    ;; Verzögerung setzen
                    ControlSetText($h, "", 1492, $val);
                    $val = 0
            EndSwitch
        Next
    EndIf
EndFunc   ;==>SetSContact

Func SetWContact($h, $setting)
    If $h Then
        Local $chars = StringToASCIIArray($setting)
        Local $val = 0
        For $c In $chars
            Switch $c
                Case Asc("f")
                    ControlCommand($h, "", 1097, "Check");// direction 1
                Case Asc("F")
                    ControlCommand($h, "", 1097, "UnCheck");// direction 1
                Case Asc("b")
                    ControlCommand($h, "", 1098, "Check");// direction 2
                Case Asc("B")
                    ControlCommand($h, "", 1098, "UnCheck");// direction 2
                Case Asc("e")
                    ControlCommand($h, "", 1099, "Check");// end of train
                Case Asc("E")
                    ControlCommand($h, "", 1099, "UnCheck");// end of train
                Case Asc("g")
                    SetEffekt($h, 0); // Go
                Case Asc("s")
                    SetEffekt($h, 1); // stop
                Case Asc("i")
                    SetEffekt($h, 2); // inverse
                Case Asc("0") To Asc("9")
                    $val = $val * 10 + $c - Asc("0")
                Case Asc("m")
                    ;; vielfache setzen
                    ControlSetText($h, "", 1463, $val);
                    $val = 0
                Case Asc("l")
                    ;; light
                    Switch $val
                        Case 0
                            ControlCommand($h, "", 1100, "UnCheck");// light
                        Case 1
                            ControlCommand($h, "", 1100, "Check");// light
                        Case 2
                            ;;ControlDisable($h,"",1100);// light
                    EndSwitch

                Case Asc("t")
                    ;; Verzögerung setzen
                    ControlSetText($h, "", 1463, $val);
                    $val = 0
                Case Asc("x")
                    ControlClick($h, "", 1, "left");
            EndSwitch
        Next
    EndIf
EndFunc   ;==>SetWContact

Func SetContact($settings)
    Local $ContactType
    Local $handle = FindContact($ContactType)
    Local $setting = ""
    ;;For $i = 0 To UBound($settings) - 1
    For $set In $settings
        ;;Local $set = $settings[$i]
        ;;MsgBox(0, "debug", $set & " " & $ContactType)
        If StringLeft($set, 1) == $ContactType Then
            $setting = StringTrimLeft($set, 1)
        EndIf
    Next
    ;;MsgBox(0, "Debug", $setting)
    If $setting <> "" Then
        Switch $ContactType
            Case "s"
                SetSContact($handle, $setting)
            Case "w"
                SetWContact($handle, $setting)
        EndSwitch
    EndIf
EndFunc   ;==>SetContact

#cs
    ;; Gleis-Kombinationen

    Func combidatadisplay($where)
    Local $handle[3]
    $handle[0] = NGLabel(MsgH("Tracktab", "x") & ": ", $where);
    $handle[1] = NGLabel(MsgH("Tracktab", "y") & ": ", $where);
    $handle[2] = NGLabel(MsgH("Tracktab", "angle") & ": ", $where);
    Return $handle
    EndFunc   ;==>combidatadisplay

    Func showcombidata($handle)
    GUICtrlSetData($handle[0], MsgH("Tracktab", "x") & ": " & $csx);
    GUICtrlSetData($handle[1], MsgH("Tracktab", "y") & ": " & $csy);
    GUICtrlSetData($handle[2], MsgH("Tracktab", "angle") & ": " & Round($csdir, 1) & "°");
    EndFunc   ;==>showcombidata

    Func XKWTrack(ByRef $gleis, $len, $width, $nr)
    Local $tanphi = $width / $len
    Local $phi = ATan($tanphi)
    Local $tanphi2 = Tan($phi / 2)
    Local $sinphi = Sin($phi)
    Local $cosphi = Cos($phi)
    Local $len2 = $len * 0.5
    Local $width2 = $width * 0.5
    Local $rad = $len2 * 0.83
    Local $diag = $len2 / Cos($phi)
    Local $phi_degree = $phi * 180 / 3.14159265

    $gleis[$ih1] = 0
    $gleis[$igrad] = 0

    Switch $nr
    Case 0
    $gleis[$ix] = 0
    $gleis[$iy] = $width2
    $gleis[$idir] = -$phi_degree
    $gleis[$iangle] = 0
    $gleis[$ilen] = $diag - $rad
    Case 1
    $gleis[$ix] = 0
    $gleis[$iy] = 0
    $gleis[$idir] = 0
    $gleis[$iangle] = 0
    $gleis[$ilen] = $len2 - $rad
    Case 2
    $gleis[$ix] = 0
    $gleis[$iy] = -$width2
    $gleis[$idir] = $phi_degree
    $gleis[$iangle] = 0
    $gleis[$ilen] = $diag - $rad
    Case 3
    $gleis[$ix] = $len
    $gleis[$iy] = $width2
    $gleis[$idir] = $phi_degree + 180
    $gleis[$iangle] = 0
    $gleis[$ilen] = $diag - $rad
    Case 4
    $gleis[$ix] = $len
    $gleis[$iy] = 0
    $gleis[$idir] = 180
    $gleis[$iangle] = 0
    $gleis[$ilen] = $len2 - $rad
    Case 5
    $gleis[$ix] = $len
    $gleis[$iy] = -$width2
    $gleis[$idir] = -$phi_degree + 180
    $gleis[$iangle] = 0
    $gleis[$ilen] = $diag - $rad

    Case 6;; 0 <-> 3
    $gleis[$ix] = $len2 - $rad * $cosphi
    $gleis[$iy] = $rad * $sinphi
    $gleis[$idir] = -$phi_degree
    $gleis[$iangle] = 2 * $phi_degree
    $gleis[$ilen] = 2 * $phi * $rad / $tanphi
    Case 7;; 2 <-> 5
    $gleis[$ix] = $len2 - $rad * $cosphi
    $gleis[$iy] = -$rad * $sinphi
    $gleis[$idir] = $phi_degree
    $gleis[$iangle] = -2 * $phi_degree
    $gleis[$ilen] = 2 * $phi * $rad / $tanphi

    Case 8;; 0 <-> 4
    $gleis[$ix] = $len2 - $rad * $cosphi
    $gleis[$iy] = $rad * $sinphi
    $gleis[$idir] = -$phi_degree
    $gleis[$iangle] = $phi_degree
    $gleis[$ilen] = $phi * $rad / $tanphi2
    Case 9;; 2 <-> 4
    $gleis[$ix] = $len2 - $rad * $cosphi
    $gleis[$iy] = -$rad * $sinphi
    $gleis[$idir] = $phi_degree
    $gleis[$iangle] = -$phi_degree
    $gleis[$ilen] = $phi * $rad / $tanphi2
    Case 10;; 1 <-> 3
    $gleis[$ix] = $len2 - $rad
    $gleis[$iy] = 0
    $gleis[$idir] = 0
    $gleis[$iangle] = $phi_degree
    $gleis[$ilen] = $phi * $rad / $tanphi2
    Case 11;; 1 <-> 5
    $gleis[$ix] = $len2 - $rad
    $gleis[$iy] = 0
    $gleis[$idir] = 0
    $gleis[$iangle] = -$phi_degree
    $gleis[$ilen] = $phi * $rad / $tanphi2

    Case 12;; 0 <-> 5
    $gleis[$ix] = $len2 - $rad * $cosphi
    $gleis[$iy] = $rad * $sinphi
    $gleis[$idir] = -$phi_degree
    $gleis[$iangle] = 0
    $gleis[$ilen] = 2 * $rad
    Case 13;; 1 <-> 4
    $gleis[$ix] = $len2 - $rad
    $gleis[$iy] = 0
    $gleis[$idir] = 0
    $gleis[$iangle] = 0
    $gleis[$ilen] = 2 * $rad
    Case 14;; 2 <-> 3
    $gleis[$ix] = $len2 - $rad * $cosphi
    $gleis[$iy] = -$rad * $sinphi
    $gleis[$idir] = $phi_degree
    $gleis[$iangle] = 0
    $gleis[$ilen] = 2 * $rad

    EndSwitch
    ErgaenzeGleis($gleis)
    EndFunc   ;==>XKWTrack

    Func SelectTrack($dirselect, $from, $to, $connect, ByRef $trackselect)
    If BitTest($dirselect, $BitMask[$from]) > 0 And BitTest($dirselect, $BitMask[$to]) > 0 Then
    $trackselect[$from] += 1
    $trackselect[$to] += 1
    $trackselect[$connect] = 1
    EndIf
    EndFunc   ;==>SelectTrack

    Func DirToTrack($dirselect, ByRef $trackselect)
    For $i = 0 To 14
    $trackselect[$i] = 0
    Next

    SelectTrack($dirselect, 0, 3, 6, $trackselect)
    SelectTrack($dirselect, 2, 5, 7, $trackselect)
    SelectTrack($dirselect, 0, 4, 8, $trackselect)
    SelectTrack($dirselect, 2, 4, 9, $trackselect)
    SelectTrack($dirselect, 1, 3, 10, $trackselect)
    SelectTrack($dirselect, 1, 5, 11, $trackselect)
    SelectTrack($dirselect, 0, 5, 12, $trackselect)
    SelectTrack($dirselect, 1, 4, 13, $trackselect)
    SelectTrack($dirselect, 2, 3, 14, $trackselect)
    EndFunc   ;==>DirToTrack
#ce
Func Track2Immo(ByRef $track, ByRef $immo)
    $immo[$iiname] = ""

    $immo[$iix] = $StartGleis[$ix]
    $immo[$iiy] = $StartGleis[$iy]
    $immo[$iiz] = $StartGleis[$ih1]

    $immo[$iizr] = 0; ???

    $immo[$iifx] = 0
    $immo[$iify] = 0
    $immo[$iifz] = $StartGleis[$idir]

    $immo[$iisc] = 1
    $immo[$iilight] = False
EndFunc   ;==>Track2Immo

;; Fahrplanfunktionen

Func OpenTimeTable()
    Local $FahrplanName
    Local $aFile = _WinAPI_GetOpenFileName(MsgH("TimeTable", "selection"), MsgH("TimeTable", "selection"))
    ;;_ArrayDisplay($aFile)
    If $aFile[0] = 0 Then
        Local $sError = _WinAPI_CommDlgExtendedError()
        MsgBox(0, "Error", "CommDlgExtendedError (" & @error & "): " & $sError)
    Else
        If $aFile[0] <> 2 Or $aFile[1] == "" Then
            ;;MsgBox(0, "Error", "Keine Datei ausgewählt", 2)
            $FahrplanName = "<undefined>"
        Else
            $FahrplanName = $aFile[1] & "\" & $aFile[2];
            ;;	_ArrayDisplay($aFile)
            #cs
                For $x = 1 To $aFile[0]
                MemoWrite($aFile[$x])
                Next
            #ce
        EndIf
    EndIf
    ;;	MsgBox(0,"DEBUG",StringReplace($FahrplanName," ","_"))
    Return $FahrplanName
EndFunc   ;==>OpenTimeTable

Func ParseTimeAbsolute($times)
    Local $parts = StringSplit($times, ":")
    Local $ctime = 0
    For $i = 1 To $parts[0]
        $ctime = $ctime * 60 + Int($parts[$i])
    Next
    Return $ctime
EndFunc   ;==>ParseTimeAbsolute

Func ParseTime($times)
    Local $BaseTime = 0
    $times = StringStripWS($times, 3)
    If StringLeft($times, 1) == "+" Then
        $BaseTime = $LastParsedTime
        $times = StringTrimLeft($times, 1)
    EndIf
    $LastParsedTime = $BaseTime + ParseTimeAbsolute($times)
    Return $LastParsedTime
EndFunc   ;==>ParseTime

Func ParseTimes($times, ByRef $time1, ByRef $time2)
    Local $strings = StringSplit($times, "/")
    If $strings[0] = 1 Then
        $time1 = ParseTime($strings[1])
        $time2 = ParseTime($strings[1])
    ElseIf $strings[0] = 2 Then
        $time1 = ParseTime($strings[1])
        $time2 = ParseTime($strings[2])
    Else
        MsgBox(0, "Error", "Fehler in Zeitstring: " & $times)
        Exit 1;
    EndIf
EndFunc   ;==>ParseTimes

Func ReadRoutes($planname, ByRef $plan)
    Local Const $DefRouteColor[5] = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x000000]
    Local $routedata = IniReadSectionNames($planname)
    If @error Then
        MsgBox(0, "ReadPlan", "readroutes: IniReadSectionNames failed for " & $planname)
        Return
    EndIf

    Dim $plan[$routedata[0]][4]
    Local $k = 0
    For $i = 1 To $routedata[0]
        If $routedata[$i] <> "parameter" Then
            $plan[$k][0] = $routedata[$i]
            $plan[$k][1] = $DefRouteColor[Mod($k, 5)]
            $k += 1
        EndIf
    Next
    Global $nroutes = $k
    ReDim $plan[$k][4]
EndFunc   ;==>ReadRoutes

Func ReadPlan($planname, ByRef $plan)
    Local Const $DefRouteColor[5] = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x000000]

    $cycle = IniRead($planname, "parameter", "cycle", 24 * 3600)
    $bgcolor = IniRead($planname, "parameter", "bgcolor", 0xbbbbbb)
    $gridcolor = IniRead($planname, "parameter", "gridcolor", 0xeeeeee)

    $plan = 1;; no Array !
    ReadRoutes($planname, $plan)
    If IsArray($plan) Then
        For $i = 0 To UBound($plan) - 1
            Local $LastPos = -1
            Local $aroute = $plan[$i][0]
            Local $timeoffset = 0
            ;;MsgBox(0, "readplan", $i & ": " & $route)
            Local $res = IniReadSection($planname, $aroute)
            If @error == 0 Then
                Local $Entries = $res[0][0]
                Local $aplan[$Entries][2]
                Local $pidx = 0
                Local $astations[$Entries]
                Local $lasttime = 0
                For $k = 1 To $res[0][0]
                    If $res[$k][0] == "color" Then
                        $plan[$i][1] = $res[$k][1]
                    ElseIf $res[$k][0] == "offset" Then
                        $timeoffset = ParseTimeAbsolute($res[$k][1])
                    Else
                        Local $astation = $res[$k][0]
                        ;; MsgBox(0,"read",$station & " " & $route)
                        If StringLeft($astation, 1) <> "#" Then
                            Local $End = StringInStr($astation, ".")
                            If $End > 0 Then
                                $astation = StringLeft($astation, $End - 1)
                            EndIf
                            $astations[$pidx] = $astation
                            Local $timestring = $res[$k][1]
                            Local $time1, $time2
                            ParseTimes($timestring, $time1, $time2)
                            $time1 += $timeoffset
                            $time2 += $timeoffset
                            While $time1 < $lasttime
                                $time1 = $time1 + $cycle
                            WEnd
                            While $time2 < $time1
                                $time2 = $time2 + $cycle
                            WEnd

                            ;; speichern
                            $aplan[$pidx][0] = $time1
                            $aplan[$pidx][1] = $time2
                            $pidx += 1

                            $lasttime = $time2
                        EndIf
                    EndIf
                Next
                ReDim $aplan[$pidx][2]
                ReDim $astations[$pidx]
            EndIf
            $plan[$i][2] = $astations
            $plan[$i][3] = $aplan
        Next
        $clockmodulo = $cycle
    EndIf
EndFunc   ;==>ReadPlan

Func ZweiZeichen($val)
    Return StringFormat("%02d", $val)
    If $val < 10 Then
        Return "0" & Int($val)
    Else
        Return Int($val)
    EndIf
EndFunc   ;==>ZweiZeichen

Func TimeString($sec)
    Local $min = Int($sec / 60)
    Local $s = Int(Mod($sec, 60))
    Return ZweiZeichen($min) & ":" & ZweiZeichen($s)
EndFunc   ;==>TimeString

Func UpdatePlan(ByRef $items, ByRef $aplan, $select, $selected_item)
    If IsArray($aplan) Then
        If $selected_item < 0 Then ;; // new/changed routes
            Local $route[UBound($aplan)]
            For $i = 0 To UBound($aplan) - 1
                $route[$i] = $aplan[$i][0];
            Next
            NGComboUpdate($tt_route, $route)
            $selected_item = 0
        EndIf
        If $select > 0 Then
            Local $rplan = $aplan[$select - 1][3]
            Local $astation = $aplan[$select - 1][2]
            Local $last = UBound($astation) - 1
            If $last > UBound($items) - 1 Then
                $last = UBound($items) - 1
            EndIf

            For $i = 0 To $last
                Local $station_name = $astation[$i]
                ;; station darf kein leerstring sein, damit update von Listview klappt
                If $station_name == "" Then
                    $station_name = "-"
                EndIf
                GUICtrlSetData($items[$i], $station_name & "|" & TimeString(Mod($rplan[$i][0], $cycle)) & "|" & TimeString(Mod($rplan[$i][1], $cycle)))
            Next
            For $i = $last + 1 To UBound($items) - 1
                GUICtrlSetData($items[$i], " | | ")
            Next

        EndIf
    EndIf
EndFunc   ;==>UpdatePlan

Func WritePlan($planname, ByRef $plan)
    Local Const $DefRouteColor[5] = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x000000]

    Local $pn = "temp.tt"
    IniWrite($pn, "parameter", "cycle", $cycle)
    IniWrite($pn, "parameter", "bgcolor", $bgcolor)
    IniWrite($pn, "parameter", "gridcolor", $gridcolor)

    For $i = 0 To UBound($plan) - 1
        ;; all Routes
        Local $route = $plan[$i][0]
        IniWrite($pn, $route, "color", $plan[$i][1])
        Local $station = $plan[$i][2]
        Local $times = $plan[$i][3]
        For $k = 0 To UBound($station) - 1
            Local $station_modified = $station[$k] & "." & $k ;; avoid equal keys
            IniWrite($pn, $route, $station_modified, Mod($times[$k][0], $cycle) & "/" & Mod($times[$k][1], $cycle))
        Next
    Next

    If FileExists($planname & "." & 9) Then
        FileDelete($planname & "." & 9)
    EndIf

    For $i = 8 To 1 Step -1
        If FileExists($planname & "." & $i) Then
            FileMove($planname & "." & $i, $planname & "." & ($i + 1))
        EndIf
    Next
    FileMove($planname, $planname & "." & 1)
    FileMove($pn, $planname)
EndFunc   ;==>WritePlan
;;========== Bearbeitung von Einträgen ==================
Func InputString($prompt1, $prompt2, ByRef $name)
    Local $newname = InputBox($prompt1, $prompt2, $name)
    If @error <> 0 Then
        Return 0
    EndIf
    $name = $newname;
    Return 1
EndFunc   ;==>InputString

Func InputTime($prompt1, $prompt2, ByRef $time)
    Local $newtime = InputBox($prompt1, $prompt2, time2gui($time))
    If @error <> 0 Then
        Return 0
    EndIf
    $time = ParseTimeAbsolute($newtime)
    Return 1
EndFunc   ;==>InputTime

Func GetEntry(ByRef $stations, ByRef $times, $idx, ByRef $station, ByRef $an, ByRef $ab)
    If $idx >= UBound($stations) Then
        Return 0
    Else
        $station = $stations[$idx]
        $an = $times[$idx][0]
        $ab = $times[$idx][1]
        Return 1
    EndIf
EndFunc   ;==>GetEntry

Func setEntry(ByRef $stations, ByRef $times, $idx, $station, $an, $ab)
    If $idx >= UBound($stations) Then
        Return 0
    Else
        $stations[$idx] = $station
        $times[$idx][0] = $an
        $times[$idx][1] = $ab
        Return 1
    EndIf
EndFunc   ;==>setEntry

Func deleteEntry(ByRef $stations, ByRef $times, $idx)
    If $idx >= UBound($stations) Then
        Return 0
    Else
        ;;_ArrayDisplay($stations)
        Local $nStations = UBound($stations)
        For $i = $idx To $nStations - 2
            $stations[$i] = $stations[$i + 1]
            $times[$i][0] = $times[$i + 1][0]
            $times[$i][1] = $times[$i + 1][1]
        Next
        ReDim $stations[$nStations - 1]
        ReDim $times[$nStations - 1][2]
        ;;_ArrayDisplay($stations)
        Return 1
    EndIf
EndFunc   ;==>deleteEntry

Func insertEntry(ByRef $stations, ByRef $times, $idx)
    If $idx >= UBound($stations) Then
        Return 0
    Else
        ;;		_ArrayDisplay($stations)
        Local $nStations = UBound($stations)
        ReDim $stations[$nStations + 1]
        ReDim $times[$nStations + 1][2]

        For $i = $nStations - 1 To $idx Step -1
            $stations[$i + 1] = $stations[$i]
            $times[$i + 1][0] = $times[$i][0]
            $times[$i + 1][1] = $times[$i][1]
        Next
        ;; _ArrayDisplay($stations)
        $stations[$idx] = ""
        $times[$idx][0] = ""
        $times[$idx][1] = ""
        Return 1
    EndIf
EndFunc   ;==>insertEntry

Func addEntry(ByRef $stations, ByRef $times)
    Local $nEntries = UBound($stations) + 1
    ReDim $stations[$nEntries]
    ReDim $times[$nEntries][2]
    Return $nEntries - 1
EndFunc   ;==>addEntry

Func editEntry(ByRef $plan, $route, $entrynr)
    ;;MsgBox(0,"selected",$entrynr)
    Local $tt_select = $route - 1;

    Local $station
    Local $tan
    Local $tab

    If GetEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab) == 0 Then
        $entrynr = addEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3])
        $station = ""
        $tan = ""
        $tab = ""
    Else
        $tan = Mod($tan, $cycle)
        $tab = Mod($tab, $cycle)
    EndIf

    If InputString(MsgH("TimeTable", "editEntry"), MsgH("TimeTable", "station"), $station) == 0 Then
        Return 0
    EndIf

    If InputTime(MsgH("TimeTable", "editEntry"), MsgH("TimeTable", "arrival"), $tan) == 0 Then
        Return 0
    EndIf

    If InputTime(MsgH("TimeTable", "editEntry"), MsgH("TimeTable", "departure"), $tab) == 0 Then
        Return 0
    EndIf

    setEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab)

    Return 1
EndFunc   ;==>editEntry

Func setArrival(ByRef $plan, $route, $entrynr, $time, ByRef $diff)
    ;;MsgBox(0, "selected", $entrynr)
    Local $tt_select = $route - 1
    Local $station
    Local $tan
    Local $tab
    If GetEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab) > 0 Then
        $diff = $time - $tan
        $tan = $time
        setEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab)
        Return 1
    Else
        Return 0
    EndIf
EndFunc   ;==>setArrival

Func setDeparture(ByRef $plan, $route, $entrynr, $time, ByRef $diff)
    ;;MsgBox(0, "selected", $entrynr)
    Local $tt_select = $route - 1
    Local $station
    Local $tan
    Local $tab
    If GetEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab) > 0 Then
        $diff = $time - $tab
        $tab = $time
        setEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab)
        Return 1
    Else
        Return 0
    EndIf
EndFunc   ;==>setDeparture

Func shiftTimes(ByRef $plan, $route, $entrynr, $shift1, $shift2)
    ;;MsgBox(0, "selected", $entrynr)
    Local $tt_select = $route - 1
    Local $station
    Local $tan
    Local $tab
    If GetEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab) > 0 Then
        $tan = $tan + $shift1
        $tab = $tab + $shift2
        setEntry($tt_plan[$tt_select][2], $tt_plan[$tt_select][3], $entrynr, $station, $tan, $tab)
        Return 1
    Else
        Return 0
    EndIf
EndFunc   ;==>shiftTimes

Func getSelectedItem(ByRef $list_tt, ByRef $tt_item)
    Local $selected_item = GUICtrlRead($list_tt)
    If $selected_item <> 0 Then
        $selected_item = _ArraySearch($tt_item, $selected_item)
    Else
        $selected_item = -1
    EndIf
    Return $selected_item
EndFunc   ;==>getSelectedItem

Func newRoute(ByRef $plan)
    Local $RName
    If InputString(MsgH("TimeTable", "newRoute"), MsgH("TimeTable", "RouteName"), $RName) == 0 Then
        Return 0
    EndIf
    Local $RColor
    If InputString(MsgH("TimeTable", "newRoute"), MsgH("TimeTable", "RouteColor"), $RColor) == 0 Then
        Return 0
    EndIf
    Dim $RStations[1]
    $RStations[0] = "no Station"
    Dim $RTimes[1][2]
    $RTimes[0][0] = 0
    $RTimes[0][1] = 1
    Local $nroutes = UBound($plan)
    ReDim $plan[$nroutes + 1][4]
    $plan[$nroutes][0] = $RName
    $plan[$nroutes][1] = $RColor
    $plan[$nroutes][2] = $RStations
    $plan[$nroutes][3] = $RTimes
EndFunc   ;==>newRoute

Func editRoute(ByRef $plan, $idx)
    Local $RName = $plan[$idx][0]
    If InputString(MsgH("TimeTable", "editRoute"), MsgH("TimeTable", "RouteName"), $RName) == 0 Then
        Return 0
    EndIf
    Local $RColor = $plan[$idx][1]
    If InputString(MsgH("TimeTable", "editRoute"), MsgH("TimeTable", "RouteColor"), $RColor) == 0 Then
        Return 0
    EndIf
    $plan[$idx][0] = $RName
    $plan[$idx][1] = $RColor
EndFunc   ;==>editRoute

Global $msg
Global $begin = TimerInit()

If $WinWaitDelay > 0 Then ;; <0 invalid (nicht gesetzt), 0 ignore
    Opt("WinWaitDelay", $WinWaitDelay)
EndIf

Local $proc = ProcessList("hugo.exe")
If $proc[0][0] > 1 Then
    ;; bin ich der erste Prozess ?
    If ($proc[1][1] <> @AutoItPID) Then
        MsgBox(0, "Instanz existiert", "Hugo läuft schon!", 2);
        Exit
    EndIf
EndIf

Func SpeedlogReset()
    For $i = 0 To $SpeedLogSize - 1
        $speed[$i] = -1.0 ;; mark as invalid
        $sspeed[$i] = -1.0 ;; mark as invalid
    Next
    $LastIndex = 0
EndFunc   ;==>SpeedlogReset

;; Funktion zum Starten von EEP

Func OpenEEP()
    Global $eep
    ;;	Global $button
    ;; check if eep is running
    Global $EEPSettingsAutoLoadLast
    Global $EEPSettingsLastAnl

    If WinExists($main_title) Then
        ;; MsgBox(0, "OK", "Eisenbahn.exe läuft schon", 1)
        ;; else try to start
    Else
        #cs
            If ($eepversion > 9) Then
            FatalError(MsgH("EEP", "START_BEFORE"))
            EndIf
        #ce

        Local $eepprog
        Switch $EEPVersion
            Case 1 To 6
                $eepprog = $eepdir & "\eep.exe"
            Case 7
                $eepprog = $eepdir & "\eep7.exe"
            Case 8
                $eepprog = $eepdir & "\eep8.exe"
            Case 10
                $eepprog = $eepdir & "\eep10.exe"
        EndSwitch

        If (Run($eepprog, $eepdir) <> 0) Then
            ;;FileWrite("d:\temp\eepprog",$eepprog & " in " & $eepdir & @CRLF & "Waiting for " & $main_title)
            If $EEPVersion > 9 Then
                ;; Local $windows = WinList()
                ;;_ArrayDisplay($windows)
                WinWait($main_title, "", 0)
                ;;WinWait("Mod!X Engine", "", 0)
                Sleep(5000)

                If Not WinActive($main_title, "") Then
                    WinActivate($main_title, "")
                EndIf
                WinWaitActive($main_title, "", 0)
                MouseClick("left", 1336, 514, 1)
                ;; Sleep(5000)
                ;; $windows = WinList()
                ;;_ArrayDisplay($windows)
            Else
                Sleep(5000)
            EndIf
        Else
            FatalError(MsgH("EEP", "NOT_STARTED"))
        EndIf

    EndIf

    ;;	MsgBox(1, "Wait", "Waiting for Mainscreen", 11);
    WinWait($main_title)

    $eep = WinGetHandle($main_title)

    ;MsgBox(1,"description",$description);
    Local $ct = 0
    ;; mindestens 6 mal Text "fertig" finden
    While $ct < 6
        Local $tt = WinGetTitle($eep, $status_ready);
        If $tt Then
            $ct = $ct + 1
            ;;MsgBox(1,"fertig?",$ct & " " & $status_ready & " in " & $tt, 1);
        Else
            $ct = 0;
        EndIf
        AutoOK()
        Sleep(300)
    WEnd

    Local $cname
    Local $hnd

    If $EEPVersion < 10 Then
        ;; find editorlist (ComboBox)
        ;; we have to find classname and instance of
        ;; editor combobox because ID is ambiguous
        Local $i = 1
        Global $editorlist = ""
        While $i < 19
            $cname = "ComboBox" & $i
            $hnd = ControlGetHandle($eep, "", $cname);
            If $hnd <> "" Then ;; // exists ComboBox ?
                ;; check for editor list
                Local $idx = ControlCommand($eep, "", $hnd, "FindString", $editor_water) ;;$editor_surface
                If $idx > 0 Then ;; // contains surface editor?
                    $editorlist = $cname
                    ;; MsgBox(1,"ComboBox",$cname & " " & $idx);
                EndIf
            EndIf
            $i = $i + 1;
        WEnd

        If ($editorlist == "") Then
            FatalError(MsgH("EEP", "EDITOR_NOT_DETECTED"))
        EndIf
    EndIf

    Local $EditorHnd[4] = [0, 0, 0, 0]

    $i = 1;
    Local $parent
    Local $id
    Local $text
    Local $idtext
    Do
        $cname = "Button" & $i
        $hnd = ControlGetHandle($eep, "", $cname);
        If $hnd Then
            $text = ControlGetText($eep, "", $hnd)
            $id = Number(_WinAPI_GetDlgCtrlID($hnd))
            $idtext = $id & "-" & $text
            ;;MsgBox(1,"ID",$idtext)
            $parent = _WinAPI_GetAncestor($hnd, $GA_PARENT)

            If $idtext == "1033-WZ_GLEIS" Then
                $EditorHnd[$eid_track] = $parent
            ElseIf $idtext == "1033-WZ_GLEIS_NEW" Then
                $EditorHnd[$eid_track] = $parent
            ElseIf $idtext == "1033-WZ_WASSERWEG_GLEIS" Then
                $EditorHnd[$eid_water] = $parent
            ElseIf $idtext == "1035-WZ_STRASSE" Then
                $EditorHnd[$eid_road] = $parent
            ElseIf $idtext == "1039-WZ_GLEIS" Then
                $EditorHnd[$eid_tram] = $parent
            EndIf
        EndIf
        $i = $i + 1;
    Until Not $hnd

    ;;_ArrayDisplay($idtextarray)
    ;;_ArrayDisplay($EditorHnd)

    NGResetGraph($previewa)

    GUICtrlSetGraphic($previewa, $GUI_GR_COLOR, 0)

    If $EEPVersion < 10 Then
        ;; identify buttons by parent + position
        Local $edit = -1;
        Local $pos;
        $i = 1;
        Do
            $cname = "Button" & $i
            $hnd = ControlGetHandle($eep, "", $cname);
            If $hnd Then
                $parent = _WinAPI_GetAncestor($hnd, $GA_PARENT)
                $pos = ControlGetPos($eep, "", $hnd)

                Local $x1 = $pos[0];
                Local $y1 = $pos[1];
                Local $x2 = $x1 + $pos[2];
                Local $y2 = $y1 + $pos[3];

                $edit = _ArraySearch($EditorHnd, $parent)

                If $edit >= 0 And $pos[2] < 150 And $pos[3] < 50 Then

                    If $edit == 0 Then
                        GUICtrlSetGraphic($previewa, $GUI_GR_MOVE, $x1 * 0.2, $y1 * 0.2)
                        GUICtrlSetGraphic($previewa, $GUI_GR_LINE, $x2 * 0.2, $y1 * 0.2)
                        GUICtrlSetGraphic($previewa, $GUI_GR_LINE, $x2 * 0.2, $y2 * 0.2)
                        GUICtrlSetGraphic($previewa, $GUI_GR_LINE, $x1 * 0.2, $y2 * 0.2)
                        GUICtrlSetGraphic($previewa, $GUI_GR_LINE, $x1 * 0.2, $y1 * 0.2)

                        GUICtrlSetGraphic($previewa, $GUI_GR_REFRESH);
                        #cs
                            Local $msg = $cname & ": " & $x1 & "," & $y1 & "," & $x2 & "," & $y2
                            $msg = $msg & @CRLF & ($x1 + $x2) / 2 & " " & ($y1 + $y2) / 2 & " " & $pos[2] & " x " & $pos[3]
                            MsgBox(0, "xy ", $msg);
                        #ce
                    EndIf
                    If Inside($pos, 62, 156) = True Then
                        $Button[$edit][$bid_track] = $hnd
                    ElseIf Inside($pos, 138, 156) = True Then
                        $Button[$edit][$bid_switch3] = $hnd
                    ElseIf Inside($pos, 62, 201) = True Then
                        $Button[$edit][$bid_switch] = $hnd
                    ElseIf Inside($pos, 138, 201) = True Then
                        $Button[$edit][$bid_end] = $hnd
                    ElseIf Inside($pos, 62, 246) = True Then
                        $Button[$edit][$bid_del] = $hnd
                    ElseIf (Inside($pos, 148, 381) = True Or Inside($pos, 100, 381) = True) Then
                        $Button[$edit][$bid_level] = $hnd
                    ElseIf Inside($pos, 62, 436) = True Then
                        $Button[$edit][$bid_obj] = $hnd
                    ElseIf Inside($pos, 62, 488) = True Then
                        $Button[$edit][$bid_copy] = $hnd
                    ElseIf Inside($pos, 150, 479) = True Then
                        $Button[$edit][$bid_left] = $hnd
                    ElseIf Inside($pos, 150, 499) = True Then
                        $Button[$edit][$bid_forward] = $hnd
                    ElseIf Inside($pos, 150, 519) = True Then
                        $Button[$edit][$bid_right] = $hnd
                        ;;				Elseif Inside($pos,96,346)=True then
                        ;;					$button[$edit][$bid_height]=$hnd
                    ElseIf Inside($pos, 68, 519) = True Then
                        $Button[$edit][$bid_inv] = $hnd
                    EndIf
                EndIf
            EndIf
            $i = $i + 1;
        Until Not $hnd
    Else
        ;; buttons in version>=10 identifizieren
        Dim $barray[1][5]
        Local $edit = -1;
        Local $pos;
        $i = 1;
        Do
            ;;$cname = "Button" & $i
            $cname = "[CLASS:Button; INSTANCE:" & $i & "]";
            $hnd = ControlGetHandle($eep, "", $cname);
            ;; msgbox(0,"Button",$cname & " " & $eep & " " & $hnd);
            If $hnd Then
                Local $last = UBound($barray)
                ReDim $barray[$last + 1][5]
                $parent = _WinAPI_GetAncestor($hnd, $GA_PARENT)
                $edit = _ArraySearch($EditorHnd, $parent)
                $text = ControlGetText($eep, "", $hnd)
                $id = Number(_WinAPI_GetDlgCtrlID($hnd))
                $barray[$last][0] = $cname
                $barray[$last][1] = $parent
                $barray[$last][2] = $edit
                $barray[$last][3] = $text
                $barray[$last][4] = $id
                Switch $edit
                    Case 0 ;; track editor
                        Switch $id
                            Case 1033
                                $Button[0][$bid_track] = $hnd
                            Case 1132
                                $Button[0][$bid_switch3] = $hnd
                            Case 1034
                                $Button[0][$bid_switch] = $hnd
                            Case 1133
                                $Button[0][$bid_end] = $hnd
                            Case 1141
                                $Button[0][$bid_del] = $hnd
                            Case 1218
                                $Button[0][$bid_level] = $hnd
                            Case 1369
                                $Button[0][$bid_copy] = $hnd
                            Case 1361
                                $Button[0][$bid_left] = $hnd
                            Case 1181
                                $Button[0][$bid_forward] = $hnd
                            Case 1180
                                $Button[0][$bid_right] = $hnd
                            Case 1505
                                $Button[0][$bid_inv] = $hnd
                        EndSwitch
                    Case 1 ;; tram editor
                        Switch $id
                            Case 1039
                                $Button[1][$bid_track] = $hnd
                            Case 1132
                                $Button[1][$bid_switch3] = $hnd
                            Case 1040
                                $Button[1][$bid_switch] = $hnd
                            Case 1133
                                $Button[1][$bid_end] = $hnd
                            Case 1141
                                $Button[1][$bid_del] = $hnd
                            Case 1218
                                $Button[1][$bid_level] = $hnd
                            Case 1369
                                $Button[1][$bid_copy] = $hnd
                            Case 1361
                                $Button[1][$bid_left] = $hnd
                            Case 1181
                                $Button[1][$bid_forward] = $hnd
                            Case 1180
                                $Button[1][$bid_right] = $hnd
                            Case 1505
                                $Button[1][$bid_inv] = $hnd
                        EndSwitch
                    Case 2 ;; street editor
                        Switch $id
                            Case 1035
                                $Button[2][$bid_track] = $hnd
                            Case 1132
                                $Button[2][$bid_switch3] = $hnd
                            Case 1036
                                $Button[2][$bid_switch] = $hnd
                            Case 1150
                                $Button[2][$bid_end] = $hnd
                            Case 1141
                                $Button[2][$bid_del] = $hnd
                            Case 1218
                                $Button[2][$bid_level] = $hnd
                            Case 1369
                                $Button[2][$bid_copy] = $hnd
                            Case 1361
                                $Button[2][$bid_left] = $hnd
                            Case 1181
                                $Button[2][$bid_forward] = $hnd
                            Case 1180
                                $Button[2][$bid_right] = $hnd
                            Case 1505
                                $Button[2][$bid_inv] = $hnd
                        EndSwitch
                    Case 3 ;; water editor
                        Switch $id
                            Case 1033
                                $Button[3][$bid_track] = $hnd
                            Case 1132
                                $Button[3][$bid_switch3] = $hnd
                            Case 1034
                                $Button[3][$bid_switch] = $hnd
                            Case 1133
                                $Button[3][$bid_end] = $hnd
                            Case 1141
                                $Button[3][$bid_del] = $hnd
                            Case 1218
                                $Button[3][$bid_level] = $hnd
                            Case 1369
                                $Button[3][$bid_copy] = $hnd
                            Case 1361
                                $Button[3][$bid_left] = $hnd
                            Case 1181
                                $Button[3][$bid_forward] = $hnd
                            Case 1180
                                $Button[3][$bid_right] = $hnd
                            Case 1505
                                $Button[3][$bid_inv] = $hnd
                        EndSwitch
                    Case -1 ;; others
                        If $text = "WZ_IMMDEL" Then
                            $Button_Immo_del = $hnd
                        ElseIf $text = "WZ_LEDEL" Then
                            $Button_LE_del = $hnd
                        EndIf

                EndSwitch

            EndIf
            $i = $i + 1;
        Until Not $hnd
        ;; neue id in eigenschaftsfenster
        $id_steigung = 1313
    EndIf
    ;;MsgBox(0,"",$button_immo_del & " " & $button_le_del)
    ;_ArrayDisplay($barray)
    ;_ArrayDisplay($button)
    #cs
        $i = 1;
        Global $actualspeedcontrol
        Global $targetspeedcontrol
        Do
        $cname = "[CLASS:Static;INSTANCE:" & $i & "]"
        $hnd = ControlGetHandle($eep, "", $cname);
        If $hnd Then
        Local $string = ControlGetText($eep, "", $hnd);
        ;; MsgBox(0,"Static " & $i,$string & "  =?=  " & $actualspeed & " =?= " & $targetspeed)
        If StringRegExp($string, $targetspeed) > 0 Then
        $targetspeedcontrol = $hnd
        EndIf
        If StringRegExp($string, $actualspeed) > 0 Then
        $actualspeedcontrol = $hnd
        EndIf
        EndIf
        $i = $i + 1;
        Until Not $hnd

        ;;MsgBox(0,"Controls",$actualspeedcontrol & " " & $targetspeedcontrol)
    #ce

    WinActivate($eep)
    ;;	MsgBox(0, "Debug", "OpenEEP fertig");

EndFunc   ;==>OpenEEP



;; create gui

Global $gui = NGCreate()
Global $tab = NGCreateTab()

$TrackTab = NGCreateTabItem(MsgH("GUI", "TabTrack"))
;;#include "g_track.au3"

Global $davorbutton = NGButton(MsgH("Tracktab", "before"), $NG_LEFT)
Global $danachbutton = NGButton(MsgH("Tracktab", "after"), $NG_RIGHT);
;;Global $agleisdisplay=TrackDataDisplay($NG_RIGHT);
Global $inverse1cb = NGCheckBox(MsgH("Tracktab", "inverse"), $NG_LEFT, False);
Global $null1cb = NGCheckBox(MsgH("Tracktab", "Stub"), $NG_RIGHT, False);

;; Global $davor2posbutton = NGButton("-> object",$NG_LEFT)

;;NGDel($NG_BOTH)

;;Global $egleisdisplay=TrackDataDisplay($NG_RIGHT);
;;Global $inverse2cb = NGCheckBox(MsgH("Tracktab","inverse,$NG_LEFT,False);
;;Global $null2cb = NGCheckBox(MsgH("Tracktab","stub,$NG_LEFT,False);

;; Global $danach2posbutton = NGButton("-> object",$NG_LEFT)

#cs
    NGDel($NG_BOTH)
    Global $agleisdisplay=TrackDataDisplay($NG_LEFT);
    Global $egleisdisplay=TrackDataDisplay($NG_RIGHT);
#ce

Global $invflag = False
Global $nullflag = False

;;Global $inversecb = NGCheckBox(MsgH("Tracktab","inverse,$NG_LEFT,False);
;;Global $nullcb = NGCheckBox(MsgH("Tracktab","stub,$NG_LEFT,False);
NGDel($NG_BOTH)
Global $gleisanzInput = NGInput(MsgH("Tracktab", "Tracks"), $SollGleisAnz, $NG_LEFT, 1);
Global $radinput = NGInput(MsgH("Tracktab", "Rad"), $trackrad, $NG_RIGHT);
If ($mode < 4) Then
    GUICtrlSetState($radinput, $GUI_DISABLE)
EndIf

NGLabel(MsgH("TrackTab", "Construction"), $NG_BOTH)
Global $modecombo = NGCombo($ModeList, $NG_BOTH)
If $mode > 0 And $mode < 6 Then
    NGComboUpdate($modecombo, $ModeList[$mode - 1])
EndIf

;Global $tlen = NGLabel(MsgH("Tracktab","length_unknown,$NG_BOTH)
;Global $trad = NGLabel(MsgH("Tracktab","rad_unknown,$NG_BOTH)
Global $tistanz = NGLabel(MsgH("Tracktab", "TracknumberUnknown"), $NG_BOTH)
Global $tlen = NGLabel(MsgH("Tracktab", "LengthUnknown"), $NG_LEFT)
Global $trad = NGLabel(MsgH("TrackTab", "RadiusUnknown"), $NG_LEFT)

;Global $txx = NGLabel("X: ?",$NG_BOTH)
;Global $tyy = NGLabel("Y: ?",$NG_BOTH)

Global $txx = NGLabel("X: ?", $NG_RIGHT)
Global $tyy = NGLabel("Y: ?", $NG_RIGHT)

NGSpace(5, $NG_LEFT)
Global $PutTrackButton = NGButton(MsgH("TrackTab", "PutTracks"), $NG_LEFT);

Global $levelcb = NGCheckBox(MsgH("Tracktab", "Levelling"), $NG_RIGHT, $level);
Global $copycb = NGCheckBox(MsgH("Tracktab", "2tracks"), $NG_RIGHT, $copy);

Global $dxinput = NGInput(MsgH("Tracktab", "ShiftX"), $track_shift_x, $NG_BOTH);
Global $dhinput = NGInput(MsgH("Tracktab", "ShiftH"), $track_shift_h, $NG_BOTH);

Global $samftcb = NGCheckBox(MsgH("Tracktab", "Sanft"), $NG_BOTH, False)
Global $transinput = NGInput(MsgH("Tracktab", "Transition"), $track_trans, $NG_BOTH)
Global $shortinput = NGInput(MsgH("Tracktab", "Short"), $track_short, $NG_BOTH)

#cs
    $CombiTab = NGCreateTabItem(MsgH("GUI", "TabCombi"));
    ;;#include "g_combi.au3"

    ;; tab für gleiskombinationen
    ;; new Buttons... for position, but track handlers are used
    Global $csposbutton = NGButton(MsgH("Combitab", "getpos"), $NG_LEFT)
    Global $csinverse1cb = NGCheckBox(MsgH("Tracktab", "inverse"), $NG_RIGHT, False);
    Global $csnull1cb = NGCheckBox(MsgH("Tracktab", "Stub"), $NG_RIGHT, False);

    ;;Global $csposbutton = NGButton($mtext_cs_getpos,$NG_LEFT)

    Global $combidata = combidatadisplay($NG_BOTH)

    NGDel($NG_BOTH, $SS_BLACKFRAME, 10)

    Global $csDir0 = NGCheckBox(MsgH("CombiTab", "Dir0"), $NG_LEFT, True)
    Global $csDir1 = NGCheckBox(MsgH("CombiTab", "Dir1"), $NG_LEFT, True)
    Global $csDir2 = NGCheckBox(MsgH("CombiTab", "Dir2"), $NG_LEFT, True)
    Global $csDir3 = NGCheckBox(MsgH("CombiTab", "Dir3"), $NG_RIGHT, True)
    Global $csDir4 = NGCheckBox(MsgH("CombiTab", "Dir4"), $NG_RIGHT, True)
    Global $csDir5 = NGCheckBox(MsgH("CombiTab", "Dir5"), $NG_RIGHT, True)

    NGSpace(10, $NG_BOTH)

    Global $csupbutton = NGButton(MsgH("CombiTab", "Up"), $NG_BOTH, 0);
    Global $csrightbutton = NGButton(MsgH("CombiTab", "Right"), $NG_RIGHT, 1);
    Global $csleftbutton = NGButton(MsgH("CombiTab", "Left"), $NG_LEFT, 3);
    Global $csdownbutton = NGButton(MsgH("CombiTab", "Down"), $NG_BOTH, 2);

    NGSpace(10, $NG_BOTH)

    Global $csLenInput = NGInput(MsgH("CombiTab", "Length"), $cslen, $NG_BOTH);
    Global $csWidthInput = NGInput(MsgH("CombiTab", "Width"), $cswidth, $NG_BOTH);

    ;;MsgBox(0,"iii",$csleninput & " " & $cswidthinput)

    ;;NGDel($NG_BOTH,$SS_BLACKFRAME,20)

    Global $cssetbutton = NGButton(MsgH("CombiTab", "Set"), $NG_LEFT);
#ce

$Track2Tab = NGCreateTabItem(MsgH("GUI", "TabTrack2"));
;;#include "g_track2.au3"

;; tab für gleistools 2
#cs
    Global $egalinput = NGInput(MsgH("Tracktab", "Height"), 0, $NG_LEFT);
    Global $egalbutton = NGButton(MsgH("Tracktab", "SetHeight"), $NG_LEFT);

    Global $egalrelcb = NGCheckBox(MsgH("Tracktab", "HeightRel"), $NG_RIGHT, $egalRel);
    Global $egallevelcb = NGCheckBox(MsgH("Tracktab", "Levelling"), $NG_RIGHT, $egallevel);

    NGDel($NG_BOTH, $SS_BLACKFRAME, 20)
#ce
Global $replacebutton = NGButton(MsgH("Tracktab", "Replace"), $NG_LEFT);
Global $replaceinversecb = NGCheckBox(MsgH("Tracktab", "ReplaceInverse"), $NG_LEFT, False);

Global $dx2input = NGInput(MsgH("Tracktab", "ShiftX"), $track2_shift_x, $NG_BOTH);
Global $dh2input = NGInput(MsgH("Tracktab", "ShiftH"), $track2_shift_h, $NG_BOTH);

Global $replaceremovecb = NGCheckBox(MsgH("Tracktab", "ReplaceRemove"), $NG_LEFT, True);

Global $replacechangeeditorcb = NGCheckBox(MsgH("Tracktab", "ReplaceChangeEditor"), $NG_LEFT, False);
Global $replaceeditorcombo = NGCombo($TrackEditorList, $NG_BOTH)
NGComboUpdate($replaceeditorcombo, $editor_track)

$ImmoTab = NGCreateTabItem(MsgH("GUI", "TabImmo"));
;;#include "g_immo.au3"
$getposbutton = NGButton(MsgH("ImmoTab", "GetPos"))

NGDel($NG_BOTH);
;;NGSpace(10,$NG_BOTH)

$immodata = immodatadisplay($NG_BOTH);

NGDel($NG_BOTH);
;;NGSpace(10,$NG_BOTH)

$shiftxinput = NGInput(MsgH("ImmoTab", "DeltaX"), $ShiftX);

$shiftxpcb = NGCheckBox(MsgH("ImmoTab", "Right"), $NG_RIGHT, $doShiftXp);
$shiftxmcb = NGCheckBox(MsgH("ImmoTab", "Left"), $NG_RIGHT, $doShiftXm);

NGSpace(5, $NG_BOTH)

$shiftyinput = NGInput(MsgH("ImmoTab", "DeltaY"), $ShiftY);

$shiftypcb = NGCheckBox(MsgH("ImmoTab", "Up"), $NG_RIGHT, $doShiftYp);
$shiftymcb = NGCheckBox(MsgH("ImmoTab", "Down"), $NG_RIGHT, $doShiftYm);

NGSpace(5, $NG_BOTH)

$setposbutton = NGButton(MsgH("ImmoTab", "SetPos"));
$hrelcb = NGCheckBox(MsgH("ImmoTab", "HightRel"), $NG_RIGHT, $hrel);

$save_as_default_cb = NGCheckBox(MsgH("ImmoTab", "AsDefault"), $NG_RIGHT, False);


$TTTab = NGCreateTabItem(MsgH("GUI", "TabTT"));
;;#include "g_timetable.au3"
;; tab für fahrplan

Local $label = $tt_file
If StringLen($label) > 35 Then
    $label = "..." & StringRight($tt_file, 32)
EndIf

Global $lbl_tt = NGLabel($label, $NG_BOTH, $SS_CENTER)
;;Global $cb_ttEnable = NGCheckBox("grafischer Fahrplan", $NG_BOTH, False)
Global $lbl_halt = NGLabel(MsgH("TimeTable", "laststop"), $NG_BOTH)
Global $lbl_start = NGLabel(MsgH("TimeTable", "laststart"), $NG_BOTH)
;;Global $lbl_current = NGLabel("**", $NG_BOTH)
;;Global $lbl_last = NGLabel("**",$NG_BOTH)

Local $dummy = MsgH("TimeTable", "routes")
$tt_route = NGCombo($dummy, $NG_BOTH)

Global $tt_item
;;Global $tt_selected_route = 1

Global $list_tt = NGList(MsgH("TimeTable", "ListHead"), $tt_item, $NG_BOTH, 25)
If UBound($tt_plan) > 0 Then
    UpdatePlan($tt_item, $tt_plan, $tt_selected_route, -1)
EndIf

Global $tt_edit = NGButton(MsgH("TimeTable", "edit"), $NG_LEFT);
Global $tt_menu = NGButton(MsgH("TimeTable", "menu"), $NG_RIGHT)
Global $tt_set_arrival = NGButton(MsgH("TimeTable", "setarrival"), $NG_LEFT);
Global $tt_set_departure = NGButton(MsgH("TimeTable", "setdeparture"), $NG_RIGHT)

Global $tt_shift_times_cb = NGCheckBox(MsgH("TimeTable", "shiftTimes"), $NG_BOTH, 0)

Global $tt_create_plan_button
Global $tt_delete_button
Global $tt_insert_button
Global $tt_delete_route_button
Global $tt_new_route_button
Global $tt_edit_route_button
Global $tt_close_button
Global $tt_submenu = 0

$SignalTab = NGCreateTabItem(MsgH("GUI", "TabSignal"));
;;#include "g_sign.au3"
;; tab für signaltool

Global $signbutton1 = NGButton($mtext_signal_button1, $NG_BOTH);
Global $signbutton2 = NGButton($mtext_signal_button2, $NG_BOTH);
Global $signbutton3 = NGButton($mtext_signal_button3, $NG_BOTH);
Global $signbutton4 = NGButton($mtext_signal_button4, $NG_BOTH);


$OptionTab = NGCreateTabItem(MsgH("GUI", "TabOption"));

;;#include "g_option.au3"
;; NGLabel($mtext_general_options,$NG_BOTH)

;; create version label
;; handle is used to activate eep (via hotkey)
Global $activate_eep = NGLabel("V. " & $Version, $NG_BOTH, $SS_CENTER + $SS_SUNKEN);
NGDel($NG_BOTH, $SS_BLACKFRAME, 5);

WinSetTitle($gui, "", $PName & " " & $Version)

Global $auto_ok_cb = NGCheckBox(MsgH("GUI", "AutoOK"), $NG_BOTH, BitTest($auto_ok, 1));
If $EEPVersion = 7 Then
    Global $raster_ok_cb = NGCheckBox(MsgH("GUI", "RasterOK"), $NG_BOTH, BitTest($auto_ok, 2));
Else
    Global $raster_ok_cb = $auto_ok_cb
EndIf

NGDel($NG_BOTH, $SS_BLACKFRAME, 5);

Global $auto_val_cb = NGCheckBox(MsgH("ImmoTab", "AutoValue"), $NG_BOTH, $auto_val);

NGDel($NG_BOTH, $SS_BLACKFRAME, 5);

NGLabel(MsgH("GUI", "Clock"), $NG_BOTH)

GUIStartGroup()
Global $clock_start_stop_rad = NGRadio(MsgH("Clock", "StartStopMode"), $NG_LEFT, $clockmode == "start_stop")
Global $clock_start_cont_rad = NGRadio(MsgH("Clock", "StartContMode"), $NG_LEFT, $clockmode == "start_cont")
Global $clock_lap_rad = NGRadio(MsgH("Clock", "LapMode"), $NG_RIGHT, $clockmode == "lap")
Global $clock_life_rad = NGRadio(MsgH("Clock", "LifeMode"), $NG_RIGHT, $clockmode == "life")

NGSpace(5, $NG_BOTH)
;;Func NGInput($text, $itext, $where = $NG_LEFT, $pm = 0)

Global $clock_modulo_input = NGInput(MsgH("Clock", "Cycle"), $clockmodulo, $NG_LEFT)

NGSpace(5, $NG_BOTH)

GUIStartGroup()

Global $clock_hmsmode_cb = NGCheckBox("hh:mm:ss", $NG_BOTH, $clockdmode == "hms")

;;NGSpace(5, $NG_BOTH)

NGDel($NG_BOTH)

Global $winposlabel = NGLabel(MsgH("Options", "WindowPosition"), $NG_BOTH)
Global $winposbutton = NGButton(MsgH("Options", "SaveWindowPosition"), $NG_LEFT)

NGDel($NG_BOTH)

Global $speedloglabel = NGLabel(MsgH("Options", "SpeedLog"), $NG_BOTH)
GUIStartGroup()
Global $speedlog2 = NGRadio(MsgH("Options", "2min"), $NG_LEFT, $LogStep == 1)
Global $speedlog4 = NGRadio(MsgH("Options", "4min"), $NG_LEFT, $LogStep == 2)
Global $speedlog8 = NGRadio(MsgH("Options", "8min"), $NG_RIGHT, $LogStep == 4)
Global $speedlog16 = NGRadio(MsgH("Options", "16min"), $NG_RIGHT, $LogStep == 8)


NGCreateTabItem("");

$previewa = NGGraphic($NG_BOTH)

Global $clock = NGLabel("HH:MM:SS", $NG_BOTH, $SS_CENTER, 2)
;; GUICtrlSetFont (controlID, size [, weight [, attribute [, fontname[, quality]]]] )

;; Global $testlabel = NGLabel("TEST",$NG_BOTH)

Global $clockbutton = NGButton(MsgH("Clock", "Start"), $NG_LEFT)
Global $clock_reset_button = NGButton(MsgH("Clock", "Reset"), $NG_RIGHT)

SetClockMode($clockmode)

;; handle of delimiter "misused" to activate hugo (via hotkey)
Global $activate_hugo = NGDel($NG_BOTH, $SS_BLACKFRAME, 15)
Global $quitbutton = NGButton(MsgH("GUI", "Quit"), $NG_BOTH)

;;NGSetAccelerators()

GUISetState(@SW_SHOW)

;; hotkeys must be initialized _after_ GUI was created
;;#include "f_hotkey.au3"
;; f_hotkey

;; Zuordnung Key <-> Msg
;; autoit kann arrays der Länge 0 nicht anlegen (?), deshalb dummyeintrag
Global $keylist[1] = [""]
Global $keymsglist[1] = [""]

Func HotKeyDispatcher()
    ;; bearbeitet alle Hugo-Hotkeys
    If UBound($keylist) > 0 Then
        Local $kidx = _ArrayBinarySearch($keylist, @HotKeyPressed)
        ;; MsgBox(0,"HotKey",@HotKeyPressed & " " & $kidx,5)
        If $kidx >= 0 Then
            $msg = $keymsglist[$kidx]
        EndIf
    EndIf
EndFunc   ;==>HotKeyDispatcher

Global $hotkeyactive = 0

Func HotkeysOn()
    Local $key
    If $hotkeyactive == 0 Then
        For $key In $keylist
            HotKeySet($key, "HotKeyDispatcher")
        Next
        $hotkeyactive = 1
    EndIf
EndFunc   ;==>HotkeysOn

Func HotkeysOff()
    Local $key
    If $hotkeyactive > 0 Then
        For $key In $keylist
            HotKeySet($key)
        Next
        $hotkeyactive = 0
    EndIf
EndFunc   ;==>HotkeysOff

#cs
    ;; variante mit Gleiskombination
    ;; Listen zur Zuordnung action(string) <-> msg
    Local $actionmsglist[48] = [$clockbutton, _
    $davorbutton, $danachbutton, $PutTrackButton, _
    $egalbutton, $replacebutton, _
    $getposbutton, $setposbutton, _
    $cssetbutton, _
    $inverse1cb, $null1cb, _
    $clock_start_stop_rad, $clock_start_cont_rad, $clock_lap_rad, _
    $clock_reset_button, _
    $signbutton1, $signbutton2, $signbutton3, $signbutton4, _
    $TrackTab, $Track2Tab, $ImmoTab, $SignalTab, $OptionTab, $CombiTab, _
    $tt_set_arrival, $tt_set_departure, _
    $activate_hugo, $activate_eep, _
    $quitbutton]

    Global $actionlist[48] = ["clock", _
    "before", "after", "puttrack", _
    "setheight", "replacetrack", _
    "getobject", "setobject", "setcombi", _
    "inverse", "null", _
    "clockstartstop", "clockstartcont", "clocklap", _
    "clockreset", _
    "signal1", "signal2", "signal3", "signal4", _
    "tabtrack", "tabtrack2", "tabobject", "tabsignal", "taboptions", "tabcombi", _
    "setarrival", "setdeparture", _
    "activatehugo", "activateeep", _
    "quit"]
#ce

Local $actionmsglist[48] = [$clockbutton, _
        $davorbutton, $danachbutton, $PutTrackButton, _
        $replacebutton, _
        $getposbutton, $setposbutton, _
        $inverse1cb, $null1cb, _
        $clock_start_stop_rad, $clock_start_cont_rad, $clock_lap_rad, _
        $clock_reset_button, _
        $signbutton1, $signbutton2, $signbutton3, $signbutton4, _
        $TrackTab, $Track2Tab, $ImmoTab, $SignalTab, $OptionTab, $CombiTab, _
        $tt_set_arrival, $tt_set_departure, _
        $activate_hugo, $activate_eep, _
        $quitbutton]

Global $actionlist[48] = ["clock", _
        "before", "after", "puttrack", _
        "replacetrack", _
        "getobject", "setobject", _
        "inverse", "null", _
        "clockstartstop", "clockstartcont", "clocklap", _
        "clockreset", _
        "signal1", "signal2", "signal3", "signal4", _
        "tabtrack", "tabtrack2", "tabobject", "tabsignal", "taboptions", "tabcombi", _
        "setarrival", "setdeparture", _
        "activatehugo", "activateeep", _
        "quit"]

;; hotkeystrings anhand $keydefstring initialisieren

Local $keydefarray = StringSplit($keydefstring, "|", 2)

;; Sortieren für schnelle Suche mit _ArrayBinarySearch
_ArraySort($keydefarray)

For $def In $keydefarray
    ;;MsgBox(0,$def,$def)
    If $def <> "" Then ;; ignore empty strings

        Local $defarray = StringSplit($def, ":")

        If $defarray[0] <> 2 Then
            Warning(MsgH("GUI", "wrongHotkey") & ": " & $def)
        Else
            Local $aidx = _ArraySearch($actionlist, $defarray[2])
            If $aidx < 0 Then
                Warning(MsgH("GUI", "wrongAction") & ": " & $def)
            Else
                ;; OK - alles setzen
                Local $keycode = $defarray[1]
                If StringLen($keycode) < 1 Or StringLen($keycode) > 2 Then
                    Warning(MsgH("GUI", "wrongHotkey") & ": " & $def)
                Else
                    If $keylist[0] = "" Then
                        ;; erster Eintrag überschreibt dummy
                        $keylist[0] = $keycode
                        $keymsglist[0] = $actionmsglist[$aidx]
                    Else
                        ;; an Liste anhängen
                        _ArrayAdd($keylist, $keycode)
                        _ArrayAdd($keymsglist, $actionmsglist[$aidx])
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
Next
;;_ArrayDisplay($keylist)


;; EEP starten
OpenEEP();

#cs
    Local $avChildren
    WinListChildren($eep, $avChildren)
    _ArrayDisplay($avChildren)
#ce

;; grafic timetable not active
$gtimetable = $eep

;; Größen an Bildschirm anpassen
$ScreenSize = WinGetPos("Program Manager")

If ValidWindowPos($eeppos) Then
    WinMove($eep, "", $eepleft, $eeptop, $eepwidth, $eepheight, 10)
EndIf

WinActivate($eep)

SetTab($TrackTab)

SpeedlogReset()

HotkeysOn()

Do
    If TimerDiff($begin) > 1000 Then

        ;; dynamic activation/deactivation of hotkeys
        ;; does not work correctly, if subwindows (of eep) are active!
        #cs
            ;; check if hotkeys must be activated
            If (WinActive($eep) Or WinActive($gui)) Then
            HotkeysOn()
            Else
            HotkeysOff()
            EndIf
        #ce

        ;; Editor ermitteln, GUI anpassen
        $editor = GetEditor()
        If $editor <> $oldeditor Then
            SetEditorVars($editor)
            $oldeditor = $editor
            $DisplayNeedsRedraw = 1
        EndIf

        ;; clock / stopwatch
        $CurrentTime = GetTime()
        $CurrentTimeMod = $CurrentTime
        If $clockmode == "life" Then
            If $clockmodulo > 0 Then
                $CurrentTimeMod = Mod($CurrentTime, $clockmodulo)
            EndIf
        EndIf
        GUICtrlSetData($clock, ClockString($CurrentTimeMod))

        Global $speedvalid
        Global $targetspeedval
        Global $actualspeedval
        Global $lastspeed

        ;; Fahrtenschreiber
        If $editor < 0 Then
            $DisplayStat = $SpeedDisplay
            Global $delta_t = $CurrentTime - $lasttime
            If ($delta_t <> 0) Then

                GetSpeed($speedvalid, $targetspeedval, $actualspeedval)
                If $speedvalid > 0 Then
                    If $lastspeed == 0 And $actualspeedval > 0 Then ;; start
                        GUICtrlSetData($lbl_start, MsgH("TimeTable", "laststart") & " " & ClockString($CurrentTimeMod))
                    Else
                        If $lastspeed > 0 And $actualspeedval == 0 Then ;; halt
                            GUICtrlSetData($lbl_halt, MsgH("TimeTable", "laststop") & " " & ClockString($CurrentTimeMod))
                        EndIf
                    EndIf
                    ;;GUICtrlSetData($lbl_current, $actualspeedval)
                    ;;GUICtrlSetData($lbl_last, $lastspeed)
                    $lastspeed = $actualspeedval
                    ;; speedlog
                    If $delta_t > 0 And $delta_t < 100 Then ;; sinnvolle Zeitschritte? (100 ist gross mit Rücksicht auf Zeitfaktor in EEP)
                        $logcount = $logcount + 1
                        If $logcount >= $LogStep Then
                            $logcount = 0

                            $speed[$LastIndex] = $actualspeedval
                            $sspeed[$LastIndex] = $targetspeedval

                            $LastIndex = Mod($LastIndex + 1, $SpeedLogSize)

                            ;;DrawSpeed($previewa,$speed,$sspeed,$lastindex);
                            $DisplayNeedsRedraw = 1

                        EndIf
                    Else
                        ;; Zeitsprung!!, log löschen
                        SpeedlogReset()
                    EndIf
                    $lasttime = $CurrentTime;
                EndIf
            EndIf

        Else
            If $DisplayStat == $SpeedDisplay Then
                $DisplayStat = $LastDisplay
            EndIf
        EndIf

        ;; Berechnung notwendig?
        If $calculated = False Then

            ;; Gleisdaten ungültig
            GUICtrlSetColor($tistanz, 0xff0000)
            GUICtrlSetColor($tlen, 0xff0000)
            GUICtrlSetColor($trad, 0xff0000)

            GUICtrlSetData($tlen, MsgH("GUI", "Please"))
            GUICtrlSetData($trad, MsgH("GUI", "Wait"))

            $trackstatus = Optimize($StartGleis, $EndGleis, $Verbindung, $mode)
            ;; trackstatus < 0 = Berechnung fehlgeschlagen

            $calculated = True

            If $trackstatus > 0 Then
                ;; erfolgreiche Berechnung, jetzt test auf Eignung für EEP
                ;; Status 1 = OK
                ;; Status > 1 = Grenzwerte überschritten
                $trackstatus = isValid($Verbindung)
            EndIf
            If $DisplayStat == $TrackDisplay Then
                $DisplayNeedsRedraw = 1 ; Display als ungültig erklären
            EndIf

            ;; Text-Darstellung
            If $trackstatus > 0 Then
                ;; es existieren Daten
                If $trackstatus = 1 Then
                    ;; für EEP gültige Gleisdaten1
                    GUICtrlSetColor($tistanz, 0x000000)
                    GUICtrlSetColor($tlen, 0x000000)
                    GUICtrlSetColor($trad, 0x000000)
                Else
                    GUICtrlSetColor($tistanz, 0xFF8800)
                    GUICtrlSetColor($tlen, 0xFF8800)
                    GUICtrlSetColor($trad, 0xFF8800)
                EndIf

                GUICtrlSetData($tistanz, StringFormat(MsgH("Tracktab", "TrackNumber"), $istgleisanz))

                If $minlen == $maxlen Then
                    GUICtrlSetData($tlen, StringFormat(MsgH("Tracktab", "LengthIs"), $minlen))
                Else
                    GUICtrlSetData($tlen, StringFormat(MsgH("TrackTab", "LengthRange"), $minlen, $maxlen))
                EndIf
                GUICtrlSetData($trad, StringFormat(MsgH("TrackTab", "RadiusIs"), $minrad))
                GUICtrlSetData($txx, StringFormat("X: %5.0f .. %5.0f", $minx, $maxx))
                GUICtrlSetData($tyy, StringFormat("Y: %5.0f .. %5.0f", $miny, $maxy))

            Else
                ;; keine Gleisdaten
                GUICtrlSetData($tistanz, StringFormat(MsgH("Tracktab", "TrackNumber"), $istgleisanz))
                GUICtrlSetData($tlen, MsgH("Tracktab", "LengthUnknown"))
                GUICtrlSetData($trad, MsgH("Tracktab", "RadiusUnknown"))
            EndIf
        EndIf

        If $DisplayNeedsRedraw Then
            If $DisplayStat <> $SpeedDisplay Then
                $LastDisplay = $DisplayStat
            EndIf

            Switch $DisplayStat
                Case $TrackDisplay
                    If $trackstatus > 0 Then
                        DrawGleis($previewa, $StartGleis, $Verbindung, $istgleisanz, $EndGleis)
                    Else
                        DrawGleis($previewa, $StartGleis, $Verbindung, 0, $EndGleis)
                    EndIf
                Case $CombiDisplay
                    DrawCombi($previewa)

                Case $ImmoDisplay
                    DrawImmo($previewa, $ImmoPos1)
                Case $SpeedDisplay
                    DrawSpeed($previewa, $speed, $sspeed, $LastIndex)
            EndSwitch
            $DisplayNeedsRedraw = 0
        EndIf

        If (Not WinExists($eep)) Then
            $msg = $GUI_EVENT_CLOSE
        EndIf

        ;; automization
        AutoOK()

        $begin = TimerInit()
    EndIf;; // Time

    ;; gui event ?
    If (Not $msg) Then
        $msg = GUIGetMsg()
    EndIf

    If $msg <> 0 Then

        #cs
            if $msg>0 Then
            GUICtrlSetData($testlabel,$msg)
            EndIf
        #ce
        Switch $msg

            ;; handler for events of different tools

            ;;			#include "h_track.au3"
            Case $davorbutton, $csposbutton
                If $trackeditoridx >= 0 Then
                    If GetTrackData($StartGleis, GUICtrlRead($null1cb) == $GUI_CHECKED) Then

                        If GUICtrlRead($null1cb) == $GUI_CHECKED Then
                            SetLenToNull($StartGleis)
                        Else
                            If GUICtrlRead($inverse1cb) == $GUI_CHECKED Then
                                InvertiereGleis($StartGleis);
                            EndIf
                        EndIf

                        ResetFlags()

                        GUICtrlSetTip($davorbutton, trackdatastring($StartGleis))

                        ;; Verschiebung rücksetzen
                        $track_shift_x = 0
                        $track_shift_h = 0
                        GUICtrlSetData($dxinput, $track_shift_x)
                        GUICtrlSetData($dhinput, $track_shift_h)

                        ;; Set object position too
                        Track2Immo($StartGleis, $ImmoPos1)
                        $iValid = True;
                        showimmodata($immodata, $ImmoPos1);
                        #cs
                            ;; set combination position from end of $StartGleis
                            $csx = $StartGleis[$ixe]
                            $csy = $StartGleis[$iye]
                            $csdir = $StartGleis[$idir] + $StartGleis[$iangle]
                            $csh1 = $StartGleis[$ieh2]
                            Local $csgrad = $StartGleis[$igrad]
                            $csdhx = CosD($csdir) * ($csgrad)
                            $csdhy = SinD($csdir) * ($csgrad)
                            ;;MsgBox(0,"Anstieg","dhx: " & $csdhx & " dhy: " & $csdhy)

                            For $i = 0 To 4
                            For $j = 0 To 4
                            $csOld[$j][$i] = 0
                            Next
                            Next
                            showcombidata($combidata)
                        #ce
                        $calculated = False
                        $DisplayNeedsRedraw = 1
                    EndIf
                Else
                    Error(MsgH("EEP", "no_track_editor"))
                EndIf

            Case $danachbutton
                SetTab($TrackTab)
                If $trackeditoridx >= 0 Then
                    If GetTrackData($EndGleis, GUICtrlRead($null1cb) == $GUI_CHECKED) Then
                        If GUICtrlRead($null1cb) == $GUI_CHECKED Then
                            SetLenToNull($EndGleis)
                            InvertiereGleis($EndGleis)
                        Else
                            If GUICtrlRead($inverse1cb) == $GUI_CHECKED Then
                                InvertiereGleis($EndGleis);
                            EndIf
                        EndIf

                        GUICtrlSetTip($danachbutton, trackdatastring($EndGleis))

                        ResetFlags()

                        ;; Verschiebung rücksetzen
                        $track_shift_x = 0
                        $track_shift_h = 0
                        GUICtrlSetData($dxinput, $track_shift_x)
                        GUICtrlSetData($dhinput, $track_shift_h)

                        $calculated = False
                    EndIf
                Else
                    Error(MsgH("EEP", "no_track_editor"))
                EndIf

            Case $PutTrackButton
                SetTab($TrackTab)
                If $trackeditoridx >= 0 Then
                    If $calculated Then
                        If $trackstatus == 1 Then
                            WinActivate($eep)
                            For $gnr = $istgleisanz - 1 To 0 Step -1

                                Local $gleis[$TrackDataLen]
                                CopyTrackFromArray($Verbindung, $gnr, $gleis)

                                If $track_shift_x <> 0 Or $track_shift_h <> 0 Then
                                    VerschiebeGleis($gleis, $track_shift_x, $track_shift_h)
                                EndIf

                                If PutTrack($gleis, 1) == False Then
                                    ExitLoop
                                EndIf

                                If $level == True Then
                                    ControlClick($eep, "", $Button[$trackeditoridx][$bid_level]) ; planieren !
                                    Sleep(200)
                                EndIf

                                If $copy == True Then
                                    ControlCommand($eep, "", $Button[$trackeditoridx][$bid_inv], "check"); umkehren
                                    ControlClick($eep, "", $Button[$trackeditoridx][$bid_left]) ; links
                                    ControlClick($eep, "", $Button[$trackeditoridx][$bid_copy]) ; kopieren!
                                    Sleep(200)
                                    If $level == True Then
                                        ControlClick($eep, "", $Button[$trackeditoridx][$bid_level]) ; planieren !
                                        Sleep(200)
                                    EndIf
                                EndIf
                            Next
                        Else ;; not valid
                            If $maxlen > 100 Then
                                Error(MsgH("EEP", "track_too_long") & $maxlen & " m!" & @CRLF & MsgH("EEP", "track_too_long2"));
                            Else
                                If $minlen < 1 Then
                                    Error(MsgH("EEP", "track_too_short") & $minlen & " m!" & @CRLF & MsgH("EEP", "track_too_short2"));
                                EndIf
                            EndIf
                        EndIf; // $valid
                    EndIf ; $calculated
                Else
                    Error(MsgH("EEP", "no_track_editor"))
                EndIf

            Case $gleisanzInput
                $SollGleisAnz = Int(GUICtrlRead($gleisanzInput))

                If $SollGleisAnz > $MaxGleise Then
                    $SollGleisAnz = $MaxGleise
                Else
                    If $SollGleisAnz < 2 Then
                        $SollGleisAnz = 2
                    EndIf
                EndIf

                $calculated = False
                GUICtrlSetData($gleisanzInput, $SollGleisAnz)

            Case $copycb
                $copy = GUICtrlRead($copycb) == $GUI_CHECKED

            Case $levelcb
                $level = GUICtrlRead($levelcb) == $GUI_CHECKED

            Case $samftcb
                If GUICtrlRead($samftcb) == $GUI_CHECKED Then
                    $samft = 1
                Else
                    $samft = 0
                EndIf


            Case $inverse1cb, $csinverse1cb
                $invflag = Not $invflag
                SetFlags()

            Case $null1cb, $csnull1cb
                $nullflag = Not $nullflag
                SetFlags()

            Case $modecombo
                Local $stat = ControlCommand($gui, "", $modecombo, "GetCurrentSelection")
                Local $mode = ControlCommand($gui, "", $modecombo, "FindString", $stat) + 1;
                If ($mode < 4) Then
                    GUICtrlSetState($radinput, $GUI_DISABLE)
                Else
                    GUICtrlSetState($radinput, $GUI_ENABLE)
                EndIf
                If ($mode > 2) Then
                    GUICtrlSetState($gleisanzInput, $GUI_DISABLE)
                Else
                    GUICtrlSetState($gleisanzInput, $GUI_ENABLE)
                EndIf
                $calculated = False

            Case $samftcb
                $calculated = False

            Case $radinput
                InputNumber($radinput, $trackrad)
                $calculated = False

            Case $dxinput
                InputNumber($dxinput, $track_shift_x)

            Case $dhinput
                InputNumber($dhinput, $track_shift_h)

            Case $transinput
                InputNumber($transinput, $track_trans)
                $calculated = False

            Case $shortinput
                InputNumber($shortinput, $track_short)
                $calculated = False


                ;;			#include "h_track2.au3"
                ;; gleistools zweiter Tab
                #cs
                    Case $egallevelcb
                    $egallevel = GUICtrlRead($egallevelcb) == $GUI_CHECKED

                    Case $egalrelcb
                    $egalRel = GUICtrlRead($egalrelcb) == $GUI_CHECKED

                    Case $egalinput
                    $egalHeight = GUICtrlRead($egalinput)
                    GUICtrlSetData($egalinput, $egalHeight)

                    Case $egalbutton
                    ;; MsgBox(0,"Setzen","Setze auf " & $egalheight & " rel=" & $egalrel & " level=" & $egallevel,5);

                    If $trackeditoridx >= 0 Then
                    Local $Trackdata[$TrackDataLen]
                    If GetTrackData($Trackdata, False) Then
                    If GUICtrlRead($egalrelcb) == $GUI_CHECKED Then
                    $Trackdata[$ih1] += $egalHeight
                    Else
                    $Trackdata[$ih1] = $egalHeight
                    EndIf
                    ErgaenzeGleis($Trackdata)
                    SetTrack($Trackdata)
                    If $egallevel Then
                    Sleep(100)
                    ControlClick($eep, "", $Button[$trackeditoridx][$bid_level]) ; planieren !
                    EndIf
                    EndIf
                    Else
                    Error(MsgH("EEP", "no_track_editor"))
                    EndIf
                #ce
            Case $dx2input
                InputNumber($dx2input, $track2_shift_x)

            Case $dh2input
                InputNumber($dh2input, $track2_shift_h)

            Case $replacebutton
                If $trackeditoridx >= 0 Then
                    Local $Trackdata[$TrackDataLen]
                    Local $remove = GUICtrlRead($replaceremovecb) == $GUI_CHECKED
                    If GetTrackData($Trackdata, $remove) Then
                        If $track2_shift_x <> 0 Or $track2_shift_h <> 0 Then
                            VerschiebeGleis($Trackdata, $track2_shift_x, $track2_shift_h)
                        EndIf

                        If GUICtrlRead($replaceinversecb) == $GUI_CHECKED Then
                            InvertiereGleis($Trackdata)
                        EndIf

                        Local $myoldeditor = $editor

                        If GUICtrlRead($replacechangeeditorcb) == $GUI_CHECKED Then
                            ;; Local $ceditor=GUICtrlRead($replaceeditorcombo)
                            Local $stat = ControlCommand($gui, "", $replaceeditorcombo, "GetCurrentSelection")
                            Local $sel = ControlCommand($gui, "", $replaceeditorcombo, "FindString", $stat);

                            ; MsgBox(0,"Editor",$stat & "  " & $sel);
                            SetEditor($sel + 6)
                            $editor = $sel + 6
                        EndIf
                        PutTrack($Trackdata, 1)
                        If $myoldeditor <> $editor Then
                            SetEditor($myoldeditor)
                            $editor = $myoldeditor
                        EndIf

                    EndIf
                Else
                    Error(MsgH("EEP", "no_track_editor"))
                EndIf
                ;;			#include "h_timetable.au3"

            Case $lbl_tt
                Local $temp = OpenTimeTable()
                If $temp <> "<undefined>" Then
                    If FileExists($temp) Then
                        Local $attrib = FileGetAttrib($temp)
                        ;;MsgBox(0,"Attrib",$temp & " -> " & $attrib)
                        If StringInStr($attrib, "D") == 0 Then
                            ;;MsgBox(0,"file",$attrib)
                            $tt_file = $temp
                        Else
                            $tt_file = "<undefined>"
                        EndIf

                    Else
                        $tt_file = "<undefined>"
                    EndIf
                EndIf

                Local $label = $tt_file
                If StringLen($label) > 35 Then
                    $label = "..." & StringRight($tt_file, 32)
                EndIf

                GUICtrlSetData($lbl_tt, $label)

                If $tt_file <> "<undefined>" Then
                    ReadPlan($tt_file, $tt_plan)

                    $tt_selected_route = 1
                    UpdatePlan($tt_item, $tt_plan, $tt_selected_route, -1)
                EndIf

            Case $tt_route
                Local $tt_route_stat = ControlCommand($gui, "", $tt_route, "GetCurrentSelection")
                Local $tt_selected_route = ControlCommand($gui, "", $tt_route, "FindString", $tt_route_stat) + 1;
                UpdatePlan($tt_item, $tt_plan, $tt_selected_route, 0)
                _GUICtrlListView_SetItemSelected($list_tt, 0, 1, 1)

            Case $tt_edit
                ;		MsgBox(0, "listview item", GUICtrlRead(GUICtrlRead($list_tt)), 2)
                Local $selected_item = GUICtrlRead($list_tt)
                If $selected_item <> 0 Then
                    $selected_item = _ArraySearch($tt_item, $selected_item)
                    If editEntry($tt_plan, $tt_selected_route, $selected_item) > 0 Then
                        UpdatePlan($tt_item, $tt_plan, $tt_selected_route, $selected_item - 1)
                        WritePlan($tt_file, $tt_plan)
                    EndIf
                EndIf

            Case $tt_set_arrival
                ;		MsgBox(0, "listview item", GUICtrlRead(GUICtrlRead($list_tt)), 2)
                Local $selected_item = GUICtrlRead($list_tt)
                If $selected_item <> 0 Then
                    $selected_item = _ArraySearch($tt_item, $selected_item)
                    Local $shift
                    If setArrival($tt_plan, $tt_selected_route, $selected_item, $CurrentTime, $shift) > 0 Then
                        If GUICtrlRead($tt_shift_times_cb) == $GUI_CHECKED Then
                            Local $laststation = UBound($tt_plan[$tt_selected_route][2]) - 1
                            shiftTimes($tt_plan, $tt_selected_route, $selected_item, 0, $shift)
                            ;; MsgBox(1,"debug",$selected_item & " / " & $laststation)
                            If $selected_item < $laststation Then
                                For $i = $selected_item + 1 To $laststation
                                    shiftTimes($tt_plan, $tt_selected_route, $i, $shift, $shift)
                                Next
                            EndIf
                        EndIf

                        UpdatePlan($tt_item, $tt_plan, $tt_selected_route, $selected_item)
                        WritePlan($tt_file, $tt_plan)
                        ;;_GUICtrlListView_SetItemSelected($list_tt, $selected_item + 1, 1, 1)
                    EndIf
                EndIf

            Case $tt_set_departure
                ;		MsgBox(0, "listview item", GUICtrlRead(GUICtrlRead($list_tt)), 2)
                Local $selected_item = GUICtrlRead($list_tt)
                If $selected_item <> 0 Then
                    $selected_item = _ArraySearch($tt_item, $selected_item)
                    Local $shift
                    If setDeparture($tt_plan, $tt_selected_route, $selected_item, $CurrentTime, $shift) > 0 Then
                        If GUICtrlRead($tt_shift_times_cb) == $GUI_CHECKED Then
                            Local $laststation = UBound($tt_plan[$tt_selected_route][2]) - 1
                            ;; MsgBox(1,"debug",$selected_item & " / " & $laststation)
                            If $selected_item < $laststation Then
                                For $i = $selected_item + 1 To $laststation
                                    shiftTimes($tt_plan, $tt_selected_route, $i, $shift, $shift)
                                Next
                            EndIf
                        EndIf
                        UpdatePlan($tt_item, $tt_plan, $tt_selected_route, $selected_item)
                        WritePlan($tt_file, $tt_plan)
                        ;; Abfahrt setzen setzt Auswahl weiter
                        _GUICtrlListView_SetItemSelected($list_tt, $selected_item + 1, 1, 1)
                    EndIf
                EndIf

            Case $tt_menu
                If $tt_submenu == 0 Then
                    $tt_submenu = GUICreate(MsgH("TimeTable", "subMenu"), 300, 400, -1, -1, $DS_MODALFRAME);
                    $tt_create_plan_button = GUICtrlCreateButton(MsgH("TimeTable", "newPlan"), 25, 25, 250, 25)
                    $tt_delete_button = GUICtrlCreateButton(MsgH("TimeTable", "deleteEntry"), 25, 55, 250, 25)
                    $tt_insert_button = GUICtrlCreateButton(MsgH("TimeTable", "insertEntry"), 25, 85, 250, 25)
                    $tt_delete_route_button = GUICtrlCreateButton(MsgH("TimeTable", "deleteRoute"), 25, 115, 250, 25)
                    $tt_edit_route_button = GUICtrlCreateButton(MsgH("TimeTable", "editRoute"), 25, 145, 250, 25)
                    $tt_new_route_button = GUICtrlCreateButton(MsgH("TimeTable", "newRoute"), 25, 175, 250, 25)
                    $tt_close_button = GUICtrlCreateButton("Close", 25, 205, 250, 25)
                EndIf
                GUISetState(@SW_SHOW)

            Case $tt_close_button
                If $tt_submenu <> 0 Then
                    GUIDelete($tt_submenu)
                    $tt_submenu = 0
                EndIf

            Case $tt_delete_button
                Local $selected_item = getSelectedItem($list_tt, $tt_item)
                If $selected_item < 0 Then
                    MsgBox(0, MsgH("TimeTable", "TimeTable"), MsgH("TimeTable", "noEntrySelected"))
                Else
                    Local $station
                    Local $tan
                    Local $tab
                    If GetEntry($tt_plan[$tt_selected_route - 1][2], $tt_plan[$tt_selected_route - 1][3], $selected_item, $station, $tan, $tab) > 0 Then
                        If MsgBox(4, MsgH("TimeTable", "TimeTable"), "Eintrag >" & $station & "< wirklich löschen?") == 6 Then
                            deleteEntry($tt_plan[$tt_selected_route - 1][2], $tt_plan[$tt_selected_route - 1][3], $selected_item)
                            UpdatePlan($tt_item, $tt_plan, $tt_selected_route, $selected_item - 1)
                            WritePlan($tt_file, $tt_plan)
                            ;; Auswahl setzen auf nachgerückten Punkt
                            _GUICtrlListView_SetItemSelected($list_tt, $selected_item, 1, 1)
                        EndIf
                    EndIf
                EndIf

            Case $tt_insert_button
                Local $selected_item = getSelectedItem($list_tt, $tt_item)
                If $selected_item < 0 Then
                    MsgBox(0, MsgH("TimeTable", "TimeTable"), MsgH("TimeTable", "noEntrySelected"))
                Else
                    insertEntry($tt_plan[$tt_selected_route - 1][2], $tt_plan[$tt_selected_route - 1][3], $selected_item)
                    UpdatePlan($tt_item, $tt_plan, $tt_selected_route, $selected_item - 1)
                    WritePlan($tt_file, $tt_plan)
                    ;; Auswahl setzen auf nachgerückten Punkt
                    _GUICtrlListView_SetItemSelected($list_tt, $selected_item, 1, 1)
                EndIf

            Case $tt_new_route_button
                newRoute($tt_plan)
                $tt_selected_route = UBound($tt_plan) - 1
                UpdatePlan($tt_item, $tt_plan, $tt_selected_route, -1)
                WritePlan($tt_file, $tt_plan)

            Case $tt_edit_route_button
                editRoute($tt_plan, $tt_selected_route - 1)
                UpdatePlan($tt_item, $tt_plan, $tt_selected_route, -1)
                WritePlan($tt_file, $tt_plan)

                ;;	Case $list_tt
                ;;		MsgBox(0, "listview", "clicked=" & GUICtrlGetState($list_tt), 2)

            Case $tt_delete_route_button
                MsgBox(0, "Schade", "Noch nicht implementiert")

                ;;			#include "h_immo.au3"
            Case $getposbutton
                SetTab($ImmoTab)
                If $objeditoridx >= 0 Then
                    Local $oldname = $ImmoPos1[0];
                    GetImmoData($ImmoPos1, False)
                    showimmodata($immodata, $ImmoPos1);
                    If $ImmoPos1[0] <> $oldname Then
                        If $auto_val Then
                            ;; versuchen, Verschiebungswerte zu laden
                            ReadDefaultShift();
                        EndIf
                    EndIf
                    $iValid = True;
                    $DisplayNeedsRedraw = 1
                Else
                    Error(MsgH("EEP", "no_obj_editor"))
                EndIf

            Case $shiftxpcb
                $doShiftXp = GUICtrlRead($shiftxpcb) == $GUI_CHECKED
                If ($doShiftXp) Then
                    $doShiftXm = False
                    GUICtrlSetState($shiftxmcb, $GUI_UNCHECKED);
                EndIf

            Case $shiftxmcb
                $doShiftXm = GUICtrlRead($shiftxmcb) == $GUI_CHECKED
                If ($doShiftXm) Then
                    $doShiftXp = False
                    GUICtrlSetState($shiftxpcb, $GUI_UNCHECKED);
                EndIf

            Case $shiftypcb
                $doShiftYp = GUICtrlRead($shiftypcb) == $GUI_CHECKED
                If ($doShiftYp) Then
                    $doShiftYm = False
                    GUICtrlSetState($shiftymcb, $GUI_UNCHECKED);
                EndIf

            Case $shiftymcb
                $doShiftYm = GUICtrlRead($shiftymcb) == $GUI_CHECKED
                If ($doShiftYm) Then
                    $doShiftYp = False
                    GUICtrlSetState($shiftypcb, $GUI_UNCHECKED);
                EndIf

            Case $setposbutton
                SetTab($ImmoTab)
                If $objeditoridx >= 0 Then
                    If $iValid == False Then
                        Error("Position ungültig");
                    Else
                        Local $dx = 0;
                        Local $dy = 0;
                        Local $si = Sin($degToRad * $ImmoPos1[$iifz]);
                        Local $co = Cos($degToRad * $ImmoPos1[$iifz]);
                        If $doShiftXp Then
                            $dx = $ShiftX * $co;
                            $dy = $ShiftX * $si;
                        EndIf
                        If $doShiftXm Then
                            $dx = -$ShiftX * $co;
                            $dy = -$ShiftX * $si;
                        EndIf

                        If $doShiftYp Then
                            $dx -= $ShiftY * $si;
                            $dy += $ShiftY * $co;
                        EndIf
                        If $doShiftYm Then
                            $dx += $ShiftY * $si;
                            $dy -= $ShiftY * $co;
                        EndIf

                        $ImmoPos1[$iix] += $dx;
                        $ImmoPos1[$iiy] += $dy;

                        Local $oldname = $ImmoPos1[0];
                        If (SetImmoData($ImmoPos1, $hrel)) Then
                            showimmodata($immodata, $ImmoPos1);
                            Local $save_as_default = GUICtrlRead($save_as_default_cb) == $GUI_CHECKED;
                            If $save_as_default Then
                                WriteDefaultShift()
                                $save_as_default = False
                                NGSetCB($save_as_default_cb, False);
                            EndIf
                            If $ImmoPos1[0] <> $oldname Then
                                If $auto_val Then
                                    ReadDefaultShift()
                                EndIf
                            EndIf
                            $DisplayNeedsRedraw = 1
                        EndIf
                    EndIf
                Else
                    Error(MsgH("EEP", "no_obj_editor"))
                EndIf

            Case $shiftxinput
                $ShiftX = GUICtrlRead($shiftxinput)
                GUICtrlSetData($shiftxinput, $ShiftX)

            Case $shiftyinput
                $ShiftY = GUICtrlRead($shiftyinput)
                GUICtrlSetData($shiftyinput, $ShiftY)

            Case $hrelcb
                $hrel = GUICtrlRead($hrelcb) == $GUI_CHECKED

                ;;			#include "h_sign.au3"
                ;; signal/contact-tool

            Case $signbutton1
                SetContact($setting_signal_button1)
                WinActivate($eep)

            Case $signbutton2
                SetContact($setting_signal_button2)
                WinActivate($eep)

            Case $signbutton3
                SetContact($setting_signal_button3)
                WinActivate($eep)

            Case $signbutton4
                SetContact($setting_signal_button4)
                WinActivate($eep)

                ;;			#include "h_combi.au3"
                #cs
                    Case $csDir0
                    If GUICtrlRead($csDir0) == $GUI_CHECKED Then
                    BitSet($csdirselect, 1)
                    Else
                    BitReset($csdirselect, 1)
                    EndIf
                    $DisplayNeedsRedraw = 1

                    Case $csDir1
                    If GUICtrlRead($csDir1) == $GUI_CHECKED Then
                    BitSet($csdirselect, 2)
                    Else
                    BitReset($csdirselect, 2)
                    EndIf
                    $DisplayNeedsRedraw = 1

                    Case $csDir2
                    If GUICtrlRead($csDir2) == $GUI_CHECKED Then
                    BitSet($csdirselect, 4)
                    Else
                    BitReset($csdirselect, 4)
                    EndIf
                    $DisplayNeedsRedraw = 1

                    Case $csDir3
                    If GUICtrlRead($csDir3) == $GUI_CHECKED Then
                    BitSet($csdirselect, 8)
                    Else
                    BitReset($csdirselect, 8)
                    EndIf
                    $DisplayNeedsRedraw = 1

                    Case $csDir4
                    If GUICtrlRead($csDir4) == $GUI_CHECKED Then
                    BitSet($csdirselect, 16)
                    Else
                    BitReset($csdirselect, 16)
                    EndIf
                    $DisplayNeedsRedraw = 1

                    Case $csDir5
                    If GUICtrlRead($csDir5) == $GUI_CHECKED Then
                    BitSet($csdirselect, 32)
                    Else
                    BitReset($csdirselect, 32)
                    EndIf
                    $DisplayNeedsRedraw = 1

                    Case $csupbutton
                    InputNumber($csWidthInput, $cswidth)
                    $csx += -SinD($csdir) * $cswidth
                    $csy += CosD($csdir) * $cswidth
                    For $i = 0 To 4
                    For $j = 0 To 3
                    $csOld[$i][$j] = $csOld[$i][$j + 1]
                    Next
                    $csOld[$i][$j] = 0
                    Next
                    $DisplayNeedsRedraw = 1

                    ;;Global $csrightbutton= NGButton(">",$NG_RIGHT);
                    Case $csrightbutton
                    InputNumber($csLenInput, $cslen)
                    $csx += CosD($csdir) * $cslen
                    $csy += SinD($csdir) * $cslen
                    For $i = 0 To 4
                    For $j = 0 To 3
                    $csOld[$j][$i] = $csOld[$j + 1][$i]
                    Next
                    $csOld[4][$i] = 0
                    Next
                    $DisplayNeedsRedraw = 1

                    ;;Global $csleftbutton= NGButton("<",$NG_LEFT);
                    Case $csleftbutton
                    InputNumber($csLenInput, $cslen)
                    $csx += -CosD($csdir) * $cslen
                    $csy += -SinD($csdir) * $cslen
                    For $i = 0 To 4
                    For $j = 4 To 1 Step -1
                    $csOld[$j][$i] = $csOld[$j - 1][$i]
                    Next
                    $csOld[0][$i] = 0
                    Next
                    $DisplayNeedsRedraw = 1

                    ;;Global $csdownbutton=NGButton("V",$NG_BOTH);
                    Case $csdownbutton
                    InputNumber($csWidthInput, $cswidth)
                    $csx += SinD($csdir) * $cswidth
                    $csy += -CosD($csdir) * $cswidth
                    For $i = 0 To 4
                    For $j = 4 To 1 Step -1
                    $csOld[$i][$j] = $csOld[$i][$j - 1]
                    Next
                    $csOld[$i][0] = 0
                    Next
                    $DisplayNeedsRedraw = 1

                    Case $csLenInput
                    InputNumber($csLenInput, $cslen)
                    ;;MsgBox(0,"Set cslen",$cslen)

                    Case $csWidthInput
                    InputNumber($csWidthInput, $cswidth)
                    ;;GuiCtrlSetData($csWidthInput,$cswidth)

                    Case $cssetbutton
                    SetTab($CombiTab)
                    WinActivate($eep)

                    InputNumber($csLenInput, $cslen)
                    InputNumber($csWidthInput, $cswidth)

                    DirToTrack($csdirselect, $cstrackselect)

                    ;;_arraydisplay($csdirselect)
                    ;;_arraydisplay($cstrackselect)

                    Dim $xkwtrack[$TrackDataLen]
                    ;; referenzpunkt der Gleiskombination ermitteln
                    Global $csreftrack = 1
                    XKWTrack($xkwtrack, $cslen, $cswidth, $csreftrack)
                    Local $csrefx = $xkwtrack[$ix]
                    Local $csrefy = $xkwtrack[$iy]
                    Local $csrefdir = $xkwtrack[$idir]

                    For $i = 0 To 14
                    XKWTrack($xkwtrack, $cslen, $cswidth, $i)
                    ShiftTrack($xkwtrack, -$csrefx, -$csrefy)
                    RotateTrack($xkwtrack, 0, 0, -$csrefdir)

                    RotateTrack($xkwtrack, 0, 0, $csdir)
                    ShiftTrack($xkwtrack, $csx, $csy)
                    $xkwtrack[$ih1] = $csh1
                    If $cstrackselect[$i] > 0 Then
                    PutTrack($xkwtrack, $cstrackselect[$i])
                    EndIf
                    Next
                    $csOld[2][2] = $csdirselect
                    ;;_ArrayDisplay($csOld)
                #ce
                ;;			#include "h_option.au3"
            Case $auto_ok_cb
                If GUICtrlRead($auto_ok_cb) == $GUI_CHECKED Then
                    BitSet($auto_ok, 1)
                Else
                    BitReset($auto_ok, 1)
                EndIf

            Case $raster_ok_cb
                If GUICtrlRead($raster_ok_cb) == $GUI_CHECKED Then
                    BitSet($auto_ok, 2)
                Else
                    BitReset($auto_ok, 2)
                EndIf

            Case $clock_start_stop_rad
                SetClockMode("start_stop")

            Case $clock_start_cont_rad
                SetClockMode("start_cont")

            Case $clock_lap_rad
                SetClockMode("lap")

            Case $clock_life_rad
                SetClockMode("life")

            Case $clock_hmsmode_cb
                If GUICtrlRead($clock_hmsmode_cb) == $GUI_CHECKED Then
                    $clockdmode = "hms"
                Else
                    $clockdmode = "sec"
                EndIf

            Case $clock_modulo_input
                Local $h = Int(GUICtrlRead($clock_modulo_input))

                If $h >= 0 Then
                    $clockmodulo = $h
                EndIf

            Case $clock_reset_button
                SetClockMode($clockmode)

            Case $speedlog2
                $LogStep = 1

            Case $speedlog4
                $LogStep = 2

            Case $speedlog8
                $LogStep = 4

            Case $speedlog16
                $LogStep = 8

            Case $winposbutton
                Local $pos = WinGetPos($eep)
                $eepleft = $pos[0]
                $eeptop = $pos[1]
                $eepwidth = $pos[2]
                $eepheight = $pos[3]

                $pos = WinGetPos($gui)
                $top = $pos[1]
                $left = $pos[0]


                ;; Tabwechsel
            Case $tab
                Local $activetab = GUICtrlRead($tab, 1)
                SetDisplay($activetab)

            Case $TrackTab
                SetTab($TrackTab)

            Case $CombiTab
                SetTab($CombiTab)

            Case $Track2Tab
                SetTab($Track2Tab)

            Case $ImmoTab
                SetTab($ImmoTab)

            Case $SignalTab
                SetTab($SignalTab)

            Case $OptionTab
                SetTab($OptionTab)

            Case $activate_hugo
                WinActivate($gui)

            Case $activate_eep
                WinActivate($eep)

            Case $auto_val_cb
                $auto_val = GUICtrlRead($auto_val_cb) == $GUI_CHECKED

            Case $clockbutton
                ClockButton()
                WinActivate($eep)

            Case $quitbutton
                ;;DLLTest()
                $msg = $GUI_EVENT_CLOSE

            Case $previewa
                SpeedlogReset()
                WinActivate($eep)

        EndSwitch ;; msg

        If $msg <> $GUI_EVENT_CLOSE Then
            $msg = 0
        EndIf
    EndIf
    ;; WinActivate($eep)
Until $msg == $GUI_EVENT_CLOSE

;; aktuelle Einstellungen speichern
SaveOptions()
