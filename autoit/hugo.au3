#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compile_Both=n
#AutoIt3Wrapper_UseX64=n
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

#include <hugo_constants.au3>

;; eep language file
Global $eep_langfile

;; preloaded strings from language files
Global $hugo_lang
Global $eep_lang

;; EEP version - still unknown
Global $EEPVersionWanted = 0
Global $EEPVersionReal = 0

;; registry section and directory path
Global $EEPSection = ""
Global $EEPDir = ""

; =============================================================================
;; globals for track tool

Global $SollGleisAnz = 5 ; // number of tracks

Global $StartGleis[$TrackDataLen] = [-99, 0, 0, 0, 99, 0.6, 0.6, False, 0, 0, 0]

Global $EndGleis[$TrackDataLen] = [300, -80, -20, 0, 99, 0.6, 0.6, False, 0, 0, 0]

;; Gleisverbindung
Global $Verbindung[$MaxGleise][$TrackDataLen]
Global $IstGleisAnz ;  // Anzahl der Gleise in Verbindung

;; Startwerte für Positionen Immobilien
Global $ImmoPos1[16] = ["", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $iValid = False

;; Startwert Verschiebung in x-Richtung
Global $ShiftX = 10
Global $ShiftY = 10
Global $ShiftZ = 0

Global $doShiftXp = True
Global $doShiftXm = False
Global $doShiftYp = False
Global $doShiftYm = False
Global $doShiftZp = False
Global $doShiftZm = False

Global $LogStep = 4

;; Gleisbogenberechnung
Global $TrackRad = 300
Global $TrackMaxLen = 60
Global $samft = 0

Global $trackCalculated = 0 ;; Gleis bereits berechnet ?
Global $trackstatus = 0 ;; (berechnetes) Gleis zulässig ?
Global $track_shift_x = 0 ;; keine Verschiebung
Global $track_shift_h = 0 ;; keine Verschiebung
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
Global $EEPTimeFile ;

;; Timetable
Global $cycle = 24 * 3600
Global $ncycle = 2
Global $bgcolor = 0xbbbbbb
Global $gridcolor = 0xeeeeee

Global $LastParsedTime = 0

Global $tt_plan
Global $tt_selected_route = 1
Global $tt_route

;; GUI
Global $oldeditor = -1
Global $actionlist

Global $ScreenSize
;; Handler for EEP-Window
Global $eep


Global $TrackTab
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
Global $trackeditoridx = -1 ; Aktueller Gleis-Editor (Index in Tabelle der Buttons)
Global $objeditoridx = -1 ; Aktueller Objekt-Editor

Global $lasttime = 0
Global $getxlasttime = 0
Global $LastIndex = 0

Dim $speed[$SpeedLogSize]
Dim $sspeed[$SpeedLogSize]
Global $logcount = 0

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

;; Gui ImmoTab

Global $getposbutton

Global $immodata

Global $shiftxinput

Global $shiftxpcb
Global $shiftxmcb

Global $shiftyinput

Global $shiftypcb
Global $shiftymcb

Global $shiftzinput

Global $shiftzpcb
Global $shiftzmcb

Global $setposbutton
Global $hrelcb

Global $save_as_default_cb

;; Clock
Global $clock_reset_button

#include <generic_functions.au3>

#include <geometry.au3>

Func Inside($winpos, $x, $y)
	Return $x > $winpos[0] And $x < $winpos[0] + $winpos[2] And $y > $winpos[1] And $y < $winpos[1] + $winpos[3]
EndFunc   ;==>Inside
#cs
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
#ce

#include <calldll.au3>

#include <langtools.au3>

;; Initialisierungen
;; Werte die aus der aktuellen Konfiguration zu bestimmen sind:
;; - Nutzereinstellungen
;; - eep-Installation
;; - Sprachdateien

Func LoadOptions()
	$EEPVersionWanted = Int(IniRead($inifile, "gui", "EEPVersion", 0))

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
	Global $mode = Int(IniRead($inifile, "track", "mode", 1)) ;

	Global $TrackRad = Int(IniRead($inifile, "track", "trackrad", 300))
	Global $TrackMaxLen = Int(IniRead($inifile, "track", "trackmaxlen", 60))
	$samft = Bool(IniRead($inifile, "track", "samft", True))

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
		$keydefstring &= "!a:setarrival|!d:setdeparture|"
		$keydefstring &= "^g:getobject|^s:setobject|"
		$keydefstring &= "!f:signal2|!h:signal1|^2:signal3|^t:clock"
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

	Global Const $mtext_signal_button1 = IniRead($inifile, "SignTab", "Button1", "Fahrt") ;
	Global Const $mtext_signal_button2 = IniRead($inifile, "SignTab", "Button2", "Halt / Abzweig") ;
	Global Const $mtext_signal_button3 = IniRead($inifile, "SignTab", "Button3", "Richtung 2") ;
	Global Const $mtext_signal_button4 = IniRead($inifile, "SignTab", "Button4", "") ;

	Global Const $setting_signal_button1 = StringSplit(IniRead($inifile, "SignTab", "Setting1", "sfBesx|wfBEsx"), "|", 2) ;
	Global Const $setting_signal_button2 = StringSplit(IniRead($inifile, "SignTab", "Setting2", "sfBegx|wfBEgx"), "|", 2) ;
	Global Const $setting_signal_button3 = StringSplit(IniRead($inifile, "SignTab", "Setting3", "wFbx|sFbx"), "|", 2) ;
	Global Const $setting_signal_button4 = StringSplit(IniRead($inifile, "SignTab", "Setting4", ""), "|", 2) ;

EndFunc   ;==>LoadOptions

Func IniSaveGE($section, $key, $val)
	If $val >= 0 Then
		IniWrite($inifile, $section, $key, $val) ;
	EndIf
EndFunc   ;==>IniSaveGE

Func SaveOptions()

	Dim $pos[4]

	IniWrite($inifile, "gui", "top", $top) ;
	IniWrite($inifile, "gui", "left", $left) ;

	IniSaveGE("eep", "top", $eeptop)
	IniSaveGE("eep", "left", $eepleft)
	IniSaveGE("eep", "width", $eepwidth)
	IniSaveGE("eep", "height", $eepheight)

	IniSaveGE("timetable", "top", $tttop)
	IniSaveGE("timetable", "left", $ttleft)
	IniSaveGE("timetable", "width", $ttwidth)
	IniSaveGE("timetable", "height", $ttheight)

	IniWrite($inifile, "timetable", "file", $tt_file)

	IniSaveGE("gui", "WinWaitDelay", $WinWaitDelay) ;

	IniWrite($inifile, "track", "level", $level) ;
	IniWrite($inifile, "track", "copy", $copy) ;
	IniWrite($inifile, "track", "mode", $mode) ;
	IniWrite($inifile, "track", "trackmaxlen", $TrackMaxLen) ;
	IniWrite($inifile, "track", "samft", $samft) ;

	IniWrite($inifile, "immo", "auto_val", $auto_val) ;
	IniWrite($inifile, "immo", "hrel", $hrel) ;

	IniWrite($inifile, "options", "auto_ok", $auto_ok)

	IniWrite($inifile, "clock", "mode", $clockmode)
	IniWrite($inifile, "clock", "dmode", $clockdmode)
	IniWrite($inifile, "clock", "modulo", $clockmodulo)

	Local $actionstring = _ArrayToString($actionlist, ",") ;
	IniWrite($inifile, "hotkey", "possible_actions", $actionstring) ;
	IniWrite($inifile, "hotkey", "last_used", $keydefstring) ;

	IniWrite($inifile, "SignTab", "Button1", $mtext_signal_button1) ;
	IniWrite($inifile, "SignTab", "Button2", $mtext_signal_button2) ;
	IniWrite($inifile, "SignTab", "Button3", $mtext_signal_button3) ;
	IniWrite($inifile, "SignTab", "Button4", $mtext_signal_button4) ;

	Local $bs = _ArrayToString($setting_signal_button1, "|") ;
	IniWrite($inifile, "SignTab", "Setting1", $bs) ;
	Local $bs = _ArrayToString($setting_signal_button2, "|") ;
	IniWrite($inifile, "SignTab", "Setting2", $bs) ;
	Local $bs = _ArrayToString($setting_signal_button3, "|") ;
	IniWrite($inifile, "SignTab", "Setting3", $bs) ;
	Local $bs = _ArrayToString($setting_signal_button4, "|") ;
	IniWrite($inifile, "SignTab", "Setting4", $bs) ;
EndFunc   ;==>SaveOptions

Func ReadLang($section, $key)
	Local $val = IniRead($langfile, $section, $key, "<undefined>")
	If $val = "<undefined>" Then
		FatalError($PName & ".lng: " & $key & " in section " & $section & " undefined")
		Return ""
	EndIf
	Return $val ;
EndFunc   ;==>ReadLang

Func ReadEEP($section, $key)
	Local $val = IniRead($eep_langfile, $section, $key, "<undefined>")
	If $val = "<undefined>" Then
		FatalError($eep_langfile & ": " & $key & " in section " & $section & " undefined")
		Return ""
	EndIf
	Return $val ;
EndFunc   ;==>ReadEEP


Func locateEEP($Version)
	Switch $Version
		Case 10
			$EEPSection = "HKEY_LOCAL_MACHINE64\SOFTWARE\Trend\EEP 10.00\EEXP"
		Case 110
			$EEPSection = "HKEY_LOCAL_MACHINE\SOFTWARE\Trend\EEP 10.00\EEXP"
		Case 11
			$EEPSection = "HKEY_LOCAL_MACHINE64\SOFTWARE\Trend\EEP 11.00\EEXP"
		Case 110
			$EEPSection = "HKEY_LOCAL_MACHINE\SOFTWARE\Trend\EEP 11.00\EEXP"
		Case 12
			$EEPSection = "HKEY_LOCAL_MACHINE64\SOFTWARE\Trend\EEP 12.00\EEXP"
		Case 120
			$EEPSection = "HKEY_LOCAL_MACHINE\SOFTWARE\Trend\EEP 12.00\EEXP"
	EndSwitch
	$EEPDir = RegRead($EEPSection, "Directory") ;
	If @error Then
		$EEPSection = ""
		$EEPDir = ""
		Return False
	Else
		$EEPVersionReal = Mod($Version, 100)
		Return True
	EndIf
EndFunc   ;==>locateEEP

;; Meldungen und andere Texte einlesen
;; das ist eine neue Variante, die keine Einzelvariablen sondern ein Array verwendet
ReadLanguageFile($hugo_lang, $langfile)

;; Global messages
;; have default here to allow exit with message
Global Const $msg_error = IniRead($langfile, "Base", "Error", "Fehler") ;
Global Const $msg_warning = IniRead($langfile, "Base", "Warning", "Warnung") ;
Global Const $msg_tip = IniRead($langfile, "Base", "Tip", "Tipp") ;

;; Mode-Liste Tracktool

Global Const $ModeList[5] = [MsgH("TrackTab", "Optimization1"), MsgH("TrackTab", "Optimization2"), MsgH("TrackTab", "Construction_line_circle"), MsgH("TrackTab", "Construction_circle_line_circle"), MsgH("TrackTab", "Construction_line_circle_line")]

;Global Const $mtext_speedlog = ReadLang("Options", "SpeedLog")
;;

;; eventuelle Nutzereinstellung laden
LoadOptions()

$EEPVersionReal = 0

Switch $EEPVersionWanted
	Case 0 ;; check all
		If Not locateEEP(12) Then
			If Not locateEEP(112) Then
				If Not locateEEP(11) Then
					If Not locateEEP(111) Then
						If Not locateEEP(10) Then
							locateEEP(110)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

	Case 10
		If Not locateEEP(10) Then
			locateEEP(110)
		EndIf
	Case 11
		If Not locateEEP(11) Then
			locateEEP(111)
		EndIf
	Case 12
		If Not locateEEP(12) Then
			locateEEP(112)
		EndIf
	Case Else
		FatalError("Version " & $EEPVersionWanted & " nicht unterstützt")
EndSwitch

If $EEPVersionReal == 0 Then
	MsgBox(0, $msg_error, MsgH("EEP", "EEP_NOT_FOUND"))
	Exit 1
EndIf

$EEPTimeFile = $EEPDir & "\Resourcen\time.eep"
;;$EEPTimeFile = "time.eep"
FileDelete($EEPTimeFile)

;; ---- Data for EEP ----

$eep_langfile = $EEPDir & "\" & "eep.lng"

ReadLanguageFile($eep_lang, $eep_langfile)

;; Texte zur Identifizierung von Fenstern

Global $main_title = ReadEEP("DLG_STANDARD_MESSAGE", "IDR_MAINFRAME") ;
;; eep 10 :  IDR_MAINFRAME ="EEP %s- Eisenbahn.exe"

;MsgBox(0,"Title",$main_title)
If StringInStr($main_title, "%s") Then
	Local $MainTitleParts = StringSplit($main_title, "%s", 1)
	$main_title = "[REGEXPTITLE:" & $MainTitleParts[1] & ".*" & $MainTitleParts[2] & "]"
EndIf
;MsgBox(0,"Title",$main_title)
;; IDR_MAINFRAME				="EEP %s- Eisenbahn.exe"

Global Const $immo_prop_text1 = ReadEEP("DLG_OBJECT_PROPERTIES", "IDC_STATIC_ROTZ") ;
Global Const $immo_prop_text2 = ReadEEP("DLG_OBJECT_PROPERTIES", "IDC_STATIC_ROTX") ;

Global Const $track_prop_text1 = ReadEEP("DLG_TRACK_PROPERTIES", "IDC_STATIC_POSX") ;
Global Const $track_prop_text2 = ReadEEP("DLG_TRACK_PROPERTIES", "IDC_STATIC_POSY") ;

Global Const $ok_window_text1 = ReadEEP("DLG_STANDARD_MESSAGE", "IDS_REPORT_SAVED") ;
Global $ok_window_text2 = ReadEEP("DLG_STANDARD_MESSAGE", "IDS_BESTEHENDE_ANLAGE_SPEICHERN") ;

;; MsgBox(1,"windowtext2",$ok_window_text2 & " => " & C2RegExp($ok_window_text2));

;; Dieser text enthält substitionen (%s)
;; zur Zeit: Nur längsten der festen Textteile nutzen
;; in feste Textteile zerlegen

Dim $harray = StringSplit($ok_window_text2, "%s", 1)

;; längsten text-Teil suchen

$ok_window_text2 = "" ;
For $i = 1 To $harray[0]
	If (StringLen($harray[$i]) > StringLen($ok_window_text2)) Then
		$ok_window_text2 = $harray[$i] ;
	EndIf
Next

Global Const $status_ready = ReadEEP("DLG_STANDARD_MESSAGE", "AFX_IDS_IDLEMESSAGE")

Global $rasterwarning = StringLeft(ReadEEP("OTHER", "ANLERR1"), 30) ;; Trick: nur 30 Zeichen, um [e] für Enter zu umgehen.
Global $description = ReadEEP("DLG_DESCRIPTION", "Caption") ;

;MsgBox(1,"description",$description);
;MsgBox(1,"rasterwarning",$rasterwarning);
;MsgBox(1,"status_ready",$status_ready);

;; Text in speedcontrol
;; werden für Control-Suche gleich in reguläre Ausdrücke umgewandelt
Global Const $actualspeed = C2RegExp(ReadEEP("DLG_CONTROL_AUTOMATIC", "IDC_STAT_ISTVELOC"))
Global Const $targetspeed = C2RegExp(ReadEEP("DLG_CONTROL_AUTOMATIC", "IDC_STAT_SOLLVELOC"))
;; MsgBox(0,"speed",$actualspeed & " " & $targetspeed)

;; Texte der Editorliste(ComboBox)

Global Const $editor_signal = ReadEEP("TOOLBAR", "COMBOBOX_A_0") ;
Global Const $editor_surface = ReadEEP("TOOLBAR", "COMBOBOX_A_1") ;
Global Const $editor_landscape = ReadEEP("TOOLBAR", "COMBOBOX_A_2") ;
Global Const $editor_immo = ReadEEP("TOOLBAR", "COMBOBOX_A_3") ;
Global Const $editor_goods = ReadEEP("TOOLBAR", "COMBOBOX_A_4") ;
Global Const $editor_traffic = ReadEEP("TOOLBAR", "COMBOBOX_A_5") ;
Global Const $editor_track = ReadEEP("TOOLBAR", "COMBOBOX_A_6") ;
Global Const $editor_road = ReadEEP("TOOLBAR", "COMBOBOX_A_7") ;
Global Const $editor_tram = ReadEEP("TOOLBAR", "COMBOBOX_A_8") ;
Global Const $editor_water = ReadEEP("TOOLBAR", "COMBOBOX_A_9") ;

Global Const $TrackEditorList[4] = [$editor_track, $editor_road, $editor_tram, $editor_water] ;
Global Const $EditorList[] = [$editor_signal, $editor_surface, $editor_landscape, $editor_immo, $editor_goods, $editor_traffic, $editor_track, $editor_road, $editor_tram, $editor_water] ;

Global Const $controls = 16
Global $Button[4][$controls] ; 4 editors * (12 "buttons" + 4 "edits")

For $i = 0 To 3
	For $k = 0 To $controls - 1
		$Button[$i][$k] = 0
	Next
Next

Global $Button_Immo_del = 0
Global $Button_LE_del = 0

Global Const $caption_contact_signal = ReadEEP("DLG_CONTACT_POINT_SIGNAL", "CAPTION") ;
Global Const $caption_contact_switch = ReadEEP("DLG_CONTACT_POINT_SWITCH", "CAPTION") ;
Global Const $contact_umschalter = ReadEEP("DLG_CONTACT_POINT_SWITCH", "IDC_EFFECT4") ;
;; Vorbereitungen Gleis
ErgaenzeGleis($StartGleis)
ErgaenzeGleis($EndGleis)

Global Const $caption_control = ReadEEP("DLG_CTRL", "CAPTION")

If $tt_file <> "<undefined>" Then
	ReadPlan($tt_file, $tt_plan)
EndIf

Func GetEditor()
	;; global $eep
	Local $sel = -1 ; not found yet

	Local $selectstring ;
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
	Return $sel ;
EndFunc   ;==>GetEditor

Func SetEditorVars($edit)
	;; MsgBox(0, "Editoren", "Alt:" & $OldEditor & "  neu:" & $editor)
	Global $trackeditoridx = -1 ;
	Global $objeditoridx = -1 ;
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
			$trackeditoridx = $eid_track ;
		Case 7
			;; Strasse
			$trackeditoridx = $eid_road ;
		Case 8
			;; Strassenbahn
			$trackeditoridx = $eid_tram ;
		Case 9
			;; Wasser/Luft
			$trackeditoridx = $eid_water ;
	EndSwitch
EndFunc   ;==>SetEditorVars

Func SetEditor($edit)
	Local $ct = 0
	While GetEditor() <> $edit
		If $ct = 0 Then
			MsgBox(0, "SetEditor", "Switch to Editor " & $EditorList[$edit], 1)
		EndIf
		Sleep(100)
		$ct += 1
		If $ct > 5 Then
			$ct = 0
		EndIf
	WEnd
	SetEditorVars($edit)
EndFunc   ;==>SetEditor

Func SetEffekt($h, $edit)
	Local $sel = ControlGetHandle($h, "", 1465)
	;; ControlClick($h,"",$sel);
	If ($edit < 0) Then
		ControlCommand($h, "", $sel, "SelectString", $contact_umschalter)
	Else
		ControlCommand($h, "", $sel, "SetCurrentSelection", $edit)
	EndIf
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
	;;Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client
	WinActivate($eep)
	Select
		Case $btn == 0
			MouseClick("left")
		Case $btn == 1
			MouseClick("right")
		Case $btn == 2
			MouseClick("left")
			MouseClick("right")
	EndSelect
EndFunc   ;==>Click

Func RightClick()
	Click(1)
EndFunc   ;==>RightClick

Func FindProp1($text1, $text2)
	;; Search track property window
	Local $hw = 0
	;; global $eep
	Local $var = WinList()
	;; _arraydisplay($var)
	For $i = 1 To $var[0][0]
		;;		If $var[$i][0] <> "" AND IsVisible($var[$i][1]) Then
		If $var[$i][0] <> "" And BitAND(WinGetState($var[$i][1]), 2) Then
			Local $title = $var[$i][0]
			Local $handle = $var[$i][1] ;
			Local $title3 = StringLower(StringLeft($title, 3))
			;; Das EEP-Fenster darf nicht weiter abgefragt werden, da es dadurch zerstört wird
			If $title3 <> "eep" Then
				;; If $handle <> $eep Then
				Local $text = WinGetText($handle) ;
				If StringInStr($text, $text1) And StringInStr($text, $text2) Then
					$hw = $var[$i][1] ;  found!
					ExitLoop
				EndIf
			EndIf
		EndIf
	Next
	;; _arraydisplay($var)
	Return $hw
EndFunc   ;==>FindProp1

Func FindProp($text1, $text2)
	;; MsgBox(1,"FindProp",$text1 & "  " & $text2)
	;; property window open ??
	Local $rc = FindProp1($text1, $text2)
	If ($rc == 0) Then
		;; retry with rightclick
		RightClick()
		Local $i = 0 ;
		While ($rc == 0 And $i < 40)
			Sleep(100)
			$rc = FindProp1($text1, $text2)
			$i = $i + 1 ;
		WEnd
	EndIf
	Return $rc
EndFunc   ;==>FindProp

Func FindEdit()
	Return FindProp($track_prop_text1, $track_prop_text2) ;
EndFunc   ;==>FindEdit

Func FindImmo()
	Return FindProp($immo_prop_text1, $immo_prop_text2) ;
EndFunc   ;==>FindImmo

Func AutoOK()
	If BitTest($auto_ok, 1) Then
		;;MsgBox(0,"auto1",$auto_ok);
		;;		if WinActive("eep",$ok_window_text1) OR WinActive("EEP",$ok_window_text1) OR WinActive("eep",$ok_window_text2) OR WinActive("EEP",$ok_window_text2) Then
		If WinActive("eep", $ok_window_text1) Or WinActive("eep", $ok_window_text2) Then
			;;		If WinExists("eep", $ok_window_text1) Or WinExists("eep", $ok_window_text2) Then
			;;MsgBox(0,"auto1","Enter");
			Send("{ENTER}") ;
		EndIf
	EndIf
	If BitTest($auto_ok, 2) Then
		;;MsgBox(0,"auto2",$auto_ok);
		If WinActive($description) Then
			;;MsgBox(0,"auto2","Enter");
			Send("{ENTER}") ;
		EndIf
	EndIf
	If BitTest($auto_ok, 4) Then
		If WinActive("eep", $rasterwarning) Then
			;;MsgBox(0,"auto2b","Enter");
			Send("{ENTER}") ;
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
		$speedstring = ControlGetText($eep, "", 1283) ;
		;;MsgBox(1,"speed","EEP " & $speedstring,1)
	Else
		$speedstring = ControlGetText($caption_control, "", 1283) ;
		;;MsgBox(1,"speed","Steuer " & $speedstring,1)
	EndIf
	Local $aspeed = StringRegExp($speedstring, '\(([-0-9]*).*\)', 1)
	If @error == 0 Then
		$ist = Abs(Number($aspeed[0]))
		;;$speedstring=ControlGetText($eep,"","[CLASS:Static;INSTANCE:58]");
		;;$speedstring=ControlGetText($eep,"","[CLASS:Static;INSTANCE:52]");
		;;$speedstring = ControlGetText($eep, "", $targetspeedcontrol);
		If $sel > 0 Then
			$speedstring = ControlGetText($eep, "", 1284) ;
		Else
			$speedstring = ControlGetText($caption_control, "", 1284) ;
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
		Error(MsgH("EEP", "NO_WINDOW")) ;
		Return False ;
	Else
		WinActivate($handle) ;
		ControlCommand($handle, "", $id_parmode, "SetCurrentSelection", 3)
		$gleis[$iangle] = GetNumber($handle, $id_angle)
		$gleis[$ilen] = GetNumber($handle, $id_len)
		$gleis[$ix] = GetNumber($handle, $id_x)
		$gleis[$iy] = GetNumber($handle, $id_y)
		$gleis[$ih1] = GetNumber($handle, $id_h1)
		$gleis[$idir] = GetNumber($handle, $id_dir)
		$gleis[$igrad] = GetNumber($handle, $id_steigung)
		$gleis[$ibend] = GetNumber($handle, $id_bend)
		ErgaenzeGleis($gleis)

		Send("!A") ;

		If $delete Then
			WinActivate($eep) ;
			Sleep(100)
			Send("!E")
			Send("L") ;
		EndIf

		Return True ;
	EndIf

EndFunc   ;==>GetTrackData

Func GetImmoData(ByRef $immo, $delete = False)
	WinActivate($eep)
	Local $handle = FindImmo()
	If $handle == 0 Then
		Error(MsgH("EEP", "NO_WINDOW"))
		Return False ;
	Else
		WinActivate($handle) ;
		#cs
			Global Const $iiname = 0
			Global Const $iix = 1
			Global Const $iiy = 2
			Global Const $iiz = 3
			Global Const $iizr = 4
			Global Const $iifx = 5
			Global Const $iify = 6
			Global Const $iifz = 7
			Global Const $iiscx = 8
			Global Const $iiscy = 9
			Global Const $iiscz = 10
			Global Const $iilight = 11
			Global Const $iishadow = 12
			Global Const $iismoke = 13
			Global Const $iifire = 14
			Global Const $iiswim = 15
		#ce
		$immo[$iiname] = WinGetTitle($handle) ;
		$immo[$iix] = GetNumber($handle, $iid_x)
		$immo[$iiy] = GetNumber($handle, $iid_y)
		$immo[$iiz] = GetNumber($handle, $iid_z)

		$immo[$iizr] = GetNumber($handle, $iid_zr)

		$immo[$iifx] = GetNumber($handle, $iid_fx)
		$immo[$iify] = GetNumber($handle, $iid_fy)
		$immo[$iifz] = GetNumber($handle, $iid_fz)

		$immo[$iiscx] = GetNumber($handle, $iid_scx)
		$immo[$iiscy] = GetNumber($handle, $iid_scy)
		$immo[$iiscz] = GetNumber($handle, $iid_scz)

		;; i cannot read the "checkboxes" of EEP
		#cs
			$immo[$iilight] = GUICtrlGetState($iid_light)
			$immo[$iishadow] = GUICtrlGetState($iid_shadow)
			$immo[$iismoke] = GUICtrlGetState($iid_smoke)
			$immo[$iifire] = GUICtrlGetState($iid_fire)
		#ce

		$immo[$iiswim] = GetNumber($handle, $iid_swim)

		Send("{ESCAPE}") ;

		If $delete Then
			WinActivate($eep) ;
			Sleep(100)
			Send("!E")
			Send("L") ;
		EndIf
		;; _arraydisplay($immo)
		Return True ;
	EndIf

EndFunc   ;==>GetImmoData

Func SetImmoData(ByRef $immo, $rel = True)

	WinActivate($eep)

	Local $handle = FindImmo()
	If $handle == 0 Then
		Error(MsgH("EEP", "NO_WINDOW")) ;
		Return False ;
	Else
		WinActivate($handle) ;
		SetText($handle, $iid_x, $immo[$iix])
		$immo[0] = WinGetTitle($handle) ;
		SetText($handle, $iid_y, $immo[$iiy])

		If ($rel == False) Then
			SetText($handle, $iid_z, $immo[$iiz])
		Else
			SetText($handle, $iid_zr, $immo[$iizr])
		EndIf

		SetText($handle, $iid_fx, $immo[$iifx])
		SetText($handle, $iid_fy, $immo[$iify])
		SetText($handle, $iid_fz, $immo[$iifz])

		SetText($handle, $iid_scx, $immo[$iiscx])
		SetText($handle, $iid_scy, $immo[$iiscy])
		SetText($handle, $iid_scz, $immo[$iiscz])

		SetText($handle, $iid_swim, $immo[$iiswim])

		;; abhängige Werte zurücklesen
		If ($rel == False) Then
			$immo[$iizr] = GetNumber($handle, $iid_zr)
		Else
			$immo[$iiz] = GetNumber($handle, $iid_z)
		EndIf

		Send("{ENTER}") ;

		Return True ;
	EndIf

EndFunc   ;==>SetImmoData

Func SetTrack(ByRef $gleis)

	Local $handle = FindEdit() ;; Eigenschaftsfenster öffnen

	If $handle <> 0 Then
		;; Modus Länge + Winkel einstellen
		ControlCommand($handle, "", 1289, "SetCurrentSelection", 3)

		While ($gleis[$idir] > 360)
			$gleis[$idir] -= 360 ;
		WEnd
		While ($gleis[$idir] < -360)
			$gleis[$idir] += 360 ;
		WEnd

		SetText($handle, $id_x, $gleis[$ix])
		SetText($handle, $id_y, $gleis[$iy])
		SetText($handle, $id_dir, $gleis[$idir])
		SetText($handle, $id_h1, $gleis[$ih1])
		SetText($handle, $id_len, $gleis[$ilen])
		SetText($handle, $id_bend, $gleis[$ibend])
		SetText($handle, $id_steigung, $gleis[$igrad])
		Local $angle = $gleis[$iangle]
		If Abs($angle) < 0.001 Then
			$angle = 0
		EndIf
		SetText($handle, $id_angle, $angle) ;
		;;MsgBox(1,"DEBUG","hier")
		Send("!O") ;; OK
		Return True ;
	Else
		Error(MsgH("EEP", "NO_WINDOW")) ;
		Return False ;
	EndIf
EndFunc   ;==>SetTrack

Func PutTrack(ByRef $gleis, $typ)
	;;	WinActivate($eep)  ;; EEP aktiviert

	If $Button[$trackeditoridx][$bid_track] = 0 Then
		Error(MsgH("EEP", "NO_TRACK_BUTTON"))
		Return False ;
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
		FatalError("Systemfehler: Falscher Gleistyp") ;
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
#include <drawing.au3>

Func Draw1Gleis(Const ByRef $gleis)
	Local $x, $y
	;;	MsgBox(0,"Gleis","Von " & $gleis[$ix] & " " & $Gleis[$iy] & " naxm " & $gleis[$ixe] & " " & $Gleis[$iye] );
	ToScreen($gleis[$ix], $gleis[$iy], $x, $y)
	GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, $x, $y)
	;; _ArrayDisplay($gleis)
	If $gleis[$irad] <> 0 Then
		Local $rad = $gleis[$irad] ;
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
			GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $x, $y)
		Next
	EndIf
	ToScreen($gleis[$ixe], $gleis[$iye], $x, $y)
	GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $x, $y)
EndFunc   ;==>Draw1Gleis

Func DrawGleis(Const ByRef $davor, Const ByRef $gleis, $anz, Const ByRef $danach)
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

	NGResetGraph()

	;GUICtrlSetGraphic($graf,$GUI_GR_HINT, 1)

	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color[0])
	Draw1Gleis($davor)

	Local $cnr = 1

	For $i = 0 To $anz - 1
		GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color[$cnr])
		Dim $hgleis[$TrackDataLen]
		For $h = 0 To $TrackDataLen - 1
			$hgleis[$h] = $gleis[$i][$h]
		Next

		If $cnr == 1 Then
			$cnr = 2
		Else
			$cnr = 1
		EndIf

		Draw1Gleis($hgleis)
	Next

	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color[0])
	Draw1Gleis($danach)

	GUICtrlSetGraphic($theGraph, $GUI_GR_REFRESH) ;
EndFunc   ;==>DrawGleis

Func Pfeil($xs, $ys, $ll, $fi, $color)
	Local $co = CosD($fi)
	Local $si = SinD($fi)

	Local $l1 = $ll * 0.15
	Local $l2 = $ll * 0.8

	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color)

	GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, $xs - $ll * $co, $ys + $ll * $si)
	GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $xs + $ll * $co, $ys - $ll * $si)
	GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $xs + $l2 * $co - $l1 * $si, $ys - $l2 * $si - $l1 * $co)
	GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $xs + $ll * $co, $ys - $ll * $si)
	GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $xs + $l2 * $co + $l1 * $si, $ys - $l2 * $si + $l1 * $co)

EndFunc   ;==>Pfeil

Func Rect($xs, $ys, $fi)
	Local $pts[10] = [-1, -1, 1, -1, 1, 1, -1, 1, -1, -1] ; Eckpunkte des Quadrats
	For $i = 0 To 9 Step 2
		Local $x = $pts[$i] * 0.075 * $xsize ;
		Local $y = $pts[$i + 1] * 0.075 * $xsize ;
		Rotate(-$fi, $x, $y)
		Shift($xs, $ys, $x, $y)
		If $i == 0 Then
			GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, $x, $y)
		Else
			GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $x, $y)
		EndIf
	Next
EndFunc   ;==>Rect

Func DrawImmo(ByRef $immopos)

	Local $fix = $immopos[$iifx]
	Local $fiy = $immopos[$iify]
	Local $fiz = $immopos[$iifz]

	NGResetGraph()

	Local $xm = $xsize * 0.5
	Local $ym = $ysize * 0.5
	Local $ll = $xsize * 0.4

	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, 0)

	;; Pfeil($xm, $ym, $ll, $fiz, 0xff0000)
	;; Pfeil($xm, $ym, $ll, $fiz + 90, 0x00ff00)

	Local $pts[1]
	;; Pfeil x
	append4($pts, -1, 0, 0, -1)
	append4($pts, 1, 0, 0, 0x00ff00)
	append3($pts, 0.9, 0.05, 0)
	append4($pts, 1, 0, 0, -1)
	append4($pts, 0.9, -0.05, 0, 0x00ff00)
	append4($pts, 1, 0, 0, -1)
	append4($pts, 0.9, 0, 0.05, 0x00ff00)
	append4($pts, 1, 0, 0, -1)
	append4($pts, 0.9, 0, -0.05, 0x00ff00)
	;; X
	append4($pts, 1.1, 0, 0, -1)
	append4($pts, 1.25, -0.3, 0, 0x00ff00)
	append4($pts, 1.25, 0, 0, -1)
	append4($pts, 1.1, -0.3, 0, 0x00ff00)

	;; Pfeil y
	append4($pts, 0, -1, 0, -1)
	append4($pts, 0, 1, 0, 0xff0000)
	append3($pts, 0.05, 0.9, 0)
	append4($pts, 0, 1, 0, -1)
	append4($pts, -0.05, 0.9, 0, 0xff0000)
	append4($pts, 0, 1, 0, -1)
	append4($pts, 0, 0.9, 0.05, 0xff0000)
	append4($pts, 0, 1, 0, -1)
	append4($pts, 0, 0.9, -0.05, 0xff0000)
	;; Y
	append4($pts, 0.1, 1, 0, -1)
	append4($pts, 0.175, 0.85, 0, 0xff0000)
	append3($pts, 0.175, 0.7, 0)
	append4($pts, 0.175, 0.85, 0, -1)
	append4($pts, 0.25, 1, 0, 0xff0000)

	;; Pfeil z
	append4($pts, 0, 0, -1, -1)
	append4($pts, 0, 0, 1, 0xff)
	append3($pts, 0.05, 0, 0.9)
	append4($pts, 0, 0, 1, -1)
	append4($pts, -0.05, 0, 0.9, 0xff)
	append4($pts, 0, 0, 1, -1)
	append4($pts, 0, 0.05, 0.9, 0xff)
	append4($pts, 0, 0, 1, -1)
	append4($pts, 0, -0.05, 0.9, 0xff)
	;; Z
	append4($pts, 0.1, -0.1, 1, -1)
	append4($pts, 0.25, -0.1, 1, 0xff)
	append3($pts, 0.1, -0.4, 1)
	append3($pts, 0.25, -0.4, 1)

	Local $c = 0.2
	append4($pts, $c, $c, $c, -1)
	append4($pts, -$c, $c, $c, 0x444444)
	append3($pts, -$c, -$c, $c)
	append3($pts, $c, -$c, $c)

	append4($pts, -$c, $c, $c, -1)
	append4($pts, -$c, $c, -$c, 0x444444)
	append3($pts, -$c, -$c, -$c)
	append3($pts, -$c, -$c, $c)

	append4($pts, -$c, $c, -$c, -1)
	append4($pts, $c, $c, -$c, 0x444444)
	append3($pts, $c, -$c, -$c)
	append3($pts, -$c, -$c, -$c)

	append4($pts, $c, $c, -$c, -1)
	append4($pts, $c, $c, $c, 0x444444)
	append3($pts, $c, -$c, $c)
	append3($pts, $c, -$c, -$c)


	drawPoly3d($pts, $immopos)

	GUICtrlSetGraphic($theGraph, $GUI_GR_REFRESH)
EndFunc   ;==>DrawImmo

Func DrawSpeed(ByRef $speed, ByRef $sspeed, $firstindex)

	Local $xs = $xsize - 10 ;
	Local $ys = $ysize - 10 ;

	NGResetGraph()

	Local $smax = 50 ;; minimale Maximalgeschwindigkeit
	For $i = 0 To $SpeedLogSize - 1
		If $speed[$i] > $smax Then
			$smax = $speed[$i]
		EndIf
		If $sspeed[$i] > $smax Then
			$smax = $sspeed[$i]
		EndIf
	Next

	Local $hx, $hy ;

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

		GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $col)

		$hy = -$i * 10 * $ys / ($smax + 1) + $ys + 5
		If $hy >= 5 Then
			If $hy <= $ys Then
				GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, 5, $hy)
				GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, 5 + $xs, $hy)
			EndIf
		EndIf
	Next

	Local $first = True

	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color[2])
	For $i = 0 To $SpeedLogSize - 1
		Local $ii = Mod($i + $firstindex, $SpeedLogSize) ;
		If $sspeed[$ii] >= 0 Then
			$hx = $xs * $i / $SpeedLogSize + 5 ;
			$hy = -$sspeed[$ii] * $ys / ($smax + 1) + $ys + 5 ;
			If $first == True Then
				GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, $hx, $hy)
				$first = False
			Else
				GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $hx, $hy)
			EndIf
		EndIf
	Next

	$first = True
	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, $color[0])
	For $i = 0 To $SpeedLogSize - 1
		Local $ii = Mod($i + $firstindex, $SpeedLogSize) ;
		If $speed[$ii] >= 0 Then
			$hx = $xs * $i / $SpeedLogSize + 5 ;
			$hy = -$speed[$ii] * $ys / ($smax + 1) + $ys + 5 ;
			If $first == True Then
				GUICtrlSetGraphic($theGraph, $GUI_GR_MOVE, $hx, $hy)
				$first = False
			Else
				GUICtrlSetGraphic($theGraph, $GUI_GR_LINE, $hx, $hy)
			EndIf
		EndIf
	Next


	GUICtrlSetGraphic($theGraph, $GUI_GR_REFRESH) ;

EndFunc   ;==>DrawSpeed

Func SetDisplay($TabSelection)
	Local $OldDisplayStat = $DisplayStat
	Switch ($TabSelection)
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
	GUICtrlSetState($TabSelection, $GUI_SHOW) ;
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
Global $NG_HEIGHT = 900
Global $NG_WIDTH = 280 ;; alt: 210

Global $NG_BORDER = 5
Global $NG_XL1 = $NG_BORDER ;; linker Rand der linken spalte
Global $NG_XL2 = ($NG_WIDTH - $NG_BORDER) / 2 ;; rechter Rand der linken spalte
Global $NG_XR1 = $NG_XL2 + $NG_BORDER ;; linker Rand der rechten spalte
Global $NG_XR2 = $NG_WIDTH - $NG_BORDER ;; rechter Rand der rechten Spalte
Global $NG_XG1 = $NG_XL1 ;; linker rand des ganzen Fensters
Global $NG_XG2 = $NG_XR2 ;; rechter Rand der ganzen Fensters

Global $NG_TABY = 0 ;
Global $NG_TABHEIGHT = 320

;; Konstanten zur Auswahl der Spalte
Global Const $NG_LEFT = 1
Global Const $NG_RIGHT = 2
Global Const $NG_BOTH = 3

Global $NG_YLA = 5 ;
Global $NG_YRA = 5 ;
;;Global $Labels[1]

;----------- Local helper functions ------------------------
Func NGGetPos($pos, ByRef $x1, ByRef $x2, ByRef $y)
	;; nächste zu verwendende Position
	Switch ($pos)
		Case $NG_LEFT
			$x1 = $NG_XL1
			$x2 = $NG_XL2
			$y = $NG_YLA ;
		Case $NG_RIGHT
			If $NG_XR1 < 0 Then
				Return True
			EndIf

			$x1 = $NG_XR1
			$x2 = $NG_XR2
			$y = $NG_YRA ;
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
			$NG_YLA = $NG_YLA + $step ;
		Case $NG_RIGHT
			$NG_YRA = $NG_YRA + $step ;
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
	NGNextPos($hheight, $NG_BOTH) ;
	$NG_TABY = $NG_YLA ;
	;;_ArrayAdd($Labels,$tab)
	Return $tab ;
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
	Local $x1, $x2, $y ;
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
	Local $x1, $x2, $y ;
	If NGGetPos($where, $x1, $x2, $y) Then
		Return 0
	EndIf
	NGNextPos($height, $where)
EndFunc   ;==>NGSpace

;;====================================================================
Func NGLabel($text, $where = $NG_LEFT, $style = 0, $size = 0)
	Local $x1, $x2, $y, $height ;
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

	GUICtrlSetFont($label, $fontt[$size]) ;

	NGNextPos($height + 2, $where)
	Return $label
EndFunc   ;==>NGLabel

Func NGList($text, ByRef $items, $where = $NG_LEFT, $lines = 0)
	Local $x1, $x2, $y, $height ;

	If NGGetPos($where, $x1, $x2, $y) Then
		Return 0
	EndIf

	$height = 16
	Local $vlines = $lines
	If $vlines > 9 Then
		$vlines = 9
	EndIf

	$height = $height * $vlines

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
	Local $x1, $x2, $y ;
	If NGGetPos($where, $x1, $x2, $y) Then
		Return 0
	EndIf

	Local $Button ;

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
	Local $x1, $x2, $y ;
	If NGGetPos($where, $x1, $x2, $y) Then
		Return 0
	EndIf

	Local $cb = GUICtrlCreateCheckbox("-", $x1 + 10, $y, $x2 - $x1 - 10) ;
	SetControl($cb, $text)

	;;_ArrayAdd($Labels,$cb)

	If $val == True Then
		GUICtrlSetState($cb, $GUI_CHECKED)
	EndIf
	NGNextPos(20, $where)
	Return $cb ;

EndFunc   ;==>NGCheckBox

Func NGSetCB($handle, $value)
	If $value Then
		GUICtrlSetState($handle, $GUI_CHECKED) ;
	Else
		GUICtrlSetState($handle, $GUI_UNCHECKED) ;
	EndIf
EndFunc   ;==>NGSetCB
;;---
Func NGRadio($text, $where = $NG_LEFT, $checked = False)
	Local $x1, $x2, $y ;
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
	Local $x1, $x2, $y ;
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
Global $theGraph
Global $graphx ;
Global $graphy ;
Global $xsize ;
Global $ysize ;

Func NGGraphic($where)
	Local $x1, $x2, $y ;
	If NGGetPos($where, $x1, $x2, $y) Then
		Return 0
	EndIf

	;;	$graphx = $x1 + 4
	$graphx = $x1 + 15
	$graphy = $y
	;;	$xsize = $x2 - $x1 - 8
	$xsize = $x2 - $x1 - 30
	$ysize = $xsize
	$theGraph = GUICtrlCreateGraphic($graphx, $graphy, $xsize, $ysize) ;
	;;_ArrayAdd($Labels,$graph)
	;;	MsgBox(0,"graph","x" & $x1 & "," & $y & " - " & $xsize & "  " & $graph);
	GUICtrlSetBkColor($theGraph, 0xffffff)
	GUICtrlSetColor($theGraph, 0)
	NGNextPos($ysize + 5, $where)
EndFunc   ;==>NGGraphic

Func NGResetGraph()
	;; Grafik rücksetzen = Löschen und Neuaufbau ermöglichen
	GUICtrlDelete($theGraph)
	$theGraph = GUICtrlCreateGraphic($graphx, $graphy, $xsize, $ysize) ;
	GUICtrlSetBkColor($theGraph, 0xffffff)
	GUICtrlSetColor($theGraph, 0)
EndFunc   ;==>NGResetGraph

;; time-Funktionen

Func time2gui($CurrentTime)
	;; Zeit in Sekunden in xx:xx:xx wandeln
	Return StringFormat("%.2d:%.2d:%.2d", Mod($CurrentTime / 3600, 24), Mod($CurrentTime / 60, 60), Mod($CurrentTime, 60)) ;
EndFunc   ;==>time2gui

Func getTime()
	#cs
		eeptimefile=io.open("time.eep","w")
		eeptimefile:write(EEPTime)
		eeptimefile:close()
	#ce
	Local $timestring = FileReadLine($EEPTimeFile)
	If @error <> 0 Then
		Return -1 ;
		;; MsgBox(0, "Time-File", $EEPTimeFile & " 	read returns " & @error);
	EndIf
	Return Number($timestring)
EndFunc   ;==>getTime

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
		GUICtrlSetData($clockbutton, MsgH("Clock", "Start")) ;
	Else
		GUICtrlSetData($clockbutton, MsgH("Clock", "Wait")) ;
	EndIf
EndFunc   ;==>SetClockMode

Func ClockButton()
	Switch $clockstate
		Case 10
			$reftime = $CurrentTime
			GUICtrlSetData($clockbutton, MsgH("Clock", "Stop")) ;
			$clockstate = 11

		Case 11
			;; stop
			GUICtrlSetData($clockbutton, MsgH("Clock", "Start")) ;
			$clockstate = 12

		Case 12
			;; start
			$reftime = $CurrentTime
			GUICtrlSetData($clockbutton, MsgH("Clock", "Stop")) ;
			$clockstate = 11

		Case 20
			;; start
			$reftime = $CurrentTime
			GUICtrlSetData($clockbutton, MsgH("Clock", "Stop"))
			$clockstate = 21

		Case 21
			;; stop
			$sumtime = $dtime
			GUICtrlSetData($clockbutton, MsgH("Clock", "Cont")) ;
			$clockstate = 22

		Case 22
			;; cont
			$reftime = $CurrentTime ;
			GUICtrlSetData($clockbutton, MsgH("Clock", "Stop")) ;
			$clockstate = 21

		Case 30
			;; start
			$reftime = $CurrentTime
			GUICtrlSetData($clockbutton, MsgH("Clock", "Wait"))
			$clockstate = 31

		Case 31
			;; stop
			GUICtrlSetData($clockbutton, MsgH("Clock", "Cont")) ;
			$clockstate = 32

		Case 32
			;; cont
			GUICtrlSetData($clockbutton, MsgH("Clock", "Wait")) ;
			$clockstate = 31

		Case 41
			;; stop
			GUICtrlSetData($clockbutton, MsgH("Clock", "Cont")) ;
			$clockstate = 42

		Case 42
			;; cont
			GUICtrlSetData($clockbutton, MsgH("Clock", "Wait"))
			$clockstate = 41 ;

	EndSwitch
EndFunc   ;==>ClockButton

Func ClockString($CurrentTime)
	;;MsgBox(0, "state", $clockstate)
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

	Local $tstring = $dtime & " s"
	If $clockdmode == "hms" Then
		$tstring = time2gui($dtime)
	EndIf
	Return $tstring

EndFunc   ;==>ClockString

Func WriteDefaultShift()
	Global $immopos, $ShiftX, $ShiftY, $doShiftXp, $doShiftXm, $doShiftYp, $doShiftYm
	IniWrite($valfile, $ImmoPos1[0], "xshift", $ShiftX) ;
	IniWrite($valfile, $ImmoPos1[0], "yshift", $ShiftY) ;
	Local $dirs = ""
	If ($doShiftXp) Then
		$dirs &= "X" ;
	EndIf
	If ($doShiftXm) Then
		$dirs &= "x" ;
	EndIf
	If ($doShiftYp) Then
		$dirs &= "Y" ;
	EndIf
	If ($doShiftYm) Then
		$dirs &= "y" ;
	EndIf
	IniWrite($valfile, $ImmoPos1[0], "shiftdir", $dirs) ;
	;; MsgBox(0,$valfile,$immopos1[0] & " shiftdir " & $dirs);
EndFunc   ;==>WriteDefaultShift

Func ReadDefaultShift()
	Global $immopos, $ShiftX, $ShiftY, $doShiftXp, $doShiftXm, $doShiftYp, $doShiftYm
	$ShiftX = IniRead($valfile, $ImmoPos1[0], "xshift", $ShiftX) ;
	GUICtrlSetData($shiftxinput, $ShiftX) ;
	$ShiftY = IniRead($valfile, $ImmoPos1[0], "yshift", $ShiftY) ;
	GUICtrlSetData($shiftyinput, $ShiftY) ;

	Local $dirs = IniRead($valfile, $ImmoPos1[0], "shiftdir", "") ;
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

Func mkImmoDataDisplay()
	Local $handle[7]
	$handle[0] = NGLabel(".....................", $NG_BOTH) ;
	$handle[1] = NGLabel(MsgH("ImmoTab", "x") & ": ", $NG_LEFT) ;
	$handle[4] = NGLabel(MsgH("ImmoTab", "anglex") & ": ", $NG_RIGHT) ;
	$handle[2] = NGLabel(MsgH("ImmoTab", "y") & ": ", $NG_LEFT) ;
	$handle[5] = NGLabel(MsgH("ImmoTab", "angley") & ": ", $NG_RIGHT) ;
	$handle[3] = NGLabel(MsgH("ImmoTab", "z") & ": ", $NG_LEFT) ;
	$handle[6] = NGLabel(MsgH("ImmoTab", "anglez") & ": ", $NG_RIGHT) ;
	Return $handle
EndFunc   ;==>mkImmoDataDisplay

Func showimmodata($handle, ByRef $immo)
	GUICtrlSetData($handle[0], $immo[0]) ;
	GUICtrlSetData($handle[1], MsgH("ImmoTab", "x") & ": " & $immo[$iix]) ;
	GUICtrlSetData($handle[2], MsgH("ImmoTab", "y") & ": " & $immo[$iiy]) ;
	GUICtrlSetData($handle[3], MsgH("ImmoTab", "z") & ": " & $immo[$iiz]) ;
	GUICtrlSetData($handle[4], MsgH("ImmoTab", "anglex") & ": " & Round($immo[$iifx], 1) & "°") ;
	GUICtrlSetData($handle[5], MsgH("ImmoTab", "anglex") & ": " & Round($immo[$iify], 1) & "°") ;
	GUICtrlSetData($handle[6], MsgH("ImmoTab", "anglex") & ": " & Round($immo[$iifz], 1) & "°") ;
EndFunc   ;==>showimmodata

;; display-funktionen
Func trackdatadisplay($where)
	Local $handle[6]
	$handle[0] = NGLabel(MsgH("Tracktab", "x") & ": ", $where) ;
	$handle[1] = NGLabel(MsgH("Tracktab", "y") & ": ", $where) ;
	$handle[2] = NGLabel(MsgH("Tracktab", "dir") & ": ", $where) ;
	$handle[3] = NGLabel(MsgH("Tracktab", "length") & ": ", $where) ;
	$handle[4] = NGLabel(MsgH("Tracktab", "angle") & ": ", $where) ;
	$handle[5] = NGLabel(MsgH("Tracktab", "height1") & ": ", $where) ;
	Return $handle
EndFunc   ;==>trackdatadisplay

Func showtrackdata($handle, $track)
	GUICtrlSetData($handle[0], MsgH("Tracktab", "x") & ": " & $track[$ix]) ;
	GUICtrlSetData($handle[1], MsgH("Tracktab", "y") & ": " & $track[$iy]) ;
	GUICtrlSetData($handle[2], MsgH("Tracktab", "dir") & ": " & Round($track[$idir], 1) & "°") ;
	GUICtrlSetData($handle[3], MsgH("Tracktab", "length") & ": " & $track[$ilen]) ;
	GUICtrlSetData($handle[4], MsgH("Tracktab", "angle") & ": " & Round($track[$iangle], 1) & "°") ;
	GUICtrlSetData($handle[5], MsgH("Tracktab", "height1") & ": " & $track[$ih1]) ;
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
		GUICtrlSetState($inverse1cb, $GUI_CHECKED) ;
		;;GUICtrlSetState($csinverse1cb, $GUI_CHECKED);
	Else
		GUICtrlSetState($inverse1cb, $GUI_UNCHECKED) ;
		;;GUICtrlSetState($csinverse1cb, $GUI_UNCHECKED);
	EndIf

	If $nullflag Then
		GUICtrlSetState($null1cb, $GUI_CHECKED) ;
		;;GUICtrlSetState($csnull1cb, $GUI_CHECKED);
	Else
		GUICtrlSetState($null1cb, $GUI_UNCHECKED) ;
		;;GUICtrlSetState($csnull1cb, $GUI_UNCHECKED);
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
	ErgaenzeGleis($gleis) ;
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
	For $k = 1 To $IstGleisAnz - 1
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
					ControlCommand($h, "", 1097, "Check") ;// direction 1
				Case Asc("F")
					ControlCommand($h, "", 1097, "UnCheck") ;// direction 1
				Case Asc("b")
					ControlCommand($h, "", 1098, "Check") ;// direction 2
				Case Asc("B")
					ControlCommand($h, "", 1098, "UnCheck") ;// direction 2
				Case Asc("e")
					ControlCommand($h, "", 1099, "Check") ;// end of train
				Case Asc("E")
					ControlCommand($h, "", 1099, "UnCheck") ;// end of train
				Case Asc("g")
					SetEffekt($h, 1) ; // Go
				Case Asc("s")
					SetEffekt($h, 2) ; // stop
				Case Asc("i")
					SetEffekt($h, 0) ; // inverse == "Umschalter"
				Case Asc("x")
					ControlClick($h, "", 1, "left") ;
				Case Asc("0") To Asc("9")
					$val = $val * 10 + $c - Asc("0")
				Case Asc("m")
					;; vielfache setzen
					ControlSetText($h, "", 1463, $val) ;
					$val = 0
				Case Asc("l")
					;; light
					;; MsgBox(0,"Licht",$val);
					Switch $val
						Case 0
							ControlCommand($h, "", 1100, "UnCheck") ;// light
						Case 1
							ControlCommand($h, "", 1100, "Check") ;// light
						Case 2
							;;ControlDisable($h,"",1100);// light
					EndSwitch

				Case Asc("t")
					;; Verzögerung setzen
					ControlSetText($h, "", 1492, $val) ;
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
					ControlCommand($h, "", 1097, "Check") ;// direction 1
				Case Asc("F")
					ControlCommand($h, "", 1097, "UnCheck") ;// direction 1
				Case Asc("b")
					ControlCommand($h, "", 1098, "Check") ;// direction 2
				Case Asc("B")
					ControlCommand($h, "", 1098, "UnCheck") ;// direction 2
				Case Asc("e")
					ControlCommand($h, "", 1099, "Check") ;// end of train
				Case Asc("E")
					ControlCommand($h, "", 1099, "UnCheck") ;// end of train
				Case Asc("g")
					SetEffekt($h, 0) ; // Go
				Case Asc("s")
					SetEffekt($h, 1) ; // stop
				Case Asc("i")
					SetEffekt($h, -1) ; // inverse
				Case Asc("0") To Asc("9")
					$val = $val * 10 + $c - Asc("0")
				Case Asc("m")
					;; vielfache setzen
					ControlSetText($h, "", 1463, $val) ;
					$val = 0
				Case Asc("l")
					;; light
					Switch $val
						Case 0
							ControlCommand($h, "", 1100, "UnCheck") ;// light
						Case 1
							ControlCommand($h, "", 1100, "Check") ;// light
						Case 2
							;;ControlDisable($h,"",1100);// light
					EndSwitch

				Case Asc("t")
					;; Verzögerung setzen
					ControlSetText($h, "", 1463, $val) ;
					$val = 0
				Case Asc("x")
					ControlClick($h, "", 1, "left") ;
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

Func Track2Immo(ByRef $track, ByRef $immo)
	$immo[$iiname] = ""

	$immo[$iix] = $StartGleis[$ix]
	$immo[$iiy] = $StartGleis[$iy]
	$immo[$iiz] = $StartGleis[$ih1]

	$immo[$iizr] = 0 ; relative height unknown

	$immo[$iifx] = 0
	$immo[$iify] = 0
	$immo[$iifz] = $StartGleis[$idir]

	$immo[$iiscx] = 1
	$immo[$iiscy] = 1
	$immo[$iiscz] = 1

	$immo[$iilight] = False
EndFunc   ;==>Track2Immo

;; Fahrplanfunktionen

Func OpenTimeTable()
	Local $FahrplanName
	Local $aFile = _WinAPI_GetOpenFileName(MsgH("TimeTable", "selection"), MsgH("TimeTable", "pattern"))
	;;_ArrayDisplay($aFile)
	If $aFile[0] = 0 Then
		Local $sError = _WinAPI_CommDlgExtendedError()
		MsgBox(0, "Error", "CommDlgExtendedError (" & @error & "): " & $sError)
	Else
		If $aFile[0] <> 2 Or $aFile[1] == "" Then
			;;MsgBox(0, "Error", "Keine Datei ausgewählt", 2)
			$FahrplanName = "<undefined>"
		Else
			$FahrplanName = $aFile[1] & "\" & $aFile[2] ;
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
		Exit 1 ;
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

	$plan = 1 ;; no Array !
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
	#cs
		If $val < 10 Then
		Return "0" & Int($val)
		Else
		Return Int($val)
		EndIf
	#ce
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
				$route[$i] = $aplan[$i][0] ;
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
	$name = $newname ;
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
	Local $tt_select = $route - 1 ;

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
		MsgBox(0, "Instanz existiert", "Hugo läuft schon!", 2) ;
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
	;; check if eep is running

	If WinExists($main_title) Then
		;; MsgBox(0, "OK", "Eisenbahn.exe läuft schon", 1)
		;; else try to start
	Else
		FatalError(MsgH("EEP", "NOT_STARTED"))
	EndIf

	;;	MsgBox(1, "Wait", "Waiting for Mainscreen", 11);
	WinWait($main_title)

	$eep = WinGetHandle($main_title)

	;MsgBox(1,"description",$description);
	Local $ct = 0
	;; mindestens 6 mal Text "fertig" finden
	While $ct < 6
		Local $tt = WinGetTitle($eep, $status_ready) ;
		If $tt Then
			$ct = $ct + 1
			;;MsgBox(1,"fertig?",$ct & " " & $status_ready & " in " & $tt, 1);
		Else
			$ct = 0 ;
		EndIf
		AutoOK()
		Sleep(300)
	WEnd

	Local $cname
	Local $hnd

	Local $EditorHnd[4] = [0, 0, 0, 0]

	$i = 1 ;
	Local $parent
	Local $id
	Local $text
	Local $idtext
	Do
		$cname = "Button" & $i
		$hnd = ControlGetHandle($eep, "", $cname) ;
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
		$i = $i + 1 ;
	Until Not $hnd

	;;_ArrayDisplay($idtextarray)
	;;_ArrayDisplay($EditorHnd)

	NGResetGraph()

	GUICtrlSetGraphic($theGraph, $GUI_GR_COLOR, 0)

	;; buttons identifizieren
	Dim $barray[1][5]
	Local $edit = -1 ;
	Local $pos ;
	$i = 1 ;
	Do
		;;$cname = "Button" & $i
		$cname = "[CLASS:Button; INSTANCE:" & $i & "]" ;
		$hnd = ControlGetHandle($eep, "", $cname) ;
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
		$i = $i + 1 ;
	Until Not $hnd

	;; WinActivate($eep)
	;;	MsgBox(0, "Debug", "OpenEEP fertig");

EndFunc   ;==>OpenEEP

;; create gui

Global $gui = NGCreate()
Global $tab = NGCreateTab()

$TrackTab = NGCreateTabItem(MsgH("GUI", "TabTrack"))
;;#include "g_track.au3"

Global $davorbutton = NGButton(MsgH("Tracktab", "before"), $NG_LEFT)
Global $danachbutton = NGButton(MsgH("Tracktab", "after"), $NG_RIGHT) ;

Global $inverse1cb = NGCheckBox(MsgH("Tracktab", "inverse"), $NG_LEFT, False) ;
Global $null1cb = NGCheckBox(MsgH("Tracktab", "Stub"), $NG_RIGHT, False) ;

Global $invflag = False
Global $nullflag = False

NGDel($NG_BOTH)
Global $gleisanzInput = NGInput(MsgH("Tracktab", "Tracks"), $SollGleisAnz, $NG_LEFT, 1) ;
Global $radinput = NGInput(MsgH("Tracktab", "Rad"), $TrackRad, $NG_RIGHT) ;
If ($mode < 4) Then
	GUICtrlSetState($radinput, $GUI_DISABLE)
EndIf

Global $maxleninput = NGInput(MsgH("Tracktab", "maxlen"), $TrackMaxLen, $NG_BOTH) ;

NGLabel(MsgH("TrackTab", "Construction"), $NG_BOTH)
Global $modecombo = NGCombo($ModeList, $NG_BOTH)
If $mode > 0 And $mode < 6 Then
	NGComboUpdate($modecombo, $ModeList[$mode - 1])
EndIf

Global $tistanz = NGLabel(MsgH("Tracktab", "TracknumberUnknown"), $NG_BOTH)
Global $tlen = NGLabel(MsgH("Tracktab", "LengthUnknown"), $NG_LEFT)
Global $trad = NGLabel(MsgH("TrackTab", "RadiusUnknown"), $NG_LEFT)

Global $txx = NGLabel("X: ?", $NG_RIGHT)
Global $tyy = NGLabel("Y: ?", $NG_RIGHT)

NGSpace(5, $NG_LEFT)
Global $PutTrackButton = NGButton(MsgH("TrackTab", "PutTracks"), $NG_LEFT) ;

Global $levelcb = NGCheckBox(MsgH("Tracktab", "Levelling"), $NG_RIGHT, $level) ;
Global $copycb = NGCheckBox(MsgH("Tracktab", "2tracks"), $NG_RIGHT, $copy) ;

Global $dxinput = NGInput(MsgH("Tracktab", "ShiftX"), $track_shift_x, $NG_BOTH) ;
Global $dhinput = NGInput(MsgH("Tracktab", "ShiftH"), $track_shift_h, $NG_BOTH) ;
Global $samftcb = NGCheckBox(MsgH("Tracktab", "Sanft"), $NG_BOTH, $samft)

$Track2Tab = NGCreateTabItem(MsgH("GUI", "TabTrack2")) ;
;;#include "g_track2.au3"

Global $replacebutton = NGButton(MsgH("Tracktab", "Replace"), $NG_LEFT) ;
Global $replaceinversecb = NGCheckBox(MsgH("Tracktab", "ReplaceInverse"), $NG_LEFT, False) ;

Global $dx2input = NGInput(MsgH("Tracktab", "ShiftX"), $track2_shift_x, $NG_BOTH) ;
Global $dh2input = NGInput(MsgH("Tracktab", "ShiftH"), $track2_shift_h, $NG_BOTH) ;

Global $replaceremovecb = NGCheckBox(MsgH("Tracktab", "ReplaceRemove"), $NG_LEFT, True) ;

Global $replacechangeeditorcb = NGCheckBox(MsgH("Tracktab", "ReplaceChangeEditor"), $NG_LEFT, False) ;
Global $replaceeditorcombo = NGCombo($TrackEditorList, $NG_BOTH)
NGComboUpdate($replaceeditorcombo, $editor_track)

$ImmoTab = NGCreateTabItem(MsgH("GUI", "TabImmo")) ;
;;#include "g_immo.au3"
$getposbutton = NGButton(MsgH("ImmoTab", "GetPos"))

NGDel($NG_BOTH) ;
;;NGSpace(10,$NG_BOTH)

$immodata = mkImmoDataDisplay()

NGDel($NG_BOTH) ;
;;NGSpace(10,$NG_BOTH)

$shiftxinput = NGInput(MsgH("ImmoTab", "DeltaX"), $ShiftX) ;

$shiftxpcb = NGCheckBox(MsgH("ImmoTab", "East"), $NG_RIGHT, $doShiftXp) ;
$shiftxmcb = NGCheckBox(MsgH("ImmoTab", "West"), $NG_RIGHT, $doShiftXm) ;

NGSpace(5, $NG_BOTH)

$shiftyinput = NGInput(MsgH("ImmoTab", "DeltaY"), $ShiftY) ;

$shiftypcb = NGCheckBox(MsgH("ImmoTab", "North"), $NG_RIGHT, $doShiftYp) ;
$shiftymcb = NGCheckBox(MsgH("ImmoTab", "South"), $NG_RIGHT, $doShiftYm) ;

NGSpace(5, $NG_BOTH)

$shiftzinput = NGInput(MsgH("ImmoTab", "DeltaZ"), $ShiftZ) ;

$shiftzpcb = NGCheckBox(MsgH("ImmoTab", "Up"), $NG_RIGHT, $doShiftZp) ;
$shiftzmcb = NGCheckBox(MsgH("ImmoTab", "Down"), $NG_RIGHT, $doShiftZm) ;

NGSpace(5, $NG_BOTH)

$setposbutton = NGButton(MsgH("ImmoTab", "SetPos")) ;
$hrelcb = NGCheckBox(MsgH("ImmoTab", "HightRel"), $NG_RIGHT, $hrel) ;

$save_as_default_cb = NGCheckBox(MsgH("ImmoTab", "AsDefault"), $NG_RIGHT, False) ;


$TTTab = NGCreateTabItem(MsgH("GUI", "TabTT")) ;
;;#include "g_timetable.au3"
;; tab für fahrplan

Local $label = $tt_file
If StringLen($label) > 35 Then
	$label = "..." & StringRight($tt_file, 32)
EndIf

Global $lbl_tt = NGLabel($label, $NG_BOTH, $SS_CENTER)
;;Global $cb_ttEnable = NGCheckBox("grafischer Fahrplan", $NG_BOTH, False)
Global $lbl_halt = NGLabel(MsgH("TimeTable", "laststop"), $NG_LEFT)
Global $lbl_start = NGLabel(MsgH("TimeTable", "laststart"), $NG_RIGHT)
;;Global $lbl_current = NGLabel("**", $NG_BOTH)
;;Global $lbl_last = NGLabel("**",$NG_BOTH)

Local $dummy = MsgH("TimeTable", "routes")
$tt_route = NGCombo($dummy, $NG_BOTH)

Global $tt_item

Global $list_tt = NGList(MsgH("TimeTable", "ListHead"), $tt_item, $NG_BOTH, 25)
If UBound($tt_plan) > 0 Then
	UpdatePlan($tt_item, $tt_plan, $tt_selected_route, -1)
EndIf

Global $tt_edit = NGButton(MsgH("TimeTable", "edit"), $NG_LEFT) ;
Global $tt_menu = NGButton(MsgH("TimeTable", "menu"), $NG_RIGHT)
Global $tt_set_arrival = NGButton(MsgH("TimeTable", "setarrival"), $NG_LEFT) ;
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

$SignalTab = NGCreateTabItem(MsgH("GUI", "TabSignal")) ;
;;#include "g_sign.au3"
;; tab für signaltool

Global $signbutton1 = NGButton($mtext_signal_button1, $NG_BOTH) ;
Global $signbutton2 = NGButton($mtext_signal_button2, $NG_BOTH) ;
Global $signbutton3 = NGButton($mtext_signal_button3, $NG_BOTH) ;
Global $signbutton4 = NGButton($mtext_signal_button4, $NG_BOTH) ;

$OptionTab = NGCreateTabItem(MsgH("GUI", "TabOption")) ;

;;#include "g_option.au3"
;; NGLabel($mtext_general_options,$NG_BOTH)

;; create version label
;; handle is used to activate eep (via hotkey)
Global $activate_eep = NGLabel("V. " & $Version & " - EEP " & $EEPVersionReal, $NG_BOTH, $SS_CENTER + $SS_SUNKEN) ;
NGDel($NG_BOTH, $SS_BLACKFRAME, 5) ;

WinSetTitle($gui, "", $PName & " " & $Version)

Global $auto_ok_cb = NGCheckBox(MsgH("GUI", "AutoOk"), $NG_BOTH, BitTest($auto_ok, 1))
Global $raster_ok_cb = NGCheckBox(MsgH("GUI", "RasterOk"), $NG_BOTH, BitTest($auto_ok, 4))
Global $auto_val_cb = NGCheckBox(MsgH("ImmoTab", "AutoValue"), $NG_BOTH, $auto_val) ;

NGDel($NG_BOTH, $SS_BLACKFRAME, 5) ;

NGLabel(MsgH("GUI", "Clock"), $NG_BOTH)

GUIStartGroup()
Global $clock_start_stop_rad = NGRadio(MsgH("Clock", "StartStopMode"), $NG_LEFT, $clockmode == "start_stop")
Global $clock_start_cont_rad = NGRadio(MsgH("Clock", "StartContMode"), $NG_LEFT, $clockmode == "start_cont")
Global $clock_lap_rad = NGRadio(MsgH("Clock", "LapMode"), $NG_RIGHT, $clockmode == "lap")
Global $clock_life_rad = NGRadio(MsgH("Clock", "LifeMode"), $NG_RIGHT, $clockmode == "life")

NGSpace(5, $NG_BOTH)
;;Func NGInput($text, $itext, $where = $NG_LEFT, $pm = 0)

Global $clock_modulo_input = NGInput(MsgH("Clock", "Cycle"), $clockmodulo, $NG_LEFT)
Global $clock_hmsmode_cb = NGCheckBox("hh:mm:ss", $NG_RIGHT, $clockdmode == "hms")

NGSpace(5, $NG_BOTH)

;;NGSpace(5, $NG_BOTH)

NGDel($NG_BOTH)

Global $winposlabel = NGLabel(MsgH("Options", "WindowPosition"), $NG_LEFT)
Global $winposbutton = NGButton(MsgH("Options", "SaveWindowPosition"), $NG_RIGHT)

NGDel($NG_BOTH)

Global $speedloglabel = NGLabel(MsgH("Options", "SpeedLog"), $NG_BOTH)
GUIStartGroup()
Global $speedlog2 = NGRadio(MsgH("Options", "2min"), $NG_LEFT, $LogStep == 1)
Global $speedlog4 = NGRadio(MsgH("Options", "4min"), $NG_LEFT, $LogStep == 2)
Global $speedlog8 = NGRadio(MsgH("Options", "8min"), $NG_RIGHT, $LogStep == 4)
Global $speedlog16 = NGRadio(MsgH("Options", "16min"), $NG_RIGHT, $LogStep == 8)
NGDel($NG_BOTH)
NGLabel("LUA-Timecode", $NG_LEFT)
Global $copytimecode = NGButton("Copy", $NG_RIGHT)

NGCreateTabItem("") ;

NGGraphic($NG_BOTH)

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

Local $actionmsglist[47] = [$clockbutton, _
		$davorbutton, $danachbutton, $PutTrackButton, _
		$replacebutton, _
		$getposbutton, $setposbutton, _
		$inverse1cb, $null1cb, _
		$clock_start_stop_rad, $clock_start_cont_rad, $clock_lap_rad, _
		$clock_reset_button, _
		$signbutton1, $signbutton2, $signbutton3, $signbutton4, _
		$TrackTab, $Track2Tab, $ImmoTab, $SignalTab, $OptionTab, _
		$tt_set_arrival, $tt_set_departure, _
		$activate_hugo, $activate_eep, _
		$quitbutton]

Global $actionlist[47] = ["clock", _
		"before", "after", "puttrack", _
		"replacetrack", _
		"getobject", "setobject", _
		"inverse", "null", _
		"clockstartstop", "clockstartcont", "clocklap", _
		"clockreset", _
		"signal1", "signal2", "signal3", "signal4", _
		"tabtrack", "tabtrack2", "tabobject", "tabsignal", "taboptions", _
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
OpenEEP() ;

;; Größen an Bildschirm anpassen
$ScreenSize = WinGetPos("Program Manager")

If ValidWindowPos($eeppos) Then
	WinMove($eep, "", $eepleft, $eeptop, $eepwidth, $eepheight, 10)
EndIf

;; WinActivate($eep)

SetTab($TrackTab)

SpeedlogReset()

HotkeysOn()

Do
	If TimerDiff($begin) > 1000 Then

		;; Editor ermitteln, GUI anpassen
		$editor = GetEditor()
		If $editor <> $oldeditor Then
			SetEditorVars($editor)
			$oldeditor = $editor
			$DisplayNeedsRedraw = 1
		EndIf

		;; clock / stopwatch
		Local $t = getTime()
		If $t >= 0 Then
			$CurrentTime = $t
			$CurrentTimeMod = $CurrentTime
			If $clockmode == "life" Then
				If $clockmodulo > 0 Then
					$CurrentTimeMod = Mod($CurrentTime, $clockmodulo)
				EndIf
			EndIf
		EndIf
		;; MsgBox(0, "Time", ClockString($CurrentTime))
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
					$logcount = $logcount + 1
					If $logcount >= $LogStep Then
						$logcount = 0

						$speed[$LastIndex] = $actualspeedval
						$sspeed[$LastIndex] = $targetspeedval

						$LastIndex = Mod($LastIndex + 1, $SpeedLogSize)

						$DisplayNeedsRedraw = 1

						$lasttime = $CurrentTime ;
					EndIf
				EndIf
			EndIf

		Else
			If $DisplayStat == $SpeedDisplay Then
				$DisplayStat = $LastDisplay
			EndIf
		EndIf

		;; Berechnung notwendig?
		If $trackCalculated == 0 Then

			;; Gleisdaten ungültig
			GUICtrlSetColor($tistanz, 0xff0000)
			GUICtrlSetColor($tlen, 0xff0000)
			GUICtrlSetColor($trad, 0xff0000)

			GUICtrlSetData($tlen, MsgH("GUI", "Please"))
			GUICtrlSetData($trad, MsgH("GUI", "Wait"))

			$trackstatus = Optimize($StartGleis, $EndGleis, $Verbindung, $mode)
			;; trackstatus < 0 = Berechnung fehlgeschlagen

			$trackCalculated = 1

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

				GUICtrlSetData($tistanz, StringFormat(MsgH("Tracktab", "TrackNumber"), $IstGleisAnz))

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
				GUICtrlSetData($tistanz, StringFormat(MsgH("Tracktab", "TrackNumber"), $IstGleisAnz))
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
						DrawGleis($StartGleis, $Verbindung, $IstGleisAnz, $EndGleis)
					Else
						DrawGleis($StartGleis, $Verbindung, 0, $EndGleis)
					EndIf

				Case $ImmoDisplay
					DrawImmo($ImmoPos1)

				Case $SpeedDisplay
					DrawSpeed($speed, $sspeed, $LastIndex)
			EndSwitch
			$DisplayNeedsRedraw = 0
		EndIf

		If (Not WinExists($eep)) Then
			$msg = $GUI_EVENT_CLOSE
		EndIf

		;; automization
		AutoOK()

		$begin = TimerInit()
	EndIf ;; // Time

	;; gui event ?
	If ($msg = 0) Then
		$msg = GUIGetMsg()
		;;if $msg = $GUI_EVENT_CLOSE Then
		;; MsgBox(0,"got close",$msg)
		;;EndIf
	EndIf

	If $msg <> 0 Then

		Switch $msg
			;; Gleis tab
			Case $davorbutton
				If $trackeditoridx >= 0 Then
					If GetTrackData($StartGleis, GUICtrlRead($null1cb) == $GUI_CHECKED) Then

						If GUICtrlRead($null1cb) == $GUI_CHECKED Then
							SetLenToNull($StartGleis)
						Else
							If GUICtrlRead($inverse1cb) == $GUI_CHECKED Then
								InvertiereGleis($StartGleis) ;
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
						$iValid = True ;
						showimmodata($immodata, $ImmoPos1) ;
						$trackCalculated = 0
						$DisplayNeedsRedraw = 1
					Else

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
								InvertiereGleis($EndGleis) ;
							EndIf
						EndIf

						GUICtrlSetTip($danachbutton, trackdatastring($EndGleis))

						ResetFlags()

						;; Verschiebung rücksetzen
						$track_shift_x = 0
						$track_shift_h = 0
						GUICtrlSetData($dxinput, $track_shift_x)
						GUICtrlSetData($dhinput, $track_shift_h)

						$trackCalculated = 0
					EndIf
				Else
					Error(MsgH("EEP", "no_track_editor"))
				EndIf

			Case $PutTrackButton
				SetTab($TrackTab)
				If $trackeditoridx >= 0 Then
					If $trackCalculated == 1 Then
						If $trackstatus == 1 Then
							WinActivate($eep)
							For $gnr = $IstGleisAnz - 1 To 0 Step -1

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
									;; "Check" wirkt als Umschalter und wechselt ständig. Muss manuell aktiviert/deaktiviert Werden
									;; ControlCommand($eep, "", $Button[$trackeditoridx][$bid_inv], "check"); umkehren
									;; MsgBox(0,"PutTrack","invers" & ControlCommand($eep,"",$Button[$trackeditoridx][$bid_inv], "IsChecked"));
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
								Error(MsgH("EEP", "track_too_long") & $maxlen & " m!" & @CRLF & MsgH("EEP", "track_too_long2")) ;
							Else
								If $minlen < 1 Then
									Error(MsgH("EEP", "track_too_short") & $minlen & " m!" & @CRLF & MsgH("EEP", "track_too_short2")) ;
								EndIf
							EndIf
						EndIf ; // $valid
					EndIf ; $trackCalculated
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

				$trackCalculated = 0
				GUICtrlSetData($gleisanzInput, $SollGleisAnz)

			Case $copycb
				$copy = GUICtrlRead($copycb) == $GUI_CHECKED

			Case $levelcb
				$level = GUICtrlRead($levelcb) == $GUI_CHECKED

			Case $samftcb
				If GUICtrlRead($samftcb) == $GUI_CHECKED Then
					$samft = True
				Else
					$samft = False
				EndIf
				$trackCalculated = 0

			Case $inverse1cb
				$invflag = Not $invflag
				SetFlags()

			Case $null1cb
				$nullflag = Not $nullflag
				SetFlags()

			Case $modecombo
				Local $stat = ControlCommand($gui, "", $modecombo, "GetCurrentSelection")
				Local $mode = ControlCommand($gui, "", $modecombo, "FindString", $stat) + 1 ;
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
				$trackCalculated = 0

			Case $radinput
				InputNumber($radinput, $TrackRad)
				$trackCalculated = 0

			Case $maxleninput
				InputNumber($maxleninput, $TrackMaxLen)
				$trackCalculated = 0

			Case $dxinput
				InputNumber($dxinput, $track_shift_x)

			Case $dhinput
				InputNumber($dhinput, $track_shift_h)

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
							Local $sel = ControlCommand($gui, "", $replaceeditorcombo, "FindString", $stat) ;

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
				Local $tt_selected_route = ControlCommand($gui, "", $tt_route, "FindString", $tt_route_stat) + 1 ;
				UpdatePlan($tt_item, $tt_plan, $tt_selected_route, 0)
				_GUICtrlListView_SetItemSelected($list_tt, 0, True, True)
				_GUICtrlListView_EnsureVisible($list_tt, 0)

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
						_GUICtrlListView_EnsureVisible($list_tt, $selected_item + 1)
					EndIf
				EndIf

			Case $tt_menu
				If $tt_submenu == 0 Then
					$tt_submenu = GUICreate(MsgH("TimeTable", "subMenu"), 300, 400, -1, -1, $DS_MODALFRAME) ;
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
				;; immobilien tab
			Case $getposbutton
				SetTab($ImmoTab)
				If $objeditoridx >= 0 Then
					Local $oldname = $ImmoPos1[0] ;
					GetImmoData($ImmoPos1, False)
					showimmodata($immodata, $ImmoPos1) ;
					If $ImmoPos1[0] <> $oldname Then
						If $auto_val Then
							;; versuchen, Verschiebungswerte zu laden
							ReadDefaultShift() ;
						EndIf
					EndIf
					$iValid = True ;
					$DisplayNeedsRedraw = 1
				Else
					Error(MsgH("EEP", "no_obj_editor"))
				EndIf

			Case $shiftxpcb
				$doShiftXp = GUICtrlRead($shiftxpcb) == $GUI_CHECKED
				If ($doShiftXp) Then
					$doShiftXm = False
					GUICtrlSetState($shiftxmcb, $GUI_UNCHECKED) ;
				EndIf

			Case $shiftxmcb
				$doShiftXm = GUICtrlRead($shiftxmcb) == $GUI_CHECKED
				If ($doShiftXm) Then
					$doShiftXp = False
					GUICtrlSetState($shiftxpcb, $GUI_UNCHECKED) ;
				EndIf

			Case $shiftypcb
				$doShiftYp = GUICtrlRead($shiftypcb) == $GUI_CHECKED
				If ($doShiftYp) Then
					$doShiftYm = False
					GUICtrlSetState($shiftymcb, $GUI_UNCHECKED) ;
				EndIf

			Case $shiftymcb
				$doShiftYm = GUICtrlRead($shiftymcb) == $GUI_CHECKED
				If ($doShiftYm) Then
					$doShiftYp = False
					GUICtrlSetState($shiftypcb, $GUI_UNCHECKED) ;
				EndIf

			Case $shiftzpcb
				$doShiftZp = GUICtrlRead($shiftzpcb) == $GUI_CHECKED
				If ($doShiftZp) Then
					$doShiftZm = False
					GUICtrlSetState($shiftzmcb, $GUI_UNCHECKED) ;
				EndIf

			Case $shiftzmcb
				$doShiftZm = GUICtrlRead($shiftzmcb) == $GUI_CHECKED
				If ($doShiftZm) Then
					$doShiftZp = False
					GUICtrlSetState($shiftzpcb, $GUI_UNCHECKED) ;
				EndIf

			Case $setposbutton
				SetTab($ImmoTab)
				If $objeditoridx >= 0 Then
					If $iValid == False Then
						Error("Position ungültig")
					Else
						Local $dx = 0
						Local $dy = 0
						Local $dz = 0

						If $doShiftXp Then
							$dx = $ShiftX
						EndIf
						If $doShiftXm Then
							$dx = -$ShiftX
						EndIf

						If $doShiftYp Then
							$dy = $ShiftY
						EndIf
						If $doShiftYm Then
							$dy = -$ShiftY
						EndIf

						If $doShiftZp Then
							$dz = $ShiftZ
						EndIf
						If $doShiftZm Then
							$dz = -$ShiftZ
						EndIf

						RotateXYZ($ImmoPos1[$iifx], $ImmoPos1[$iify], $ImmoPos1[$iifz], $dx, $dy, $dz)
						#cs
							;; rotation about x axis
							Local $si = Sin($degToRad * $ImmoPos1[$iifx])
							Local $co = Cos($degToRad * $ImmoPos1[$iifx])

							local $dy2 = $dy * $co - $dz * $si
							local $dz2 = $dy * $si + $dz * $co

							;; rotation about y axis
							$si = Sin($degToRad * $ImmoPos1[$iify]);
							$co = Cos($degToRad * $ImmoPos1[$iify]);

							local $dx3 = $dx * $co + $dz2 * $si
							local $dz3 = - $dx * $si + $dz2 * $co

							;; rotation about z axis
							$si = Sin($degToRad * $ImmoPos1[$iifz]);
							$co = Cos($degToRad * $ImmoPos1[$iifz]);

							local $dx4 = $dx3 * $co - $dy2 * $si
							local $dy4 = $dx3 * $si + $dy2 * $co

							$ImmoPos1[$iix] += $dx4;
							$ImmoPos1[$iiy] += $dy4;
							$ImmoPos1[$iiz] += $dz3;
						#ce
						$ImmoPos1[$iix] += $dx ;
						$ImmoPos1[$iiy] += $dy ;
						$ImmoPos1[$iiz] += $dz ;

						Local $oldname = $ImmoPos1[0] ;
						If (SetImmoData($ImmoPos1, $hrel)) Then
							showimmodata($immodata, $ImmoPos1) ;
							Local $save_as_default = GUICtrlRead($save_as_default_cb) == $GUI_CHECKED ;
							If $save_as_default Then
								WriteDefaultShift()
								$save_as_default = False
								NGSetCB($save_as_default_cb, False) ;
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

			Case $shiftzinput
				$ShiftZ = GUICtrlRead($shiftzinput)
				GUICtrlSetData($shiftzinput, $ShiftZ)

			Case $hrelcb
				$hrel = GUICtrlRead($hrelcb) == $GUI_CHECKED
				;; signal/contact-tool

			Case $signbutton1
				WinActivate($eep)
				SetContact($setting_signal_button1)

			Case $signbutton2
				WinActivate($eep)
				SetContact($setting_signal_button2)

			Case $signbutton3
				WinActivate($eep)
				SetContact($setting_signal_button3)

			Case $signbutton4
				WinActivate($eep)
				SetContact($setting_signal_button4)

				;;			#include "h_option.au3"
			Case $auto_ok_cb
				If GUICtrlRead($auto_ok_cb) == $GUI_CHECKED Then
					BitSet($auto_ok, 1)
				Else
					BitReset($auto_ok, 1)
				EndIf

			Case $raster_ok_cb
				If GUICtrlRead($raster_ok_cb) == $GUI_CHECKED Then
					BitSet($auto_ok, 6)
				Else
					BitReset($auto_ok, 6)
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

			Case $copytimecode
				;;Local $tc = 'eeptimefile=io.open("' & $EEPTimeFile & '","w")' & @CRLF
				Local $tc = 'eeptimefile=io.open("time.eep","w")' & @CRLF
				$tc = $tc & 'eeptimefile:write(EEPTime)' & @CRLF
				$tc = $tc & 'eeptimefile:close()'
				ClipPut(StringRegExpReplace($tc, "\\", "\\\\"))

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
				$msg = $GUI_EVENT_CLOSE

			Case $theGraph
				SpeedlogReset()
				WinActivate($eep)

		EndSwitch ;; msg

		If $msg <> $GUI_EVENT_CLOSE Then
			$msg = 0
		EndIf
	EndIf
	;; WinActivate($eep)
Until $msg == $GUI_EVENT_CLOSE
;; MsgBox(0,"ENDE",$msg & " == " & $GUI_EVENT_CLOSE)
;; aktuelle Einstellungen speichern
SaveOptions()
